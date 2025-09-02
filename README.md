# 🚀 VIRIDA - Infrastructure DevOps Complète

## 📋 Vue d'Ensemble

VIRIDA est une plateforme complète de gestion de données IoT avec intelligence artificielle, conteneurisée et déployée sur Clever Cloud.

### 🏗️ Architecture

**Approche : Mono-repo avec Modules**
```
virida/
├── 🎨 frontend/          # Interfaces utilisateur
├── ⚡ backend/           # Services backend
├── 🤖 ai-ml/            # Intelligence artificielle
├── 🌐 iot/              # Internet des objets
├── 🏗️ infrastructure/   # DevOps et déploiement
└── 📚 docs/             # Documentation
```

## 🚀 Démarrage Rapide

### 1. Installation
```bash
# Cloner le projet
git clone <repository-url>
cd VIRIDA

# Installer les dépendances
make install

# Démarrage rapide développement
make quick-dev
```

### 2. Commandes Principales
```bash
# Développement
make dev              # Déployer l'environnement de développement
make dev-logs         # Voir les logs
make dev-status       # Statut des services

# Staging
make staging          # Déployer en staging
make staging-logs     # Voir les logs staging

# Production
make prod             # Déployer en production
make prod-logs        # Voir les logs production

# Maintenance
make clean            # Nettoyer les ressources
make status           # Statut de tous les environnements
```

## 🏢 Organisations Gitea

| Organisation | Description | Équipes |
|--------------|-------------|---------|
| **virida-frontend** | Interface utilisateur | 3d-visualizer, dashboard, mobile |
| **virida-backend** | Services backend | api-gateway, auth, user, business |
| **virida-ai-ml** | Intelligence artificielle | prediction, eve, models |
| **virida-iot** | Internet des objets | sensor, mqtt, device |
| **virida-infrastructure** | DevOps | docker, k8s, monitoring, ci-cd |

## 🐳 Services Docker

### Frontend
- **3D Visualizer** : Interface 3D (React + Three.js)
- **Dashboard** : Tableaux de bord utilisateur

### Backend
- **API Gateway** : Point d'entrée API
- **Auth Service** : Authentification et autorisation

### AI/ML
- **Prediction Engine** : Moteur de prédiction IA
- **Eve Assistant** : Assistant intelligent

### IoT
- **Sensor Collector** : Collecte de données capteurs
- **MQTT Broker** : Communication IoT

## 🌍 Environnements

### 🚀 Développement
- **Ports** : 3000-9000
- **Hot-reload** : Activé
- **Logs** : Détaillés
- **Base de données** : PostgreSQL local

### 🎭 Staging
- **Images** : Tag `:staging`
- **Ressources** : Limitées
- **Monitoring** : Activé
- **Tests** : Automatisés

### 🏭 Production
- **Images** : Tag `:latest`
- **Réplicas** : Haute disponibilité
- **Sécurité** : Renforcée
- **Monitoring** : Complet

## 📊 Monitoring

- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3002
- **Logs** : `make logs`

## 🔧 Configuration

### Variables d'Environnement
```bash
# Copier les fichiers d'exemple
cp infrastructure/docker/env.dev.example .env.dev
cp infrastructure/docker/env.staging.example .env.staging
cp infrastructure/docker/env.prod.example .env.prod

# Éditer selon vos besoins
nano .env.dev
```

### Secrets Gitea
```bash
# Générer les secrets
./get-clever-cloud-token.sh

# Configurer dans Gitea
# Voir GUIDE-CONFIGURATION-SECRETS.md
```

## 🧪 Tests

```bash
# Tests unitaires
make test

# Linting
make lint

# Scans de sécurité
make security-scan
```

## 📚 Documentation

- **Architecture** : `docs/architecture/`
- **API** : `docs/api/`
- **Déploiement** : `docs/deployment/`
- **CI/CD** : `README-CI-CD.md`

## 🆘 Support

### Problèmes Courants
```bash
# Services ne démarrent pas
make clean && make dev

# Ports occupés
make dev-stop && make dev

# Images corrompues
make clean && make build
```

### Logs et Debug
```bash
# Logs détaillés
make dev-logs

# Statut des services
make dev-status

# Monitoring
make monitor
```

## 🎯 Roadmap

### ✅ Complété (DEVOPS-001)
- [x] Architecture mono-repo avec modules
- [x] Organisations Gitea
- [x] Dockerfiles optimisés
- [x] Environnements dev/staging/prod
- [x] Scripts de déploiement
- [x] CI/CD Gitea Actions

### 🚧 En Cours (DEVOPS-002)
- [ ] Registry Docker privé
- [ ] Optimisation des builds
- [ ] Scans de sécurité avancés

### 📋 À Venir
- [ ] Kubernetes et ArgoCD
- [ ] Monitoring Prometheus-Grafana
- [ ] Logging centralisé EFK
- [ ] Sécurité renforcée
- [ ] Sauvegardes automatisées

---

**🏆 VIRIDA - Infrastructure DevOps Complète et Modulaire**
