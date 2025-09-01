# 🐳 VIRIDA Docker Strategy & Containerization Guide

## 📋 Vue d'Ensemble

Ce document décrit la stratégie complète de conteneurisation VIRIDA, incluant l'architecture Docker, les bonnes pratiques, les workflows de développement et les procédures de déploiement.

## 🏗️ Architecture Docker

### **Approche Multi-Stage**

Tous les Dockerfiles VIRIDA utilisent une approche multi-stage pour optimiser la taille des images et améliorer la sécurité :

```dockerfile
# Stage 1: Dependencies
FROM node:18-alpine AS deps
# Installation des dépendances

# Stage 2: Build
FROM node:18-alpine AS builder
# Compilation de l'application

# Stage 3: Production
FROM node:18-alpine AS runner
# Image finale optimisée
```

### **Stages Disponibles**

- **`deps`** : Installation des dépendances
- **`builder`** : Compilation et build
- **`runner`** : Image de production
- **`dev`** : Environnement de développement
- **`gpu-train`** : Training AI/ML avec GPU (si applicable)

## 🎯 Services Conteneurisés

### **Frontend Services**

| Service | Port | Image | Description |
|---------|------|-------|-------------|
| 3D Visualizer | 3001 | `virida-3d-visualizer` | Visualisation 3D interactive |
| Dashboard | 3002 | `virida-dashboard` | Tableaux de bord métier |

### **Backend Services**

| Service | Port | Image | Description |
|---------|------|-------|-------------|
| API Gateway | 3000 | `virida-api-gateway` | Routage et authentification |
| User Service | 3004 | `virida-user-service` | Gestion des utilisateurs |

### **AI/ML Services**

| Service | Port | Image | Description |
|---------|------|-------|-------------|
| Prediction Engine | 8000 | `virida-prediction-engine` | Moteur de prédiction AI |

### **Infrastructure Services**

| Service | Port | Image | Description |
|---------|------|-------|-------------|
| PostgreSQL | 5432 | `postgres:15-alpine` | Base de données principale |
| Redis | 6379 | `redis:7-alpine` | Cache et session store |
| Prometheus | 9090 | `prom/prometheus` | Collecte de métriques |
| Grafana | 3003 | `grafana/grafana` | Visualisation et dashboards |

## 🚀 Workflow de Développement

### **1. Démarrage Rapide**

```bash
# Démarrer tous les services
make up

# Démarrer par catégorie
make up-frontend
make up-backend
make up-ai-ml
make up-infrastructure
```

### **2. Construction des Images**

```bash
# Construire tous les services
make build

# Construire par catégorie
make build-frontend
make build-backend
make build-ai-ml

# Construction avec Docker Compose
make build-compose
```

### **3. Scripts d'Automatisation**

```bash
# Script de build avancé
./scripts/docker-build.sh --target prod --push

# Scan de sécurité
./scripts/docker-security-scan.sh --fail-on-critical
```

## 🔧 Configuration Docker Compose

### **Environnement de Développement**

Le fichier `docker-compose.dev.yml` configure l'environnement de développement avec :

- **Volumes montés** pour le hot-reload
- **Variables d'environnement** de développement
- **Réseaux isolés** pour la communication inter-services
- **Health checks** pour la surveillance
- **Profils** pour le démarrage sélectif

### **Profils Disponibles**

```bash
# Démarrer uniquement les services frontend
docker-compose --profile frontend up -d

# Démarrer uniquement les services backend
docker-compose --profile backend up -d

# Démarrer uniquement les services AI/ML
docker-compose --profile ai-ml up -d

# Démarrer uniquement l'infrastructure
docker-compose --profile infrastructure up -d

# Démarrer uniquement le monitoring
docker-compose --profile monitoring up -d

# Démarrer uniquement les outils
docker-compose --profile tools up -d
```

## 🐳 Registry Docker Privé

### **Configuration**

Le registry Docker privé est configuré via `docker-compose.registry.yml` :

- **Registry Docker v2** : Stockage des images
- **Interface Web** : Gestion visuelle des images
- **Nginx** : Reverse proxy avec authentification
- **SSL/TLS** : Communication sécurisée

### **Utilisation**

```bash
# Démarrer le registry
docker-compose -f docker-compose.registry.yml up -d

# Tagger une image pour le registry
docker tag virida-api-gateway:latest registry.virida.local:5000/virida-api-gateway:latest

# Pousser une image
docker push registry.virida.local:5000/virida-api-gateway:latest

# Tirer une image
docker pull registry.virida.local:5000/virida-api-gateway:latest
```

## 🔒 Sécurité Docker

### **Bonnes Pratiques Implémentées**

1. **Images de Base Minimales** : Alpine Linux pour Node.js, slim pour Python
2. **Utilisateurs Non-Root** : Création d'utilisateurs dédiés
3. **Multi-Stage Builds** : Réduction de la surface d'attaque
4. **Health Checks** : Surveillance de l'état des services
5. **Scans de Vulnérabilités** : Intégration Trivy automatisée

