# 🚁 Configuration Gitea Runner - Pipeline Révolutionnaire

## 🎯 Pourquoi Gitea Runner ?

### ✅ **Avantages Révolutionnaires**
- **Intégration native** : Tout dans Gitea, pas d'outils externes
- **Syntaxe GitHub Actions** : Migration facile des workflows existants
- **Sécurité renforcée** : Isolation des tâches, pas de fuite de données
- **Performance optimisée** : Exécution locale, pas de latence réseau
- **Coût réduit** : Pas de frais d'exécution externes

### 🚀 **Pour VIRIDA**
- **Base de données Gitea disponible** : Intégration parfaite
- **Environnement unifié** : Tout dans Gitea
- **Workflows natifs** : Plus simple à maintenir
- **Sécurité maximale** : Données restent dans votre infrastructure

## 🔧 Installation Gitea Runner

### 1. Prérequis
```bash
# Clever Cloud avec Gitea
- Gitea instance running
- PostgreSQL database available
- Docker support enabled
```

### 2. Installation du Runner
```bash
# Télécharger Gitea Runner
wget https://gitea.com/gitea/act_runner/releases/download/v0.3.0/act_runner-0.3.0-linux-amd64.tar.gz
tar -xzf act_runner-0.3.0-linux-amd64.tar.gz
chmod +x act_runner

# Configurer le runner
./act_runner register \
  --instance https://gitea.com \
  --token YOUR_GITEA_TOKEN \
  --name virida-runner \
  --labels ubuntu-latest:docker://node:18

# Démarrer le runner
./act_runner daemon
```

### 3. Configuration Clever Cloud
```json
{
  "build": {
    "type": "docker",
    "dockerfile": "Dockerfile.runner"
  },
  "deploy": {
    "target": "gitea-runner",
    "command": "./act_runner daemon"
  },
  "environment": {
    "GITEA_INSTANCE_URL": "https://gitea.com",
    "GITEA_TOKEN": "your_gitea_token",
    "RUNNER_NAME": "virida-runner",
    "RUNNER_LABELS": "ubuntu-latest:docker://node:18"
  }
}
```

## 🚀 Workflows Gitea Actions

### 1. Pipeline Principal (`.gitea/workflows/ci-cd.yml`)
- **Déclenchement** : Push sur `main`, `staging`, `develop`
- **Étapes** : Tests, Build, Déploiement
- **Applications** : Frontend 3D, AI/ML
- **Environnements** : Staging, Production

### 2. Validation PR (`.gitea/workflows/pr-validation.yml`)
- **Déclenchement** : Pull requests
- **Étapes** : Tests, Analyse de code, Build
- **Fonctionnalités** : Commentaires automatiques, Rapports de couverture

### 3. Gestion des Releases (`.gitea/workflows/release.yml`)
- **Déclenchement** : Tags de version, Workflow dispatch
- **Étapes** : Préparation, Build, Déploiement, Notification
- **Fonctionnalités** : Changelog automatique, Artifacts

## 🔐 Configuration des Secrets

### Dans Gitea (Settings > Secrets)
```bash
# Clever Cloud
CLEVER_CLOUD_TOKEN=your_clever_cloud_token
CLEVER_CLOUD_SECRET=your_clever_cloud_secret

# Base de données
CC_POSTGRESQL_ADDON_HOST=your_postgres_host
CC_POSTGRESQL_ADDON_DB=your_postgres_database
CC_POSTGRESQL_ADDON_USER=your_postgres_user
CC_POSTGRESQL_ADDON_PASSWORD=your_postgres_password

# Applications
GRAFANA_ADMIN_PASSWORD=your_grafana_password
JWT_SECRET=your_jwt_secret
CC_ACME_EMAIL=your_email@domain.com
CC_APP_DOMAIN=your_app_domain.cleverapps.io

# Notifications
SLACK_WEBHOOK_URL=your_slack_webhook_url
EMAIL_USERNAME=your_email_username
EMAIL_PASSWORD=your_email_password
RELEASE_EMAIL_LIST=team@virida.com
```

