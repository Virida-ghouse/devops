# VIRIDA - Infrastructure DevOps

> Vision globale de l'infrastructure CI/CD, qualité de code, déploiement et sécurité.

---

## 1. Architecture générale

Le repo **devops** (`GitHub: Virida-ghouse/devops`) est le repo central qui orchestre toute l'infrastructure.  
Il est synchronisé en **mirror** vers **Gitea** (`gitea.virida.org`) qui exécute les workflows via **Gitea Actions** sur un runner self-hosted `virida-host`.

### Repos externes

| Repo | Hébergement | Langage | Méthode checkout | Usage |
|------|-------------|---------|------------------|-------|
| `virida_api` | GitHub (Virida-ghouse) | Node.js / Express | Git clone direct (GH_TOKEN) | API backend principale |
| `Virida_marketplace_api` | GitHub (Virida-ghouse) | TypeScript / Express | Git clone direct (GH_TOKEN) | API marketplace |
| `virida_app` | Gitea (Virida) | React / Vite | actions/checkout | Frontend principal |
| `virida-eve` | Gitea (Virida) | Python / FastAPI | actions/checkout | Chatbot IA (RAG) |
| `virida_touch_ihm` | Gitea (Virida) | React / Node | actions/checkout | IHM Raspberry Pi |
| `leafnode` | Gitea (Virida) | Rust / ESP-IDF | actions/checkout | Firmware capteurs IoT |

### Submodules Git (`.gitmodules`)

```
virida_api  → https://github.com/Virida-ghouse/virida_api.git
virida_app  → https://github.com/Virida-ghouse/virida_app.git
```

---

## 2. Pipeline CI principale (`ci-main.yml`)

- **Taille** : 1 293 lignes
- **Jobs** : 10 (exécution séquentielle)
- **Runner** : `virida-host`

### Déclencheurs

| Événement | Détail |
|-----------|--------|
| `push` | Branches `main`, `master` |
| `pull_request` | Branche `main` |
| `schedule` | Toutes les 10 min (`*/10 * * * *`) — workaround mirror Gitea |
| `workflow_dispatch` | Déclenchement manuel |

### Chaîne d'exécution des jobs

```
validate → test-eve → test-leafnode → test-touch-ihm → test-frontend → test-backend → security → build → sonar-quality-gate → ci-summary + ci-metrics
```

| # | Job | Description |
|---|-----|-------------|
| 1 | **validate** | Preflight runner, check refs (advisory), validation YAML/JSON |
| 2 | **test-eve** | Python compile, Docker checks, RAG benchmark |
| 3 | **test-leafnode** | Cargo check + clippy (Rust/ESP) |
| 4 | **test-touch-ihm** | Install + lint/build Node/React |
| 5 | **test-frontend** | Lint + test + build `virida_app` (timeout 15min) |
| 6 | **test-backend** | Lint + test + build `virida_api` (Prisma generate) |
| 7 | **security** | npm audit, Gitleaks, Trivy (fs+IaC+image), Semgrep |
| 8 | **build** | Build final frontend (timeout 20min) + backend |
| 9 | **sonar-quality-gate** | Vérifie les quality gates SonarQube (non-bloquant) |
| 10 | **ci-summary + ci-metrics** | Résumé CI + artefact JSON de métriques |

> Tous les jobs utilisent `if: always()` pour garantir un rapport complet même en cas d'échec.

---

## 3. SonarQube (`sonar-nightly.yml`)

- **Taille** : 421 lignes
- **SonarQube** : v10.7.0 (self-hosted sur Clever Cloud)
- **SonarScanner CLI** : v8.0.1.6346

### Déclencheurs

| Événement | Détail |
|-----------|--------|
| `workflow_run` | Automatiquement après `ci-main` (completed) |
| `schedule` | Tous les jours à 3h00 (`0 3 * * *`) |
| `workflow_dispatch` | Manuel |

### Projets scannés

| Projet | Langage | Framework tests | Nb tests | Couverture | Format rapport |
|--------|---------|-----------------|----------|------------|---------------|
| `virida_api` | JavaScript | Jest 29 | 172 | **97.5%** | lcov.info |
| `Virida_marketplace_api` | TypeScript | Vitest 4.1 | 170 | **90.93%** | lcov.info |
| `virida-eve` | Python | pytest + pytest-cov | 82 | **93%** | coverage.xml |

### Configuration

- **Coverage minimum** : 90% (via `SONAR_COVERAGE_MINIMUM`)
- **Quality Gate** : Non-bloquant (`SONAR_GATE_ENFORCE=false`), émet des `::warning::` si échec
- **Exclusions de couverture** (virida_api) :
  - `src/config/**`, `src/services/**`, `src/utils/**`
  - `src/middleware/logger.js`
  - `src/routes/analytics.js`, `timeseries.js`, `eve.js`

