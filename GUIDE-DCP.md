# 🚀 GUIDE DCP - Deploy Complete Pipeline VIRIDA

## 📋 Qu'est-ce que DCP ?

**DCP (Deploy Complete Pipeline)** est un script de déploiement complet qui déploie toute l'infrastructure DevOps VIRIDA en une seule commande sur Clever Cloud.

## 🎯 Fonctionnalités

- ✅ **Déploiement automatique** de 3 applications
- ✅ **Configuration complète** des variables d'environnement
- ✅ **GitLab Runner** déployé sur Clever Cloud
- ✅ **Monitoring intégré** avec dashboard
- ✅ **Sécurité** et gestion des secrets
- ✅ **Tests automatiques** de l'infrastructure

## 🚀 Utilisation Rapide

### 1. **Configuration des credentials**

```bash
# Obtenez vos credentials sur https://console.clever-cloud.com
export CLEVER_TOKEN="votre_token_clever"
export CLEVER_SECRET="votre_secret_clever"
export GITLAB_TOKEN="votre_token_gitlab"
```

### 2. **Test de la configuration**

```bash
./scripts/test-dcp.sh
```

### 3. **Déploiement complet**

```bash
./scripts/dcp.sh
```

### 4. **Dashboard de monitoring**

```bash
./scripts/devops-dashboard.sh
```

## 📊 Applications Déployées

| Application | Type | Port | URL |
|-------------|------|------|-----|
| Frontend 3D | Node.js | 3000 | https://virida-frontend-3d.cleverapps.io |
| AI/ML | Python | 8000 | https://virida-ai-ml.cleverapps.io |
| GitLab Runner | Ubuntu | 8080 | https://virida-gitlab-runner.cleverapps.io |

## 🔧 Configuration Automatique

### Variables d'Environnement Configurées

#### Bucket (Clever Cloud)
```bash
BUCKET_FTP_PASSWORD=Odny785DsL9LYBZc
BUCKET_FTP_USERNAME=ua9e0425888f
BUCKET_HOST=bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com
```

#### PostgreSQL (Clever Cloud)
```bash
POSTGRESQL_ADDON_HOST=bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com
POSTGRESQL_ADDON_DB=bjduvaldxkbwljy3uuel
POSTGRESQL_ADDON_USER=uncer3i7fyqs2zeult6r
POSTGRESQL_ADDON_PORT=50013
POSTGRESQL_ADDON_PASSWORD=WuobPl6Nyk9X0Z4DKF7BlxE55z2buu
```

#### GitLab Runner
```bash
GITLAB_URL=https://gitlab.com/virida/
RUNNER_NAME=virida-gitlab-runner
RUNNER_LABELS=ubuntu-latest,docker,clever-cloud
```

## 📋 Scripts Disponibles

### `scripts/dcp.sh`
**Script principal de déploiement complet**
- Déploie toutes les applications
- Configure toutes les variables
- Vérifie les déploiements
- Affiche les URLs et commandes utiles

### `scripts/test-dcp.sh`
**Script de test de la configuration**
- Vérifie les credentials
- Teste la connexion Clever Cloud
- Vérifie les fichiers nécessaires
- Valide les permissions

### `scripts/devops-dashboard.sh`
**Dashboard de monitoring en temps réel**
- Statut des applications
- Métriques système
- Logs récents
- Alertes et notifications

### `scripts/deploy-devops-complete.sh`
**Script de déploiement détaillé**
- Déploiement étape par étape
- Configuration avancée
- Monitoring et alertes
- Documentation complète

## 🔍 Vérification du Déploiement

### Commandes Clever Cloud

```bash
# Vérifier le statut de toutes les applications
clever status

# Voir les logs d'une application
clever logs --alias virida-frontend-3d
clever logs --alias virida-ai-ml
clever logs --alias virida-gitlab-runner

# Voir les variables d'environnement
clever env --alias virida-frontend-3d

# Redéployer une application
clever deploy --alias virida-frontend-3d
```

