## VIRIDA DevOps — Setup CI/CD & SonarQube

Ce dépôt orchestre la CI via **Gitea Actions** (workflow `/.gitea/workflows/ci-main.yml`) et inclut les assets Docker pour **SonarQube**.

### 1) Pré-requis runner (`virida-host`)

Le workflow utilise `runs-on: virida-host`. Le runner doit fournir au minimum :

- `bash`, `curl`, `unzip`
- `python3` (utilisé pour certaines validations + pour `virida-eve` et le quality gate Sonar)
- Node.js est installé via `actions/setup-node@v4`

Optionnel (selon ce que tu veux activer) :

- `cargo` pour exécuter `cargo check` sur `leafnode`
- **Docker + daemon accessible** pour build/push d’images (ex: `virida-eve`)

### 2) Secrets requis (Gitea → repo → Settings → Secrets → Actions)

#### Checkout multi-repos (obligatoire)

- `GITEA`: token d’accès permettant de cloner les repos `Virida/*` (read-only recommandé)

#### SonarQube (obligatoire si tu veux l’analyse)

- `SONAR_HOST_URL`: racine de l’instance, ex `https://ton-sonarqube.domaine`
- `SONAR_TOKEN`: token SonarQube avec permission **Execute Analysis**

#### Frontend build (optionnel mais recommandé)

- `VITE_API_URL`: URL de l'API backend (ex: `https://api.virida.org`). Injecté automatiquement lors du build frontend pour éviter de la stocker en dur dans `.env`.

#### Déploiement Clever Cloud (optionnel)

Le job `deploy-clevercloud` est désactivé par défaut.

- `CD_ENABLED`: `true` pour activer
- `CLEVER_GIT_URL`: URL git de l’app Clever Cloud
- `CLEVER_DEPLOY_REF`: branche cible sur Clever Cloud (`master`/`main`)

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

#### Deploy `virida-eve` vers Clever Cloud (Docker app)

Workflow: `.gitea/workflows/eve-clever-cloud-deploy.yml`. Remplace le push Docker Hub (legacy). Déclenché manuellement ou hebdo (lundi 05:00 UTC).

Setup one-time sur Clever Cloud : créer une app type **Docker**, récupérer l’URL git de déploiement, et (si le Dockerfile est dans `docker/`) définir `CC_DOCKERFILE=docker/Dockerfile` dans les env vars de l’app.

- `CD_EVE_ENABLED`: `true` pour activer (safety switch)
- `CLEVER_EVE_GIT_URL`: URL git du remote Clever Cloud
- `CLEVER_EVE_DEPLOY_REF`: branche cible (`master` ou `main`)

### 3) Remarques importantes

- Les jobs “externes” (`virida-eve`, `leafnode`, `virida_touch_ihm`) sont des **best-effort checks** :
  - si un outil manque sur le runner (ex: `cargo`, docker daemon), le job **skip** proprement avec un warning.
  - si les repos n’ont pas `main` comme branche par défaut, adapter `ref:` dans le workflow.
- **SonarQube** tourne dans un workflow séparé (`.gitea/workflows/sonar-nightly.yml`) qui s’exécute automatiquement à chaque push master (parallèle, non-bloquant) + hebdo + manuel. Pour un scan local rapide : `scripts/sonar-scan-local.sh`.

