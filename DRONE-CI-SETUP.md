# 🚁 Configuration Drone CI pour VIRIDA

## 📋 Prérequis

1. **Repository Gitea** : https://gitea.com/Virida/devops.git
2. **Clever Cloud** : Compte avec applications configurées
3. **Drone CI** : Instance configurée et connectée à Gitea

## 🔧 Configuration Drone CI

### 1. Variables d'Environnement Requises

Dans l'interface Drone CI, configurez ces secrets :

#### Clever Cloud
```bash
clever_cloud_token=your_clever_cloud_token
clever_cloud_secret=your_clever_cloud_secret
```

#### Base de Données
```bash
cc_postgresql_addon_host=your_postgres_host
cc_postgresql_addon_db=your_postgres_database
cc_postgresql_addon_user=your_postgres_user
cc_postgresql_addon_password=your_postgres_password
```

#### Applications
```bash
grafana_admin_password=your_grafana_password
jwt_secret=your_jwt_secret
cc_acme_email=your_email@domain.com
cc_app_domain=your_app_domain.cleverapps.io
```

#### Notifications (Optionnel)
```bash
slack_webhook=your_slack_webhook_url
```

### 2. Configuration du Repository

1. **Activer Drone CI** sur le repository Gitea
2. **Configurer les webhooks** pour déclencher les builds
3. **Définir les branches** : `main`, `staging`

### 3. Structure des Pipelines

#### Pipeline Principal (`.drone.yml`)
- **Déclenchement** : Push sur `main` ou `staging`
- **Étapes** : Tests, Build, Déploiement
- **Applications** : Frontend 3D, AI/ML

#### Pipeline Staging (`.drone.staging.yml`)
- **Déclenchement** : Push sur `staging`
- **Environnement** : Staging
- **URLs** : `*-staging.cleverapps.io`

#### Pipeline Production (`.drone.production.yml`)
- **Déclenchement** : Push sur `main`
- **Environnement** : Production
- **URLs** : `*.cleverapps.io`

## 🚀 Déploiement

### Déploiement Automatique
Le pipeline se déclenche automatiquement sur :
- **Push vers `staging`** → Déploiement staging
- **Push vers `main`** → Déploiement production
- **Pull requests** → Tests uniquement

### Déploiement Manuel
```bash
# Via le script de déploiement
./scripts/deploy.sh staging
./scripts/deploy.sh production

# Via Drone CLI
drone build start virida/devops staging
drone build start virida/devops main
```

## 🧪 Tests et Validation

### Tests Automatiques
- **Tests unitaires** : Jest (Frontend), pytest (AI/ML)
- **Linting** : ESLint (Frontend), pylint (AI/ML)
- **Tests de sécurité** : Scan automatique
- **Tests d'intégration** : Post-déploiement

### Health Checks
- **Endpoints** : `/health` pour chaque application
- **Performance** : Tests de temps de réponse
- **Disponibilité** : Vérification continue

## 📊 Monitoring

### Notifications
- **Slack** : Succès/échec des déploiements
- **Email** : Alertes critiques
- **Logs** : Centralisés dans Drone CI

### Métriques
- **Temps de build** : Suivi des performances
- **Taux de succès** : Statistiques de déploiement
- **Temps de déploiement** : Optimisation continue

## 🔄 Gestion des Erreurs

### Rollback Automatique
- **Détection d'échec** : Health checks échoués
- **Rollback immédiat** : Retour à la version précédente
- **Notification** : Alerte automatique

### Blue-Green Deployment
- **Déploiement sans interruption** : Basculement instantané
- **Tests de validation** : Vérification avant basculement
- **Rollback rapide** : Retour en cas de problème

## 📝 Notes Importantes

### Applications Désactivées
- **Gitea/Drone CI** : Environnement non fonctionnel
- **Base de données Gitea** : Disponible sur Clever Cloud
- **Pipeline adapté** : Focus sur les applications fonctionnelles

### Applications Actives
- **Frontend 3D** : Application Node.js/Express
- **AI/ML** : Application Python/Flask

## 🎯 Prochaines Étapes

1. **Configurer Drone CI** avec les variables d'environnement
2. **Tester le pipeline** sur une branche staging
3. **Valider les déploiements** automatiques
4. **Configurer les notifications** Slack
5. **Mettre en place le monitoring** avancé

## 🔗 Liens Utiles

- **Repository** : https://gitea.com/Virida/devops.git
- **Drone CI** : https://drone.virida.com
- **Clever Cloud** : https://console.clever-cloud.com
- **Documentation** : Voir `CI-CD-SUMMARY.md`

---

**Configuration complète** : Pipeline CI/CD adapté aux applications fonctionnelles
**Support** : Documentation et scripts de déploiement inclus
