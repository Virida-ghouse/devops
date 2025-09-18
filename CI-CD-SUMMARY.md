# 🚀 Pipeline CI/CD VIRIDA - Résumé de Configuration

## 📋 État Actuel

### ✅ Applications Fonctionnelles
- **Frontend 3D** : `apps/frontend-3d/` - Application Node.js/Express
- **AI/ML** : `apps/ai-ml/` - Application Python/Flask
- **Base de données Gitea** : Disponible sur Clever Cloud (environnement non fonctionnel)

### ❌ Applications Désactivées
- **Gitea/Drone CI** : Environnement non fonctionnel, seule la base de données est disponible

## 🔧 Configuration Drone CI

### Fichiers de Configuration
- `.drone.yml` - Pipeline principal (tous environnements)
- `.drone.staging.yml` - Pipeline spécifique staging
- `.drone.production.yml` - Pipeline spécifique production

### Étapes du Pipeline

#### 1. 🧪 Tests et Validation
- Tests unitaires pour Frontend 3D (Jest)
- Tests unitaires pour AI/ML (pytest)
- Linting et formatage de code
- Scan de sécurité

#### 2. 🏗️ Build
- Build Frontend 3D (npm run build)
- Build AI/ML (Python avec requirements.txt)
- Build Docker (si Dockerfile présent)

#### 3. 🚀 Déploiement
- **Staging** : `virida-frontend-3d-staging`, `virida-ai-ml-staging`
- **Production** : `virida-frontend-3d`, `virida-ai-ml`

#### 4. 🧪 Tests Post-Déploiement
- Health checks automatiques
- Tests de performance
- Tests d'intégration

## 🌐 URLs de Déploiement

### Staging
- Frontend 3D : https://virida-frontend-3d-staging.cleverapps.io
- AI/ML : https://virida-ai-ml-staging.cleverapps.io

### Production
- Frontend 3D : https://virida-frontend-3d.cleverapps.io
- AI/ML : https://virida-ai-ml.cleverapps.io

## 🔐 Variables d'Environnement Requises

### Clever Cloud
```bash
CLEVER_CLOUD_TOKEN=your_token
CLEVER_CLOUD_SECRET=your_secret
```

### Base de Données
```bash
CC_POSTGRESQL_ADDON_HOST=your_db_host
CC_POSTGRESQL_ADDON_DB=your_db_name
CC_POSTGRESQL_ADDON_USER=your_db_user
CC_POSTGRESQL_ADDON_PASSWORD=your_db_password
```

### Applications
```bash
GRAFANA_ADMIN_PASSWORD=your_grafana_password
JWT_SECRET=your_jwt_secret
CC_ACME_EMAIL=your_email
```

## 🚀 Scripts de Déploiement

### Déploiement Manuel
```bash
# Staging
./scripts/deploy.sh staging

# Production
./scripts/deploy.sh production
```

### Déploiement Automatique
Le pipeline Drone CI se déclenche automatiquement sur :
- Push vers `staging` → Déploiement staging
- Push vers `main` → Déploiement production
- Pull requests → Tests uniquement

## 📊 Monitoring et Notifications

### Slack
- Notifications de succès/échec
- Rapport de déploiement
- Alertes de performance

### Health Checks
- Endpoints `/health` pour chaque application
- Tests de performance automatiques
- Monitoring de la disponibilité

## 🔄 Gestion des Erreurs

### Rollback Automatique
- En cas d'échec de déploiement
- Retour à la version précédente
- Notification d'alerte

### Blue-Green Deployment
- Déploiement sans interruption
- Basculement instantané
- Tests de validation

## 📝 Notes Importantes

1. **Gitea/Drone CI** : L'environnement ne fonctionne pas, seule la base de données est disponible
2. **Base de données Gitea** : Accessible via Clever Cloud pour les données
3. **Pipeline adapté** : Toutes les références à Gitea/Drone ont été désactivées
4. **Focus sur les applications fonctionnelles** : Frontend 3D et AI/ML

## 🎯 Prochaines Étapes

1. Configurer les variables d'environnement dans Drone CI
2. Tester le pipeline sur une branche staging
3. Valider les déploiements automatiques
4. Configurer les notifications Slack
5. Mettre en place le monitoring avancé

---

**Repository Gitea** : https://gitea.com/Virida/devops.git
**Configuration Drone CI** : Complète et adaptée aux applications fonctionnelles