### Tests de Connectivité

```bash
# Test Frontend 3D
curl -f https://virida-frontend-3d.cleverapps.io/health

# Test AI/ML
curl -f https://virida-ai-ml.cleverapps.io/health

# Test GitLab Runner
curl -f https://virida-gitlab-runner.cleverapps.io/health
```

## 📊 Monitoring et Alertes

### Dashboard DevOps
Le dashboard affiche en temps réel :
- ✅ Statut des applications
- 📊 Métriques système (CPU, RAM, disque)
- 📋 Logs récents
- 🚨 Alertes et notifications
- 🔧 Menu de contrôle interactif

### Métriques Surveillées
- **Performance** : Temps de réponse < 2s
- **Disponibilité** : 99.9%
- **Ressources** : CPU < 70%, RAM < 80%
- **Erreurs** : Taux d'erreur < 1%

## 🛠️ Dépannage

### Problèmes Courants

#### 1. **Credentials manquants**
```bash
# Vérifier les variables
echo $CLEVER_TOKEN
echo $CLEVER_SECRET
echo $GITLAB_TOKEN

# Les redéfinir si nécessaire
export CLEVER_TOKEN="votre_token"
export CLEVER_SECRET="votre_secret"
export GITLAB_TOKEN="votre_token_gitlab"
```

#### 2. **Connexion Clever Cloud échouée**
```bash
# Tester la connexion
clever status

# Se reconnecter
clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET"
```

#### 3. **Application non accessible**
```bash
# Vérifier le statut
clever status --alias virida-frontend-3d

# Voir les logs
clever logs --alias virida-frontend-3d --lines 50

# Redéployer
clever deploy --alias virida-frontend-3d
```

#### 4. **GitLab Runner non fonctionnel**
```bash
# Vérifier les logs
clever logs --alias virida-gitlab-runner

# Vérifier les variables GitLab
clever env --alias virida-gitlab-runner | grep GITLAB
```

## 📈 Optimisations

### Performance
- **Cache** : Node.js, Python, Go modules
- **Images Docker** : Multi-stage builds
- **Réseau** : CDN Clever Cloud
- **Base de données** : Connection pooling

### Sécurité
- **Secrets** : Variables chiffrées
- **Scan** : Vulnérabilités automatiques
- **TLS** : Chiffrement end-to-end
- **RBAC** : Contrôle d'accès

### Monitoring
- **Métriques** : Temps réel
- **Alertes** : Proactives
- **Logs** : Centralisés
- **Dashboard** : Interactif

## 🎯 Prochaines Étapes

### Immédiat
1. **Déployer l'infrastructure** : `./scripts/dcp.sh`
2. **Tester les applications** : Vérifier les URLs
3. **Configurer GitLab** : Variables et runners
4. **Lancer le dashboard** : `./scripts/devops-dashboard.sh`

### Court Terme
1. **Migrer le code** vers GitLab
2. **Configurer les pipelines** CI/CD
3. **Tester les déploiements** automatiques
4. **Former l'équipe** aux nouveaux outils

### Long Terme
1. **Optimiser les performances** du pipeline
2. **Ajouter des tests** end-to-end
3. **Implémenter le blue-green** deployment
4. **Étendre le monitoring** métier

## 📞 Support

### Documentation
- **Guide DCP** : Ce fichier
- **DevOps VIRIDA** : `DEVOPS-VIRIDA.md`
- **Migration GitLab** : `GITLAB-MIGRATION-GUIDE.md`
- **Rapport Projet** : `RAPPORT-PROJET-VIRIDA.md`

### Commandes d'Aide
```bash
# Aide DCP
./scripts/dcp.sh --help

# Test de configuration
./scripts/test-dcp.sh

# Dashboard interactif
./scripts/devops-dashboard.sh

# Statut Clever Cloud
clever status
```

---

**🚀 DCP - Infrastructure VIRIDA déployée en une commande !**

*Développement rapide, déploiement fiable, monitoring complet !* 🎉



