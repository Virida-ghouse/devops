# SonarQube on Clever Cloud

## Configuration requise

Dans la console Clever Cloud, définir les variables d'environnement suivantes :

| Variable | Valeur | Description |
|----------|--------|-------------|
| `APP_FOLDER` | `sonarqube` | Dossier du build |
| `CC_HEALTH_CHECK_PATH` | `/health` | **Important** : utilisez `/health` (pas `/api/system/status`) pour que le déploiement réussisse pendant que SonarQube démarre (5+ min) |
| `SONAR_WEB_CONTEXT` | `/` | Contexte web |
| `SONAR_ES_BOOTSTRAP_CHECKS_DISABLE` | `true` | Désactive les checks Elasticsearch en environnement contraint |

L'add-on PostgreSQL doit être lié à l'application (variables `POSTGRESQL_ADDON_*` injectées automatiquement).

## Architecture

- **Nginx** écoute sur le port 8080 (PORT Clever Cloud) et fait proxy vers SonarQube
- **/health** retourne 200 immédiatement → le healthcheck Clever Cloud passe tout de suite
- **SonarQube** démarre en arrière-plan sur le port 9000 (interne) ; le trafic est proxyfié via nginx
