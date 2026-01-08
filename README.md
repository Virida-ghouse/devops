# 🚀 VIRIDA - CI/CD Infrastructure avec Gitea Actions

**Infrastructure DevOps moderne avec SonarQube et Clever Cloud**

## 📋 Vue d'Ensemble

VIRIDA est une infrastructure CI/CD complète basée sur **Gitea Actions**, **SonarQube** et déployée sur **Clever Cloud**. Focus exclusif sur l'intégration continue et l'analyse de code.

## 🏗️ Architecture

```
VIRIDA/
├── .gitea/workflows/     # Workflows Gitea Actions
├── scripts/              # Scripts de déploiement CI/CD
├── Dockerfile.gitea-runner  # Runner Gitea Actions
├── Dockerfile.sonarqube     # SonarQube pour analyse
├── clever-entrypoint.sh     # Script Clever Cloud
└── *.json                  # Configurations Clever Cloud
```

## 🚀 Démarrage Rapide

### 1. **Configuration du Runner Gitea**
```bash
# Configuration complète
./scripts/configure-gitea-complete.sh
```

### 2. **Déploiement SonarQube**
```bash
# Déployer SonarQube sur Clever Cloud
./scripts/deploy-sonarqube.sh
```

### 3. **Test du Pipeline**
```bash
# Tester la configuration
./scripts/test-pipeline-gitea.sh
```

## 🔧 Pipeline CI/CD

### **8 Stages Automatisés**
1. **validate** - Validation du code et YAML
2. **test** - Tests des scripts CI/CD
3. **build** - Construction de l'infrastructure
4. **security** - Scan de sécurité (Trivy)
5. **sonarqube** - Analyse de code avec SonarQube
6. **deploy-staging** - Déploiement staging
7. **deploy-production** - Déploiement production
8. **notify** - Notifications des résultats

### **Composants CI/CD**
- **Gitea Actions** : Orchestration des pipelines
- **SonarQube** : Analyse de code et qualité
- **Trivy** : Scan de sécurité
- **Clever Cloud** : Plateforme de déploiement

## 📊 Fonctionnalités

### ✅ **CI/CD Automatisé**
- Pipelines Gitea Actions complets
- Déploiements automatiques vers Clever Cloud
- Tests et validation automatiques
- Rollback automatique

### ✅ **Analyse de Code**
- SonarQube intégré pour l'analyse de qualité
- Scan de sécurité avec Trivy
- Métriques de couverture de code
- Détection des vulnérabilités

### ✅ **Monitoring**
- Health checks automatiques
- Logs centralisés
- Alertes et notifications
- Métriques de performance

### ✅ **Sécurité**
- Scan des vulnérabilités (Trivy)
- Gestion des secrets chiffrés
- Isolation des tâches
- Audit trail complet

## 🛠️ Scripts Disponibles

| Script | Description |
|--------|-------------|
| `configure-gitea-complete.sh` | Configuration complète du runner |
| `configure-gitea-runner-manual.sh` | Configuration manuelle du runner |
| `setup-gitea-runner.sh` | Installation du runner |
| `start-gitea-runner.sh` | Démarrage du runner |
| `test-pipeline-gitea.sh` | Test du pipeline |
| `deploy-sonarqube.sh` | Déploiement SonarQube |

## 📚 Documentation

- **DEVOPS-VIRIDA.md** - Documentation DevOps complète
- **RAPPORT-PROJET-VIRIDA.md** - Rapport de projet détaillé

## 🌐 URLs

- **Repository Gitea** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida
- **Actions** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/actions
- **Settings** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/settings

## 🎯 Prochaines Étapes

1. **Configurer le runner** Gitea
2. **Déployer SonarQube** sur Clever Cloud
3. **Ajouter les secrets** (CLEVER_TOKEN, CLEVER_SECRET, SONAR_TOKEN, SONAR_HOST_URL)
4. **Tester le pipeline** avec un commit

## 🆘 Support

```bash
# Test complet
./scripts/test-pipeline-gitea.sh

# Configuration manuelle
./scripts/configure-gitea-runner-manual.sh

# Déploiement SonarQube
./scripts/deploy-sonarqube.sh
```

---

**VIRIDA - Infrastructure CI/CD Moderne avec Gitea Actions et SonarQube** 🚀