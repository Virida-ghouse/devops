# 🎯 Stratégie Clever Cloud Optimale pour VIRIDA

## 📊 Analyse des Besoins

### Services Métier (Applications Docker)
- **virida-frontend-3d** : Interface 3D React
- **virida-backend-api** : API Gateway Node.js
- **virida-ai-ml** : Moteur IA/ML Python
- **virida-gitea-bridge** : Bridge d'intégration

### Services Système (Applications Linux)
- **virida-prometheus** : Collecte de métriques
- **virida-grafana** : Dashboards de monitoring

### Services Existants (À conserver)
- **gitea** : Git server (Linux)
- **virida_ihm** : Interface web (Node.js)
- **n8n** : Workflow automation (Node.js)
- **PostgreSQL** : Base de données (Add-on)

## 🏗️ Architecture Recommandée

### Phase 1 : Services Métier (Docker)
```bash
# Créer les applications Docker pour les services métier
clever create --type docker --org orga_a7844a87-3356-462b-9e22-ce6c5437b0aa virida-frontend-3d
clever create --type docker --org orga_a7844a87-3356-462b-9e22-ce6c5437b0aa virida-backend-api
clever create --type docker --org orga_a7844a87-3356-462b-9e22-ce6c5437b0aa virida-ai-ml
clever create --type docker --org orga_a7844a87-3356-462b-9e22-ce6c5437b0aa virida-gitea-bridge
```

### Phase 2 : Monitoring (Linux)
```bash
# Créer les applications Linux pour le monitoring
clever create --type linux --org orga_a7844a87-3356-462b-9e22-ce6c5437b0aa virida-prometheus
clever create --type linux --org orga_a7844a87-3356-462b-9e22-ce6c5437b0aa virida-grafana
```

## 💰 Optimisation des Coûts

### Applications Docker (Services Métier)
- **Coût** : ~15-30€/mois par service
- **Avantage** : Isolation, scalabilité, déploiement facile
- **Usage** : Services qui changent souvent

### Applications Linux (Monitoring)
- **Coût** : ~10-20€/mois par service
- **Avantage** : Contrôle total, configuration personnalisée
- **Usage** : Services stables, configuration complexe

### Applications Node.js (Web)
- **Coût** : ~5-15€/mois par service
- **Avantage** : Simple, rapide, intégration native
- **Usage** : Applications web simples

## 🔧 Configuration Recommandée

### Variables d'Environnement Partagées
```bash
# Base de données
DATABASE_URL=postgresql://user:pass@host:port/db
DATABASE_HOST=bjd-postgresql.services.clever-cloud.com
DATABASE_PORT=5432
DATABASE_NAME=bjduvaldxkbwljy3uuel
DATABASE_USER=bjduvaldxkbwljy3uuel
DATABASE_PASSWORD=your_password

# Gitea
GITEA_URL=https://gitea.cleverapps.io
GITEA_TOKEN=your_token

# Clever Cloud
CC_ORG_ID=orga_a7844a87-3356-462b-9e22-ce6c5437b0aa
CC_TOKEN=your_token
CC_SECRET=your_secret
```

### Ports et URLs
```bash
# Services métier
FRONTEND_URL=https://virida-frontend-3d.cleverapps.io
API_URL=https://virida-backend-api.cleverapps.io
AI_ML_URL=https://virida-ai-ml.cleverapps.io
GITEA_BRIDGE_URL=https://virida-gitea-bridge.cleverapps.io

# Monitoring
PROMETHEUS_URL=https://virida-prometheus.cleverapps.io
GRAFANA_URL=https://virida-grafana.cleverapps.io
```

## 🚀 Plan de Déploiement

### Étape 1 : Nettoyer les Runtimes Linux Inutiles
```bash
# Supprimer les runtimes Linux qui ne servent à rien
clever delete --alias virida-frontend-3d-visualizer
clever delete --alias virida-backend-api-gateway
clever delete --alias virida-ai-ml-prediction-engine
clever delete --alias virida-monitoring-prometheus
clever delete --alias virida-monitoring-grafana
clever delete --alias virida-integration-gitea-bridge
```

### Étape 2 : Créer les Applications Docker
```bash
# Exécuter le script de création
./scripts/create-docker-apps.sh
```

### Étape 3 : Configurer les Variables d'Environnement
```bash
# Configurer chaque service avec ses variables
./scripts/configure-docker-env.sh
```

### Étape 4 : Déployer et Tester
```bash
# Déployer tous les services
./scripts/deploy-all-docker.sh
```

## 📈 Avantages de cette Approche

1. **Coût Optimisé** : Utilise le bon type d'application pour chaque besoin
2. **Performance** : Services isolés et optimisés
3. **Scalabilité** : Chaque service peut être mis à l'échelle indépendamment
4. **Maintenance** : Services séparés, plus facile à maintenir
5. **Monitoring** : Surveillance dédiée pour chaque service

## 🔍 Monitoring et Logs

### Prometheus (Collecte)
- Métriques système et applicatives
- Alertes automatiques
- Rétention des données

### Grafana (Visualisation)
- Dashboards personnalisés
- Alertes visuelles
- Rapports automatiques

### Logs Clever Cloud
- Logs centralisés
- Recherche et filtrage
- Intégration avec monitoring