### **Scan de Sécurité**

```bash
# Scan complet de toutes les images
./scripts/docker-security-scan.sh

# Scan des images frontend uniquement
./scripts/docker-security-scan.sh frontend

# Scan avec rapport JSON
./scripts/docker-security-scan.sh --format json

# Scan strict (échec sur vulnérabilités critiques)
./scripts/docker-security-scan.sh --fail-on-critical
```

## 📊 Monitoring et Observabilité

### **Métriques Collectées**

- **Prometheus** : Métriques système et applicatives
- **Grafana** : Dashboards et visualisations
- **Health Checks** : État des services en temps réel
- **Logs Centralisés** : Agrégation des logs Docker

### **Dashboards Disponibles**

- **Services Overview** : Vue d'ensemble de tous les services
- **Performance Metrics** : Métriques de performance
- **Security Alerts** : Alertes de sécurité
- **Resource Usage** : Utilisation des ressources

## 🛠️ Outils et Scripts

### **Makefile Principal**

Le `Makefile` fournit des commandes standardisées :

```bash
# Aide
make help

# Gestion des services
make up, down, restart, logs

# Tests et qualité
make test, lint, format

# Shell dans les conteneurs
make shell, shell-frontend, shell-backend
```

### **Scripts d'Automatisation**

- **`docker-build.sh`** : Construction automatisée des images
- **`docker-security-scan.sh`** : Scan de sécurité automatisé
- **`setup-gitea-virida.sh`** : Configuration Gitea

## 📈 Optimisations de Performance

### **Stratégies de Cache**

1. **Cache Docker Layer** : Réutilisation des couches entre builds
2. **Cache Registry** : Cache depuis le registry privé
3. **Cache Dependencies** : Cache des dépendances dans les stages

### **Optimisations d'Images**

1. **Multi-Architecture** : Support ARM64 et AMD64
2. **Compression** : Images optimisées en taille
3. **Security Scanning** : Intégration continue des scans

## 🔄 CI/CD Integration

### **Pipelines Supportés**

- **Drone CI** : Intégration native avec Gitea
- **Woodpecker CI** : Alternative moderne à Drone
- **GitHub Actions** : Support pour les repositories externes

### **Stages CI/CD**

1. **Build** : Construction des images Docker
2. **Test** : Tests automatisés dans les conteneurs
3. **Security Scan** : Scan de vulnérabilités
4. **Push** : Poussée vers le registry
5. **Deploy** : Déploiement automatique

## 🚨 Troubleshooting

### **Problèmes Courants**

#### **Ports Occupés**
```bash
# Vérifier les ports utilisés
lsof -i :3000

# Arrêter les services
make down
```

#### **Images Corrompues**
```bash
# Nettoyer les images
make clean-images

# Reconstruire
make build
```

#### **Volumes Corrompus**
```bash
# Nettoyer les volumes
make clean-volumes

# Redémarrer
make up
```

### **Logs et Debug**

```bash
# Logs de tous les services
make logs

# Logs d'un service spécifique
make logs-frontend

# Shell dans un conteneur
make shell-backend
```

## 📚 Ressources et Références

### **Documentation Officielle**

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Trivy Security Scanner](https://aquasecurity.github.io/trivy/)

### **Bonnes Pratiques**

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Security Best Practices](https://docs.docker.com/engine/security/)
- [Multi-Stage Builds](https://docs.docker.com/develop/dev-best-practices/multistage-builds/)

### **Outils Recommandés**

- **Trivy** : Scan de vulnérabilités
- **Hadolint** : Linting des Dockerfiles
- **Dive** : Analyse des couches Docker
- **Docker Bench Security** : Audit de sécurité

## 🔮 Roadmap et Évolutions

### **Phase 1 (Sprint 1-2) - Actuel**
- [x] Dockerfiles multi-stage optimisés
- [x] Environnement de développement local
- [x] Registry Docker privé
- [x] Scripts d'automatisation
- [x] Scans de sécurité

### **Phase 2 (Sprint 3-4)**
- [ ] Intégration Kubernetes
- [ ] Orchestration multi-environnement
- [ ] Monitoring avancé
- [ ] Backup et restauration

### **Phase 3 (Sprint 5-6)**
- [ ] Auto-scaling
- [ ] Disaster recovery
- [ ] Performance tuning
- [ ] Documentation avancée

---

## 📞 Support et Contact

Pour toute question ou problème lié à la conteneurisation VIRIDA :

- **Équipe DevOps** : devops@virida.com
- **Documentation** : docs.virida.local
- **Issues** : Gitea Issues
- **Wiki** : Gitea Wiki

---

*Dernière mise à jour : $(date)*
*Version : 1.0.0*