### Environnement CI pour les tests

| Variable | Valeur | Raison |
|----------|--------|--------|
| `DATABASE_URL` | `postgresql://user:pass@localhost:5432/...` | URL fictive pour Prisma |
| `CELLAR_ADDON_HOST` | `mock-s3.example.com` | Mock S3 pour marketplace_api |
| `CELLAR_ADDON_KEY_ID` | `mock-key-id` | Mock S3 |
| `CELLAR_ADDON_KEY_SECRET` | `mock-secret-key` | Mock S3 |
| `CI` | `true` | Détection environnement CI |

---

## 4. Sécurité

### Outils de scan (job `security` dans ci-main.yml)

| Outil | Type | Cible | Mode |
|-------|------|-------|------|
| **npm audit** | Dépendances | package-lock.json (front + back) | Advisory (warning) |
| **Gitleaks 8.24.3** | Secrets | Tout le codebase | **Bloquant** |
| **Trivy filesystem** | Vulnérabilités | package-lock.json | Bloquant (CRITICAL/HIGH) |
| **Trivy IaC** | Misconfigurations | Dockerfiles | Bloquant (avec `.trivyignore`) |
| **Trivy image** | Container | Images Docker | Progressif |
| **Semgrep** | SAST | Code source | Progressif (non-bloquant) |

### `.trivyignore` — Exclusions

| Règle | Description | Raison |
|-------|-------------|--------|
| `DS-0029` | Missing `--no-install-recommends` | Dockerfiles d'infra, pas critique |
| `DS-0002` | Containers running as root | Containers CI/build, pas production |

---

## 5. Déploiement (CD)

### Workflows de déploiement

| Workflow | Cible | Déclencheur | Plateforme | Timeout |
|----------|-------|-------------|------------|---------|
| `api-clever-cloud-deploy.yml` | virida_api | Push main + schedule Lun 01h | Clever Cloud | 12 min |
| `eve-clever-cloud-deploy.yml` | virida-eve | Manuel + schedule Lun 05h | Clever Cloud | 10 min |
| `touch-ihm-deploy.yml` | virida_touch_ihm | Manuel + schedule Lun 04h | Raspberry Pi (rsync SSH) | 20 min |
| `leafnode-release.yml` | leafnode firmware | Push tag `leafnode-v*` | Gitea Release | 45 min |

### Protections de déploiement

Tous les workflows CD incluent :
- **Approval gate** : `confirm_production=true` requis pour les déclenchements manuels
- **`PROD_AUTO_APPROVED`** : Secret requis `true` pour les déploiements schedulés
- **`CD_*_ENABLED`** : Interrupteur on/off pour chaque workflow
- **`dry_run`** : Mode simulation sans déploiement réel
- **`rollback_ref`** : Input optionnel pour rollback sur un SHA/tag spécifique

### Clever Cloud

Déploiement via `git push` vers le remote Clever Cloud :
- `CLEVER_API_GIT_URL` pour virida_api
- `CLEVER_EVE_GIT_URL` pour virida-eve
- Environnement `production` configuré

### Raspberry Pi (Touch IHM)

- Déploiement via `rsync` SSH
- Secrets : `RPI_SSH_HOST`, `RPI_SSH_USER`, `RPI_SSH_KEY`
- Build Node.js local puis sync du `dist/`
- Post-deploy command optionnel via `RPI_POST_DEPLOY_CMD`

---

## 6. Secrets et variables

### Secrets Gitea requis

| Secret | Usage | Workflows |
|--------|-------|-----------|
| `GITEA` | Token Gitea pour checkout repos internes | Tous |
| `GH_TOKEN_MARKETPLACE` | Token GitHub pour checkout virida_api + marketplace_api | ci-main, sonar-nightly |
| `SONAR_TOKEN` | Token SonarQube pour upload des scans | sonar-nightly, ci-main |
| `SONAR_HOST_URL` | URL du serveur SonarQube | sonar-nightly, ci-main |
| `CLEVER_API_GIT_URL` | Remote git Clever Cloud pour virida_api | api-clever-cloud-deploy |
| `CLEVER_EVE_GIT_URL` | Remote git Clever Cloud pour virida-eve | eve-clever-cloud-deploy |
| `CD_API_ENABLED` | Active le deploy API (true/false) | api-clever-cloud-deploy |
| `CD_EVE_ENABLED` | Active le deploy EVE | eve-clever-cloud-deploy |
| `PROD_AUTO_APPROVED` | Autorise les deploys schedulés | Workflows CD |
| `RPI_SSH_HOST` / `USER` / `KEY` | Connexion SSH au Raspberry Pi | touch-ihm-deploy |

