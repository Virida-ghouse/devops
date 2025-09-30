# 🚀 VIRIDA - CI/CD avec Gitea Actions

**Plateforme IoT/IA avec infrastructure DevOps moderne**

## 📋 Vue d'Ensemble

VIRIDA est une plateforme complète de développement IoT/IA avec une infrastructure DevOps automatisée basée sur **Gitea Actions** et déployée sur **Clever Cloud**.

## 🏗️ Architecture

```
VIRIDA/
├── .gitea/workflows/     # Workflows Gitea Actions
├── apps/                 # Applications
│   ├── frontend-3d/      # Interface 3D (Node.js)
│   ├── ai-ml/           # Intelligence Artificielle (Python)
│   └── gitea-drone-ci/  # Services Go
├── scripts/             # Scripts de déploiement
└── docs/               # Documentation
```

## 🚀 Démarrage Rapide

### 1. **Upload du Code**
```bash
# Afficher les instructions d'upload
./scripts/upload-to-gitea.sh
```

### 2. **Configuration du Runner**
```bash
# Configuration complète
./scripts/configure-gitea-complete.sh
```

### 3. **Test du Pipeline**
```bash
# Tester la configuration
./scripts/test-pipeline-gitea.sh
```

## 🔧 Pipeline CI/CD

### **9 Stages Automatisés**
1. **validate** - Validation du code et YAML
2. **test** - Tests unitaires (Frontend, AI/ML, Go)
3. **build** - Construction des applications
4. **security** - Scan de sécurité (Trivy)
5. **deploy-staging** - Déploiement staging
6. **test-staging** - Tests d'intégration
7. **deploy-production** - Déploiement production
8. **test-production** - Tests de production
9. **monitor** - Monitoring et alertes

### **Applications Supportées**
- **Frontend 3D** : Node.js 18 + React + Three.js
- **AI/ML** : Python 3.11 + Flask + Gunicorn
- **Go Services** : Go 1.21 + PostgreSQL

## 📊 Fonctionnalités

### ✅ **CI/CD Automatisé**
- Déploiements automatiques vers Clever Cloud
- Tests unitaires et d'intégration
- Scan de sécurité intégré
- Rollback automatique

### ✅ **Monitoring**
- Health checks automatiques
- Logs centralisés
- Alertes Slack (optionnel)
- Métriques de performance

### ✅ **Sécurité**
- Scan des vulnérabilités (Trivy)
- Gestion des secrets chiffrés
- Isolation des tâches
- Audit trail complet

## 🛠️ Scripts Disponibles

| Script | Description |
|--------|-------------|
| `upload-to-gitea.sh` | Instructions d'upload vers Gitea |
| `configure-gitea-complete.sh` | Configuration complète |
| `setup-gitea-runner.sh` | Installation du runner |
| `start-gitea-runner.sh` | Démarrage du runner |
| `test-pipeline-gitea.sh` | Test du pipeline |
| `generate-pdf-analysis.sh` | Génération PDF d'analyse |

## 📚 Documentation

- **ANALYSE-COMPARATIVE-CI-CD-VIRIDA.md** - Analyse détaillée des solutions CI/CD
- **RESUME-EXECUTIF-CI-CD-VIRIDA.md** - Résumé exécutif pour présentation
- **GUIDE-DEPLOIEMENT-FINAL.md** - Guide de déploiement complet
- **GUIDE-UPLOAD-MANUEL.md** - Instructions d'upload manuel

## 🌐 URLs

- **Repository Gitea** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida
- **Actions** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/actions
- **Settings** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/settings

## 🎯 Prochaines Étapes

1. **Uploader le code** vers Gitea
2. **Configurer le runner** Gitea
3. **Ajouter les secrets** (CLEVER_TOKEN, CLEVER_SECRET)
4. **Tester le pipeline** avec un commit

## 🆘 Support

```bash
# Test complet
./scripts/test-pipeline-gitea.sh

# Configuration manuelle
./scripts/configure-gitea-runner-manual.sh

# Upload du code
./scripts/upload-to-gitea.sh
```

---

**VIRIDA - Infrastructure DevOps Moderne avec Gitea Actions** 🚀