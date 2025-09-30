# 🦊 Guide de Migration vers GitLab pour VIRIDA

## 🎯 Pourquoi GitLab ?

GitLab est un excellent choix pour VIRIDA car il offre :

- ✅ **CI/CD intégré** - Plus besoin de Gitea + Drone
- ✅ **GitLab Runners** - Plus simple à gérer
- ✅ **Container Registry** - Stockage d'images Docker
- ✅ **Pages** - Documentation automatique
- ✅ **Security** - Scan de vulnérabilités
- ✅ **Monitoring** - Métriques intégrées

## 📋 Fichiers Créés

### Configuration GitLab CI
- `.gitlab-ci.yml` - Pipeline principal
- `Dockerfile.gitlab-runner` - Image GitLab Runner
- `scripts/start-gitlab-runner.sh` - Script de démarrage
- `scripts/deploy-gitlab-runner.sh` - Script de déploiement
- `clevercloud-gitlab-runner.json` - Configuration Clever Cloud

## 🚀 Étapes de Migration

### 1. **Créer un projet GitLab**

1. Allez sur https://gitlab.com
2. Créez un nouveau projet "VIRIDA"
3. Importez votre code depuis GitHub/Gitea

### 2. **Configurer les variables GitLab**

Dans GitLab > Settings > CI/CD > Variables, ajoutez :

```bash
# Clever Cloud
CLEVER_TOKEN=your_clever_token
CLEVER_SECRET=your_clever_secret
CLEVER_DEPLOY_URL=your_deploy_url

# Monitoring
MONITORING_URL=your_monitoring_url
MONITORING_TOKEN=your_monitoring_token

# Notifications
SLACK_WEBHOOK_URL=your_slack_webhook
```

### 3. **Déployer GitLab Runner sur Clever Cloud**

```bash
# Configurer les credentials
export CLEVER_TOKEN="votre_token"
export CLEVER_SECRET="votre_secret"
export GITLAB_TOKEN="votre_token_gitlab"

# Déployer
./scripts/deploy-gitlab-runner.sh
```

### 4. **Configurer le Runner dans GitLab**

1. Allez dans GitLab > Settings > CI/CD > Runners
2. Ajoutez le runner avec l'URL de votre instance Clever Cloud
3. Utilisez le token généré

## 🔄 Comparaison Drone vs GitLab CI

| Fonctionnalité | Drone | GitLab CI |
|----------------|-------|-----------|
| Configuration | YAML séparé | `.gitlab-ci.yml` |
| Runners | Gitea Runners | GitLab Runners |
| Registry | Externe | Intégré |
| Security | Plugin | Intégré |
| Monitoring | Externe | Intégré |
| Pages | Non | Oui |

## 📊 Pipeline GitLab CI

### Stages
1. **validate** - Validation du code
2. **test** - Tests unitaires
3. **build** - Construction des applications
4. **security** - Scan de sécurité
5. **deploy-staging** - Déploiement staging
6. **test-staging** - Tests d'intégration
7. **deploy-production** - Déploiement production
8. **test-production** - Tests de production
9. **monitor** - Configuration monitoring

### Jobs Principaux

#### Frontend 3D
- Tests Node.js
- Build production
- Déploiement Clever Cloud

#### AI/ML
- Tests Python
- Build avec Gunicorn
- Déploiement Clever Cloud

#### Go App
- Tests Go
- Build binaire
- Déploiement Clever Cloud

## 🔧 Configuration Avancée

### Variables d'Environnement

Toutes vos variables Clever Cloud sont déjà configurées :

```bash
# Bucket
BUCKET_FTP_PASSWORD=Odny785DsL9LYBZc
BUCKET_FTP_USERNAME=ua9e0425888f
BUCKET_HOST=bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com

# PostgreSQL
POSTGRESQL_ADDON_HOST=bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com
POSTGRESQL_ADDON_DB=bjduvaldxkbwljy3uuel
POSTGRESQL_ADDON_USER=uncer3i7fyqs2zeult6r
POSTGRESQL_ADDON_PORT=50013
POSTGRESQL_ADDON_PASSWORD=WuobPl6Nyk9X0Z4DKF7BlxE55z2buu
```

### Services

- PostgreSQL 15
- Redis 7
- Docker-in-Docker

### Cache

- Node.js modules
- Python packages
- Go modules

## 🚀 Déploiement

### Staging
- Déclenché sur branche `staging`
- Tests d'intégration
- Tests de performance

### Production
- Déclenché sur branche `main`
- Tests de santé
- Monitoring automatique
- Notifications Slack

## 📈 Avantages de la Migration

1. **Simplicité** - Un seul outil pour tout
2. **Intégration** - Tout est connecté
3. **Sécurité** - Scan automatique
4. **Performance** - Cache optimisé
5. **Monitoring** - Métriques intégrées
6. **Documentation** - Pages automatiques

## 🔍 Monitoring

### Métriques Disponibles
- Temps de build
- Taux de succès
- Performance des tests
- Temps de déploiement

### Alertes
- Échec de build
- Échec de déploiement
- Performance dégradée
- Sécurité compromise

## 📞 Support

### Documentation
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [GitLab Runners](https://docs.gitlab.com/runner/)
- [Clever Cloud](https://www.clever-cloud.com/doc/)

### Commandes Utiles

```bash
# Vérifier le statut du runner
clever status --alias virida-gitlab-runner

# Voir les logs
clever logs --alias virida-gitlab-runner

# Redéployer
clever deploy --alias virida-gitlab-runner
```

## 🎉 Résultat Final

Après migration, vous aurez :

- ✅ Pipeline CI/CD complet
- ✅ GitLab Runner sur Clever Cloud
- ✅ Toutes vos variables configurées
- ✅ Monitoring intégré
- ✅ Notifications automatiques
- ✅ Documentation automatique

**Votre pipeline VIRIDA sera plus robuste, plus simple et plus performant !** 🚀