### Variables de référence (branches/tags)

| Variable | Défaut | Usage |
|----------|--------|-------|
| `VIRIDA_API_REF` | `main` | Branche/tag/SHA de virida_api à checkout |
| `VIRIDA_APP_REF` | `main` | Branche/tag/SHA de virida_app |
| `VIRIDA_EVE_REF` | `main` | Branche/tag/SHA de virida-eve |
| `VIRIDA_TOUCH_IHM_REF` | `main` | Branche/tag/SHA de virida_touch_ihm |
| `VIRIDA_MARKETPLACE_API_REF` | `main` | Branche/tag/SHA de Virida_marketplace_api |
| `LEAFNODE_REF` | `main` | Branche/tag/SHA de leafnode |

> Pour verrouiller sur une version spécifique, configurer ces secrets avec un tag ou SHA immutable.

---

## 7. Infrastructure Docker

| Fichier | Rôle |
|---------|------|
| `Dockerfile` | Image principale de l'application |
| `Dockerfile.simple` | Image simplifiée (alternative) |
| `Dockerfile.gitea` | Instance Gitea (serveur Git) |
| `Dockerfile.gitea-runner` | Runner Gitea Actions (CI) |
| `sonarqube/Dockerfile` | Instance SonarQube (analyse code) |

Toutes les images sont déployées sur Clever Cloud.

---

## 8. Runner CI (`virida-host`)

### Caractéristiques

| Propriété | Valeur |
|-----------|--------|
| Type | Self-hosted sur Clever Cloud |
| OS | Linux amd64 (kernel 6.19.7) |
| Node.js | 20.19.0 (via `actions/setup-node`) |
| Python | 3.x (pré-installé) |
| Outils | bash, curl, unzip, git, npm, python3, PyYAML |
| Optionnels | cargo (Rust), docker, espup (ESP-IDF) |

### Limitations connues

- Docker build peut échouer (sandbox user namespaces) → géré en mode gracieux avec warning
- Mirror sync Gitea parfois lent → workaround avec cron `*/10` et checkout direct GitHub
- Pas de cache npm natif → `actions/setup-node` avec cache

---

## 9. Flux complet (du push au déploiement)

```
1. Push sur GitHub (Virida-ghouse/devops)
2. Mirror sync vers Gitea (gitea.virida.org) — ~10 min max
3. Gitea déclenche ci-main.yml
   └── validate → test-eve → test-leafnode → test-touch-ihm
       → test-frontend → test-backend → security → build → sonar-quality-gate
4. Quand ci-main termine → sonar-nightly.yml se déclenche automatiquement
   └── Install deps → Run tests + coverage → SonarScanner → Quality gates
5. Si CD actif → api-clever-cloud-deploy push vers Clever Cloud
6. Déploiements EVE/IHM : manuels ou schedulés (Lundi 04h-05h)
```

---

## 10. Fichiers de configuration clés

| Fichier | Emplacement | Rôle |
|---------|-------------|------|
| `ci-main.yml` | `.gitea/workflows/` | Pipeline CI principale (1 293 lignes) |
| `sonar-nightly.yml` | `.gitea/workflows/` | Scan SonarQube (421 lignes) |
| `api-clever-cloud-deploy.yml` | `.gitea/workflows/` | CD API vers Clever Cloud |
| `eve-clever-cloud-deploy.yml` | `.gitea/workflows/` | CD EVE vers Clever Cloud |
| `touch-ihm-deploy.yml` | `.gitea/workflows/` | CD IHM vers Raspberry Pi |
| `leafnode-release.yml` | `.gitea/workflows/` | Release firmware ESP32 |
| `sonar-project.properties` | `virida_api/` | Config SonarQube virida_api |
| `jest.config.mjs` | `virida_api/` | Config Jest (tests backend) |
| `vitest.config.ts` | `Virida_marketplace_api/` | Config Vitest (tests marketplace) |
| `pytest.ini` | `virida-eve/` | Config pytest (tests EVE) |
| `.trivyignore` | Racine | Exclusions Trivy (Dockerfiles infra) |
| `actions.yml` | `.gitea/` | Actions pinned (SHAs GitHub) |

---

## 11. Métriques globales

| Métrique | Valeur |
|----------|--------|
| Workflows CI/CD | 6 |
| Lignes YAML totales | 2 914 |
| Dockerfiles | 5 |
| Projets SonarQube | 3 |
| Tests totaux | 424 (172 + 170 + 82) |
| Couverture moyenne | ~94% |
| Commits CI (30 derniers jours) | 109 |
| Vulnérabilités HIGH | 0 |
| Secrets détectés | 0 |
