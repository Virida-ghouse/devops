## VIRIDA DevOps — Setup CI/CD & SonarQube

Ce dépôt orchestre la CI via **Gitea Actions** (workflow `/.gitea/workflows/ci-main.yml`) et inclut les assets Docker pour **SonarQube**.

> Si le repo est en **pull mirror** (GitHub -> Gitea), les événements `push` ne déclenchent pas toujours les workflows en Gitea 1.22.x.
> Les workflows principaux incluent donc un `schedule` toutes les 15 minutes pour conserver un mode "auto" sans désactiver le mirror.

### 1) Pré-requis runner (`virida-host`)

Le workflow utilise `runs-on: virida-host`. Le runner doit fournir au minimum :

- `bash`, `curl`, `unzip`
- `python3` (utilisé pour certaines validations + pour `virida-eve` et le quality gate Sonar)
- Node.js est installé via `actions/setup-node@v4`

Optionnel (selon ce que tu veux activer) :

- `cargo` pour exécuter `cargo check` sur `leafnode`
- **Docker + daemon accessible** pour build/push d’images (ex: `virida-eve`)

#### Flavor Clever Cloud du runner

Le runner Gitea est une app Clever Cloud (build depuis `Dockerfile.gitea-runner`). Le **flavor** recommandé dépend de ce que tu actives :

| Usage | Flavor | RAM | Note |
|---|---|---|---|
| CI basique seule | XS | 1 GB | suffisant pour `ci-main.yml` |
| CI + SonarQube | **M** | **4 GB** | **recommandé** — scans Java + Node.js workers |
| CI + Sonar + builds Docker lourds | L | 8 GB | si tu réactives `virida-eve` Docker local |

Pour scaler :
```bash
clever applications list                      # repère l'app Gitea Runner
clever scale --flavor M --app <app_id>        # applique immédiatement
```
Ou via l'UI : `Console CC → app Gitea Runner → Scalability → min/max = M`.

### 2) Secrets requis (Gitea → repo → Settings → Secrets → Actions)

#### Checkout multi-repos (obligatoire)

- `GITEA`: token d’accès permettant de cloner les repos `Virida/*` (read-only recommandé)

#### SonarQube (obligatoire si tu veux l’analyse)

- `SONAR_HOST_URL`: racine de l’instance, ex `https://ton-sonarqube.domaine`
- `SONAR_TOKEN`: token SonarQube avec permission **Execute Analysis**

#### Frontend build (optionnel mais recommandé)

- `VITE_API_URL`: URL de l'API backend (ex: `https://api.virida.org`). Injecté automatiquement lors du build frontend pour éviter de la stocker en dur dans `.env`.

#### Déploiement Clever Cloud

Le job générique `deploy-clevercloud` de `ci-main.yml` a été supprimé (il poussait le repo `devops` lui-même, ce qui n’a pas de sens). Le CD est maintenant **par app**, dans des workflows dédiés :

| App Clever Cloud | Workflow | Secrets à configurer |
|---|---|---|
| `virida_api` (backend Node.js) | `api-clever-cloud-deploy.yml` | `CD_API_ENABLED`, `CLEVER_API_GIT_URL`, `CLEVER_API_DEPLOY_REF` |
| `virida_app` (frontend) | `app-clever-cloud-deploy.yml` | `CD_APP_ENABLED`, `CLEVER_APP_GIT_URL`, `CLEVER_APP_DEPLOY_REF` |
| `virida-eve` (Docker) | `eve-clever-cloud-deploy.yml` | `CD_EVE_ENABLED`, `CLEVER_EVE_GIT_URL`, `CLEVER_EVE_DEPLOY_REF` |
| `Gitea`, `Gitea Runner`, `SonarQube` | _manuel (`clever deploy`)_ | — |

**Déclenchement** : tous ces workflows sont manuels (`workflow_dispatch` depuis l’UI Gitea Actions) + hebdomadaire (drift correction). Ils supportent un input `dry_run` pour tester sans push.

**Comment récupérer `CLEVER_*_GIT_URL`** :
```bash
cd <dossier de l'app>
clever status        # affiche l'app id
# ou dans .clever.json : champ "deploy_url" / "git_ssh_url"
```

Pour `virida_api`, la valeur est déjà dans `virida_api/.clever.json` :
`git+ssh://git@push-n3-par-clevercloud-customers.services.clever-cloud.com/app_ff40e2dd-3bab-4a9b-82c4-8aa517a9a3f6.git`

#### Push d’image Docker `virida-eve` (optionnel — legacy, préférer CC Docker)

- `EVE_IMAGE_PUSH_ENABLED`: `true` pour activer
- `EVE_REGISTRY`
- `EVE_IMAGE_NAME`
- `EVE_REGISTRY_USERNAME`
- `EVE_REGISTRY_PASSWORD`

#### Release firmware `leafnode` (optionnel)

Workflow: `.gitea/workflows/leafnode-release.yml`. Déclenché sur push d’un tag `leafnode-v*` ou manuellement.

- `GITEA_RELEASE_HOST`: host Gitea (ex: `ssh.gitea.virida.org`)
- `GITEA_RELEASE_OWNER`: propriétaire du repo (ex: `Virida`)
- `GITEA_RELEASE_REPO`: nom du repo (ex: `leafnode`)
- `LEAFNODE_FULL_BUILD` (optionnel): `true` côté secret `test-leafnode` pour activer aussi `cargo check`/`clippy` dans la CI principale

#### Deploy `virida_touch_ihm` vers Raspberry Pi (optionnel)

Workflow: `.gitea/workflows/touch-ihm-deploy.yml`. Déclenché manuellement (UI Gitea) ou hebdo (lundi 04:00 UTC).

- `RPI_SSH_HOST`: IP ou hostname du Pi (ex: `192.168.1.42`)
- `RPI_SSH_USER`: utilisateur SSH (ex: `pi`)
- `RPI_SSH_KEY`: contenu **intégral** de la clé privée SSH (ex: `id_ed25519`). La clé publique correspondante doit être dans `~/.ssh/authorized_keys` du Pi.
- `RPI_SSH_PORT` (optionnel, défaut 22)
- `RPI_SSH_KNOWN_HOSTS` (recommandé): sortie de `ssh-keyscan <host>` pour éviter `StrictHostKeyChecking=no`
- `RPI_DEPLOY_PATH`: chemin absolu sur le Pi (ex: `/var/www/virida-touch`)
- `RPI_POST_DEPLOY_CMD` (optionnel): commande à exécuter après rsync, ex: `sudo systemctl restart virida-touch`

### 3) Remarques importantes

- Les jobs “externes” (`virida-eve`, `leafnode`, `virida_touch_ihm`) sont des **best-effort checks** :
  - si un outil manque sur le runner (ex: `cargo`, docker daemon), le job **skip** proprement avec un warning.
  - si les repos n’ont pas `main` comme branche par défaut, adapter `ref:` dans le workflow.
- **SonarQube** tourne dans un workflow séparé (`.gitea/workflows/sonar-nightly.yml`) qui s’exécute automatiquement à chaque push master (parallèle, non-bloquant) + hebdo + manuel. Pour un scan local rapide : `scripts/sonar-scan-local.sh`.

