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

#### Push d’image Docker `virida-eve` (optionnel)

- `EVE_IMAGE_PUSH_ENABLED`: `true` pour activer
- `EVE_REGISTRY`
- `EVE_IMAGE_NAME`
- `EVE_REGISTRY_USERNAME`
- `EVE_REGISTRY_PASSWORD`

### 3) Remarques importantes

- Les jobs “externes” (`virida-eve`, `leafnode`, `virida_touch_ihm`) sont des **best-effort checks** :
  - si un outil manque sur le runner (ex: `cargo`, docker daemon), le job **skip** proprement avec un warning.
  - si les repos n’ont pas `main` comme branche par défaut, adapter `ref:` dans le workflow.

