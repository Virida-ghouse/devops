## VIRIDA DevOps — Setup CI/CD & SonarQube

Ce dépôt orchestre la CI via **Gitea Actions** (workflow `/.gitea/workflows/ci-main.yml`) et inclut les assets Docker pour **SonarQube**.

> Les anciens scripts legacy d'onboarding ont ete retires du depot.
> Les valeurs de secrets ne doivent jamais etre hardcodees. La source de verite reste ce document + `CD_SETUP.md`.

> Si le repo est en **pull mirror** (GitHub -> Gitea), les événements `push` ne déclenchent pas toujours les workflows en Gitea 1.22.x.
> Les workflows principaux incluent donc un `schedule` periodique (toutes les 10 min pour la CI principale) pour conserver un mode "auto" sans desactiver le mirror.

### 1) Pré-requis runner (`virida-host`)

Le workflow utilise `runs-on: virida-host`. Le runner doit fournir au minimum :

- `bash`, `curl`, `unzip`
- `python3` (utilisé pour certaines validations + pour `virida-eve` et le quality gate Sonar)
- `PyYAML` preinstalle dans l'image runner (utilise par la validation YAML stricte de `ci-main.yml`)

`PyYAML` est bake dans `Dockerfile.gitea-runner` via le paquet systeme `python3-yaml` (pas d'installation dynamique en job CI).
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

- `GITEA`: token d’accès permettant de cloner les repos `Virida/*` (**read-only obligatoire** sauf besoin explicite d’ecriture)
- `GH_TOKEN_MARKETPLACE` (obligatoire): token GitHub (scope repo read) pour cloner `Virida-ghouse/Virida_marketplace_api` et `Virida-ghouse/Virida_marketplace_app` (repos privés)
- `VIRIDA_API_REF` (optionnel): ref immuable recommandee pour `Virida/virida_api` (tag ou commit SHA)
- `VIRIDA_APP_REF` (optionnel): ref immuable recommandee pour `Virida/virida_app` (tag ou commit SHA)
- `VIRIDA_MARKETPLACE_API_REF` (optionnel): ref immuable recommandee pour `Virida-ghouse/Virida_marketplace_api` (tag ou commit SHA). Par defaut: `main`
- `VIRIDA_MARKETPLACE_APP_REF` (optionnel): ref immuable recommandee pour `Virida-ghouse/Virida_marketplace_app` (tag ou commit SHA)
- `VIRIDA_EVE_REF` (optionnel): ref immuable recommandee pour `Virida/virida-eve` (tag ou commit SHA)
- `VIRIDA_TOUCH_IHM_REF` (optionnel): ref immuable recommandee pour `Virida/virida_touch_ihm` (tag ou commit SHA)
- `ALLOW_MOVING_EXTERNAL_REFS` (optionnel): `false` par defaut (mode securise). Ne passez temporairement a `true` que pour une migration controlee et bornee dans le temps.

#### SonarQube (obligatoire si tu veux l’analyse)

- `SONAR_HOST_URL`: racine de l’instance, ex `https://ton-sonarqube.domaine`
- `SONAR_TOKEN`: token SonarQube avec permissions **Execute Analysis** + **Browse** (ou admin projet) pour permettre le scan **et** la verification bloquante des quality gates
- `SONAR_HARD_GATE_ENABLED` (optionnel): laisser vide ou `true` pour appliquer le hard gate dans `ci-main.yml` quand les secrets Sonar sont presents

#### Frontend build (optionnel mais recommandé)

- `VITE_API_URL`: URL de l'API backend (ex: `https://api.virida.org`). Injecté automatiquement lors du build frontend pour éviter de la stocker en dur dans `.env`.

#### Déploiement Clever Cloud

Le job générique `deploy-clevercloud` de `ci-main.yml` a été supprimé. Les workflows de déploiement actuellement actifs sont :

| Cible | Workflow | Secrets à configurer |
|---|---|---|
| `virida_api` | `api-clever-cloud-deploy.yml` | `CD_API_ENABLED`, `CD_API_AUTO_DEPLOY`, `CLEVER_API_GIT_URL`, `CLEVER_API_DEPLOY_REF` |
| `virida-eve` | `eve-clever-cloud-deploy.yml` | `CD_EVE_ENABLED`, `CLEVER_EVE_GIT_URL`, `CLEVER_EVE_DEPLOY_REF` |
| `virida_touch_ihm` (Raspberry Pi) | `touch-ihm-deploy.yml` | `RPI_SSH_HOST`, `RPI_SSH_USER`, `RPI_SSH_KEY`, `RPI_DEPLOY_PATH` |
| `leafnode` (release firmware) | `leafnode-release.yml` | `GITEA_RELEASE_HOST`, `GITEA_RELEASE_OWNER`, `GITEA_RELEASE_REPO` |

**Déclenchement** :
- `virida_api`: auto sur `push main` + manuel (`workflow_dispatch`) + hebdomadaire.
- `virida-eve`, `virida_touch_ihm`, `leafnode`: manuel + hebdomadaire (ou tag push pour `leafnode`).
- Tous supportent `dry_run` quand applicable.

Le workflow `virida_api` attend l'etat `success` des checks CI du commit avant de pousser vers Clever Cloud.
En mode `push`, ce workflow checkout egalement `github.sha` (meme artefact code que celui valide par CI).

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
- `RPI_SSH_KNOWN_HOSTS` (obligatoire): sortie de `ssh-keyscan <host>` pour conserver `StrictHostKeyChecking=yes`
- `RPI_DEPLOY_PATH`: chemin absolu sur le Pi (ex: `/var/www/virida-touch`)
- `RPI_POST_DEPLOY_CMD` (optionnel): commande à exécuter après rsync, ex: `sudo systemctl restart virida-touch`

### 3) Convention de branche

- Branche principale de reference: `main`.
- La CI de ce repo ecoute uniquement `main` (push + pull_request).
- Les refs externes restent pilotables par secrets (`VIRIDA_*_REF`) et doivent etre des refs immuables sur `main` (tag/SHA).

### 4) Checklist minimale de durcissement secrets

- Utiliser des tokens dedies CI/CD (pas de token personnel long-lived).
- Scope minimal: lecture seule par defaut (`GITEA`), ecriture uniquement pour les workflows qui poussent.
- Rotation trimestrielle des secrets critiques (`SONAR_TOKEN`, registry creds, SSH keys).
- Preferer des credentials distincts par workflow/cible pour reduire le blast radius.
- Supprimer immediatement les secrets non utilises.

### 5) Remarques importantes

- `ci-main.yml` a ete factorise avec reutilisation YAML des steps de checkout/setup (`&...` / `*...`) pour reduire la duplication et la dette de maintenance.
- Les jobs “externes” (`virida-eve`, `leafnode`, `virida_touch_ihm`) sont des **best-effort checks** par defaut :
  - si un outil manque sur le runner (ex: `cargo`, docker daemon), le job **skip** proprement avec un warning (ou echoue si mode strict).
  - la convention cible est `main` pour les refs externes; les ecarts legacy doivent etre migres puis verrouilles.
- `STRICT_EXTERNAL_CHECKS` est considere `true` par defaut dans `ci-main.yml` (le secret peut etre utilise uniquement pour override explicite).
- **SonarQube**: le gate est maintenant verifie en mode bloquant dans `ci-main.yml` (job `sonar-quality-gate`) quand les secrets Sonar sont configures. Le workflow séparé (`.gitea/workflows/sonar-nightly.yml`) reste en support quotidien + manuel pour analyses completes.
- **Cache toolchains**: `setup-node` utilise `cache: npm` (CI principale + Sonar), `sonar-nightly` met en cache le binaire SonarScanner, et `test-leafnode` met en cache les toolchains Rust/ESP (`~/.cargo`, `~/.rustup`, `~/.espressif`) pour reduire la latence des runs lourds.
- **Supply chain Actions**: les actions critiques restent pinnees par SHA (dont `actions/cache`), pour eviter les derives de tags mutables.
- Un artefact `ci-metrics-<run_id>` est publie a chaque pipeline avec un JSON de statuts de jobs (base pour KPI: taux d'echec, tendances, MTTR).

