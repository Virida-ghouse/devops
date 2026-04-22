## CD VIRIDA - etat reel

Le deploiement n'est plus dans `ci-main.yml`. Les workflows CD/release actifs sont:

- `.gitea/workflows/api-clever-cloud-deploy.yml` (deploiement `virida_api`)
- `.gitea/workflows/app-clever-cloud-deploy.yml` (deploiement `virida_app`)
- `.gitea/workflows/eve-clever-cloud-deploy.yml` (deploiement `virida-eve`)
- `.gitea/workflows/touch-ihm-deploy.yml` (deploiement `virida_touch_ihm` sur Raspberry Pi)
- `.gitea/workflows/leafnode-release.yml` (release firmware `leafnode`)

## API vers Clever Cloud

Secrets requis:

- `CD_API_ENABLED`: `true` pour autoriser le deploiement
- `CLEVER_API_GIT_URL`: remote git Clever Cloud de `virida_api`
- `CLEVER_API_DEPLOY_REF`: branche cible (`main`, `release/*`, `hotfix/*`)
- `PROD_AUTO_APPROVED` (optionnel): `true` pour autoriser un deploiement planifie (schedule)

Notes:

- Auto-deploy sur `push main` quand `CD_API_ENABLED=true`.
- Supporte `dry_run=true` en manuel.
- Le workflow supporte `rollback_ref=<tag|sha|ref>`.

## APP vers Clever Cloud

Secrets requis:

- `CD_APP_ENABLED`: `true` pour autoriser le deploiement
- `CLEVER_APP_GIT_URL`: remote git Clever Cloud de `virida_app`
- `CLEVER_APP_DEPLOY_REF`: branche cible (`main`, `release/*`, `hotfix/*`)
- `PROD_AUTO_APPROVED` (optionnel): `true` pour autoriser un deploiement planifie (schedule)

Notes:

- Auto-deploy sur `push main` quand `CD_APP_ENABLED=true`.
- Supporte `dry_run=true` en manuel.
- Le workflow supporte `rollback_ref=<tag|sha|ref>`.

## EVE vers Clever Cloud

Secrets requis:

- `CD_EVE_ENABLED`: `true` pour autoriser le deploiement
- `CLEVER_EVE_GIT_URL`: remote git Clever Cloud
- `CLEVER_EVE_DEPLOY_REF`: branche cible (`main`, `release/*`, `hotfix/*`)
- `PROD_AUTO_APPROVED` (optionnel): `true` pour autoriser un deploiement planifie (schedule)

Notes:

- Le workflow supporte `dry_run=true` pour valider sans push.
- Le workflow exige un **approval explicite** en manuel: `confirm_production=true`.
- Le push est non force (`git push` sans `--force`).
- Le workflow peut etre lance manuellement et en hebdomadaire.
- Le workflow supporte un rollback cible: `rollback_ref=<tag|sha|ref>` pour redeployer une revision precedente.
- Avant chaque push, le workflow affiche la commande de rollback rapide vers le SHA precedent.

## Touch IHM vers Raspberry Pi

Secrets requis:

- `RPI_SSH_HOST`, `RPI_SSH_USER`, `RPI_SSH_KEY`, `RPI_SSH_KNOWN_HOSTS`, `RPI_DEPLOY_PATH`
- `PROD_AUTO_APPROVED` (optionnel): `true` pour autoriser un deploiement planifie (schedule)

Notes:

- Le workflow exige un **approval explicite** en manuel: `confirm_production=true` (hors `dry_run`).
- Le deploiement utilise `rsync --delete` avec `--backup --backup-dir`.
- Un dossier de rollback horodate est cree sur le Pi hors cible synchronisee dans `$(dirname RPI_DEPLOY_PATH)/.$(basename RPI_DEPLOY_PATH)-rollback/<timestamp>`.

## Convention de branche

- Standard operationnel: `main`.
- Les workflows CI de ce repo sont declenches sur `main` uniquement.