## 🏗️ Structure des Workflows

### Pipeline CI/CD
```yaml
name: 🚀 VIRIDA CI/CD Pipeline

on:
  push:
    branches: [ main, staging, develop ]
  pull_request:
    branches: [ main, staging ]

jobs:
  test:
    # Tests et validation
  build:
    # Build et package
  deploy-staging:
    # Déploiement staging
  deploy-production:
    # Déploiement production
  rollback:
    # Rollback automatique
```

### Validation PR
```yaml
name: 🔍 PR Validation & Review

on:
  pull_request:
    branches: [ main, staging ]

jobs:
  pr-validation:
    # Validation des PR
  code-analysis:
    # Analyse de code avancée
  build-validation:
    # Build de validation
  pr-comment:
    # Commentaires automatiques
```

### Gestion des Releases
```yaml
name: 🚀 Release Management

on:
  push:
    tags: [ 'v*' ]
  workflow_dispatch:

jobs:
  prepare-release:
    # Préparation de la release
  build-release:
    # Build de release
  deploy-release:
    # Déploiement de release
  create-release:
    # Création de la release
  notify-release:
    # Notifications
```

## 🚀 Déploiement

### 1. Déploiement Automatique
- **Push vers `staging`** → Déploiement staging
- **Push vers `main`** → Déploiement production
- **Pull requests** → Tests uniquement
- **Tags de version** → Release complète

### 2. Déploiement Manuel
```bash
# Via l'interface Gitea
- Aller dans Actions > Workflows
- Sélectionner le workflow
- Cliquer sur "Run workflow"

# Via l'API Gitea
curl -X POST "https://gitea.com/api/v1/repos/Virida/devops/actions/workflows/ci-cd.yml/dispatches" \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ref":"main"}'
```

## 📊 Monitoring et Notifications

### 1. Notifications Slack
- **Succès/échec** des déploiements
- **Rapports de performance**
- **Alertes de sécurité**

### 2. Notifications Email
- **Releases importantes**
- **Échecs critiques**
- **Rapports hebdomadaires**

### 3. Interface Gitea
- **Historique des workflows**
- **Logs détaillés**
- **Métriques de performance**

## 🔄 Gestion des Erreurs

### 1. Rollback Automatique
- **Détection d'échec** : Health checks échoués
- **Rollback immédiat** : Retour à la version précédente
- **Notification** : Alerte automatique

### 2. Blue-Green Deployment
- **Déploiement sans interruption** : Basculement instantané
- **Tests de validation** : Vérification avant basculement
- **Rollback rapide** : Retour en cas de problème

## 📝 Avantages vs Drone CI

| Fonctionnalité | Gitea Runner | Drone CI |
|----------------|--------------|----------|
| **Intégration** | ✅ Native Gitea | ❌ Externe |
| **Syntaxe** | ✅ GitHub Actions | ❌ YAML custom |
| **Sécurité** | ✅ Isolation native | ⚠️ Configuration |
| **Performance** | ✅ Exécution locale | ⚠️ Latence réseau |
| **Coût** | ✅ Gratuit | ❌ Frais d'exécution |
| **Maintenance** | ✅ Intégré | ❌ Outil séparé |

## 🎯 Prochaines Étapes

1. **Installer Gitea Runner** sur Clever Cloud
2. **Configurer les secrets** dans Gitea
3. **Tester les workflows** sur une branche de test
4. **Migrer les pipelines** existants
5. **Configurer les notifications** Slack/Email

## 🔗 Liens Utiles

- **Repository** : https://gitea.com/Virida/devops
- **Gitea Actions** : https://docs.gitea.com/usage/actions/
- **Gitea Runner** : https://gitea.com/gitea/act_runner
- **Clever Cloud** : https://console.clever-cloud.com

---

**🚀 Pipeline Révolutionnaire** : Gitea Runner + Gitea Actions = CI/CD de nouvelle génération
**💡 Innovation** : Intégration native, sécurité maximale, performance optimisée
