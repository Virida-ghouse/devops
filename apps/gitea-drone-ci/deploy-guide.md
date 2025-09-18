# 🚀 Guide de Déploiement Optimisé - VIRIDA Gitea + Drone CI

Basé sur la documentation officielle Clever Cloud et Gitea.

## 📋 Étapes de Déploiement

### 1. Créer l'application sur Clever Cloud

1. **Allez sur** [console.clever-cloud.com](https://console.clever-cloud.com)
2. **Cliquez sur** "Create an application"
3. **Sélectionnez** "Go" comme type d'application
4. **Nommez-la** : `gitea-drone-ci`
5. **Sélectionnez** la région `par` (Paris)
6. **Cliquez sur** "Create"

### 2. Configurer les variables d'environnement

Une fois l'application créée, allez dans **Settings > Environment variables** et ajoutez :

#### Variables Clever Cloud (optimisées)
```bash
CC_GO_BUILD_TOOL=gomod
CC_GO_PKG=main.go
CC_RUN_COMMAND=./gitea-drone-ci
CC_HEALTH_CHECK_PATH=/health
CC_WORKER_RESTART=always
CC_WORKER_RESTART_DELAY=5
```

#### Variables de l'application
```bash
PORT=8080
GITEA_PORT=3000
DRONE_PORT=3001
DATA_DIR=/tmp/gitea-drone
DRONE_SECRET=virida-super-secret-key-2024
GITEA_DOMAIN=gitea-drone-ci.cleverapps.io
DRONE_HOST=gitea-drone-ci.cleverapps.io
GITEA_CLIENT_ID=gitea-oauth-client-2024
GITEA_CLIENT_SECRET=gitea-oauth-secret-2024
```

#### Variables de base de données
```bash
GITEA_DB_TYPE=postgres
GITEA_DB_HOST=bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:50013
GITEA_DB_NAME=bjduvaldxkbwljy3uuel
GITEA_DB_USER=uncer3i7fyqs2zeult6r
GITEA_DB_PASS=WuobPl6Nyk9X0Z4DKF7BlxE55z2buu

DRONE_DB_TYPE=postgres
DRONE_DB_HOST=bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:50013
DRONE_DB_NAME=bjduvaldxkbwljy3uuel
DRONE_DB_USER=uncer3i7fyqs2zeult6r
DRONE_DB_PASS=WuobPl6Nyk9X0Z4DKF7BlxE55z2buu
```

### 3. Déployer l'application

```bash
# Récupérer l'URL de déploiement depuis Clever Cloud
git remote add gitea-drone-ci https://push-n3-par-clevercloud-customers.services.clever-cloud.com/app_XXXXXXXX.git

# Déployer
git push gitea-drone-ci staging
```

### 4. Configurer OAuth dans Gitea

1. **Attendez** que l'application soit déployée (2-3 minutes)
2. **Accédez à** `https://gitea-drone-ci.cleverapps.io:3000`
3. **Créez un compte admin** (première connexion)
4. **Allez dans** Settings > Applications
5. **Créez une nouvelle application OAuth** :
   - **Application Name** : Drone CI
   - **Redirect URI** : `https://gitea-drone-ci.cleverapps.io:3001/login`
6. **Copiez le Client ID et Secret**
7. **Mettez à jour** les variables d'environnement dans Clever Cloud :
   - `GITEA_CLIENT_ID` = Client ID copié
   - `GITEA_CLIENT_SECRET` = Client Secret copié
8. **Redéployez** l'application

### 5. Vérifier le déploiement

#### Tests des endpoints
```bash
# Health check
curl https://gitea-drone-ci.cleverapps.io/health

# Status des services
curl https://gitea-drone-ci.cleverapps.io/status

# Page principale
curl https://gitea-drone-ci.cleverapps.io/
```

#### URLs d'accès
- **Application principale** : `https://gitea-drone-ci.cleverapps.io`
- **Gitea** : `https://gitea-drone-ci.cleverapps.io:3000`
- **Drone CI** : `https://gitea-drone-ci.cleverapps.io:3001`

## 🔧 Configuration Avancée

### Variables Clever Cloud Optimisées

Basées sur la documentation officielle :

- `CC_GO_BUILD_TOOL=gomod` : Utilise Go modules pour la compilation
- `CC_HEALTH_CHECK_PATH=/health` : Endpoint de health check
- `CC_WORKER_RESTART=always` : Redémarre automatiquement les services
- `CC_WORKER_RESTART_DELAY=5` : Délai de 5 secondes avant redémarrage

### Configuration Gitea Optimisée

- **Base de données** : PostgreSQL (votre DB existante)
- **Port** : 3000 (configurable)
- **Mode** : Production
- **SSH** : Désactivé (Clever Cloud)

### Configuration Drone CI Optimisée

- **Base de données** : PostgreSQL (même DB que Gitea)
- **Port** : 3001 (configurable)
- **Intégration** : OAuth avec Gitea
- **Runner** : Docker (inclus)

## 🚨 Dépannage

### Problèmes courants

1. **Application ne démarre pas** :
   - Vérifiez les logs : `clever logs --alias gitea-drone-ci`
   - Vérifiez les variables d'environnement

2. **Gitea ne se connecte pas à la DB** :
   - Vérifiez `GITEA_DB_*` variables
   - Testez la connexion PostgreSQL

3. **Drone ne se connecte pas à Gitea** :
   - Vérifiez `GITEA_CLIENT_ID` et `GITEA_CLIENT_SECRET`
   - Vérifiez que Gitea est accessible

4. **Services ne redémarrent pas** :
   - Vérifiez `CC_WORKER_RESTART=always`
   - Vérifiez les logs pour les erreurs

### Logs utiles

```bash
# Logs de l'application
clever logs --alias gitea-drone-ci

# Logs Gitea
clever logs --alias gitea-drone-ci | grep gitea

# Logs Drone
clever logs --alias gitea-drone-ci | grep drone
```

## ✅ Checklist de Déploiement

- [ ] Application créée sur Clever Cloud
- [ ] Variables d'environnement configurées
- [ ] Code déployé avec `git push`
- [ ] Gitea accessible sur le port 3000
- [ ] OAuth configuré dans Gitea
- [ ] Variables OAuth mises à jour
- [ ] Application redéployée
- [ ] Drone CI accessible sur le port 3001
- [ ] Tests des endpoints réussis
- [ ] Health check fonctionnel

## 🎯 Prochaines étapes

1. **Créer des repositories** dans Gitea
2. **Configurer des pipelines** Drone CI
3. **Tester la CI/CD** avec un commit
4. **Configurer les webhooks** automatiques
5. **Monitoring** avec Prometheus/Grafana

---

**🎉 Votre Gitea + Drone CI est maintenant opérationnel sur Clever Cloud !**
