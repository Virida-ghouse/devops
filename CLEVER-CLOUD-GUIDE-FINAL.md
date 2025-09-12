# 🎯 Guide Final Clever Cloud pour VIRIDA

## 🧠 **Concept Clever Cloud - Compréhension Complète**

### **Clever Cloud = PaaS (Platform as a Service)**
```
┌─────────────────────────────────────────────────────────────┐
│                    CLEVER CLOUD (PaaS)                     │
├─────────────────────────────────────────────────────────────┤
│  🚀 Déploiement Automatique                                │
│  ├── Git Push → Build → Deploy                             │
│  ├── Tests automatiques                                    │
│  └── Scaling automatique                                   │
├─────────────────────────────────────────────────────────────┤
│  🛠️ Gestion Infrastructure                                 │
│  ├── Serveurs (gérés par Clever)                           │
│  ├── Load Balancing                                        │
│  ├── SSL/TLS                                               │
│  └── Monitoring                                            │
├─────────────────────────────────────────────────────────────┤
│  📦 Runtime Support                                        │
│  ├── Node.js (détection auto)                              │
│  ├── Python (détection auto)                               │
│  ├── Java (détection auto)                                 │
│  └── Docker (optionnel, pas recommandé)                    │
└─────────────────────────────────────────────────────────────┘
```

### **Types de Runtimes Clever Cloud :**

| Type | Usage | Avantages | Inconvénients | Coût/mois |
|------|-------|-----------|---------------|-----------|
| **Node.js** | Apps web, APIs | Configuration auto, optimisé | Moins flexible | ~15-25€ |
| **Python** | ML, APIs, scripts | Configuration auto, optimisé | Moins flexible | ~20-30€ |
| **Linux** | Services système | Contrôle total, flexible | Configuration manuelle | ~10-20€ |
| **Docker** | Conteneurs | Isolation, portabilité | Plus cher, complexe | ~25-40€ |

---

## 🏗️ **Architecture VIRIDA Optimale**

### **Stratégie par Type de Service :**

**Services Métier (Runtime Natif) :**
- ✅ `virida-frontend-3d` → **Node.js** (React/Interface)
- ✅ `virida-backend-api` → **Node.js** (API Gateway)
- ✅ `virida-ai-ml` → **Python** (Machine Learning)

**Services Système (Runtime Linux) :**
- ✅ `virida-prometheus` → **Linux** (Monitoring)
- ✅ `virida-grafana` → **Linux** (Dashboards)

**Services Existants (À conserver) :**
- ✅ `gitea` → **Linux** (Git server)
- ✅ `virida_ihm` → **Node.js** (Interface web)
- ✅ `n8n` → **Node.js** (Workflow automation)

---

## 🚀 **Workflow Clever Cloud Recommandé**

### **1. Développement Local :**
```bash
# Tester en local
cd apps/frontend-3d && npm start
cd apps/backend-api && npm start  
cd apps/ai-ml && python app-simple.py
```

### **2. Déploiement Clever Cloud :**
```bash
# Déployer chaque application
cd apps/frontend-3d && clever deploy --alias virida-frontend-3d
cd apps/backend-api && clever deploy --alias virida-backend-api
cd apps/ai-ml && clever deploy --alias virida-ai-ml
```

### **3. CI/CD (Quand Gitea fonctionne) :**
```yaml
# .gitea/workflows/deploy.yml
name: Deploy to Clever Cloud
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy
        run: clever deploy --alias ${{ github.event.repository.name }}
```

---

## 🔧 **Configuration des Applications**

### **Node.js Applications :**
```json
// package.json
{
  "name": "virida-frontend-3d",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

```json
// clevercloud.json
{
  "build": {
    "type": "npm",
    "buildCommand": "npm install"
  },
  "deploy": {
    "command": "npm start"
  }
}
```

### **Python Applications :**
```txt
# requirements.txt
Flask==2.3.3
Flask-CORS==4.0.0
gunicorn==21.2.0
```

```json
// clevercloud.json
{
  "build": {
    "type": "python",
    "buildCommand": "pip install -r requirements.txt"
  },
  "deploy": {
    "command": "gunicorn app:app --bind 0.0.0.0:$PORT"
  }
}
```

### **Linux Applications :**
```bash
# Configuration manuelle requise
# Exemple pour Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
./prometheus --config.file=prometheus.yml --web.listen-address=0.0.0.0:$PORT
```

---

## 📊 **Monitoring et Observabilité**

### **Prometheus (Collecte de Métriques) :**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'virida-services'
    static_configs:
      - targets: 
        - 'virida-frontend-3d.cleverapps.io:3000'
        - 'virida-backend-api.cleverapps.io:8080'
        - 'virida-ai-ml.cleverapps.io:8000'
```

### **Grafana (Visualisation) :**
- **Dashboard Overview** : Vue d'ensemble du système
- **Dashboard Services** : Métriques détaillées par service
- **Dashboard Business** : Métriques métier

---

## 🔐 **Sécurité et Variables d'Environnement**

### **Variables Partagées :**
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

### **Configuration par Application :**
```bash
# Frontend 3D
clever env set PORT 3000 --app virida-frontend-3d
clever env set NODE_ENV production --app virida-frontend-3d

# Backend API
clever env set PORT 8080 --app virida-backend-api
clever env set DATABASE_URL "postgresql://..." --app virida-backend-api

# AI/ML
clever env set PORT 8000 --app virida-ai-ml
clever env set PYTHON_VERSION 3.11 --app virida-ai-ml
```

---

## 💰 **Optimisation des Coûts**

### **Stratégie de Coût :**
1. **Utiliser les runtimes natifs** (Node.js, Python) au lieu de Docker
2. **Consolider le monitoring** sur 2 applications Linux
3. **Optimiser les ressources** selon l'usage réel
4. **Utiliser les add-ons gérés** (PostgreSQL) au lieu de self-hosted

### **Coûts Estimés :**
- **Applications Node.js** (3) : ~45-75€/mois
- **Application Python** (1) : ~20-30€/mois
- **Applications Linux** (2) : ~20-40€/mois
- **Applications existantes** (3) : ~30-50€/mois
- **PostgreSQL Add-on** : ~15-25€/mois
- **Total** : ~130-220€/mois

---

## 🎯 **Bonnes Pratiques Clever Cloud**

### **1. Structure de Projet :**
```
VIRIDA/
├── apps/                    # Applications natives
│   ├── frontend-3d/        # Node.js
│   ├── backend-api/        # Node.js
│   ├── ai-ml/              # Python
│   ├── prometheus/         # Linux
│   └── grafana/            # Linux
├── .gitea/workflows/       # CI/CD (si Gitea fonctionne)
├── scripts/                # Scripts DevOps
└── docs/                   # Documentation
```

### **2. Déploiement :**
- ✅ **Tester localement** avant de déployer
- ✅ **Utiliser les runtimes natifs** (Node.js, Python)
- ✅ **Configurer les variables d'environnement**
- ✅ **Monitorer les logs** après déploiement

### **3. Monitoring :**
- ✅ **Health checks** sur chaque service
- ✅ **Métriques Prometheus** pour la collecte
- ✅ **Dashboards Grafana** pour la visualisation
- ✅ **Alertes** pour les problèmes critiques

---

## 🚨 **Dépannage Courant**

### **Problèmes Fréquents :**

**1. Application ne démarre pas :**
```bash
# Vérifier les logs
clever logs --alias virida-frontend-3d

# Vérifier les variables d'environnement
clever env --alias virida-frontend-3d
```

**2. Port non accessible :**
```bash
# Vérifier la configuration du port
clever env set PORT 3000 --app virida-frontend-3d
```

**3. Dépendances manquantes :**
```bash
# Pour Node.js : vérifier package.json
# Pour Python : vérifier requirements.txt
```

**4. Gitea ne fonctionne pas :**
- **Solution** : Utiliser le déploiement manuel avec Clever Tools CLI
- **Alternative** : Configurer GitHub Actions avec déploiement Clever Cloud

---

## 🎉 **Conclusion**

**Clever Cloud = PaaS moderne et efficace pour VIRIDA**

- ✅ **Déploiement simplifié** : Git Push → Déploiement automatique
- ✅ **Runtimes optimisés** : Node.js, Python, Linux
- ✅ **Infrastructure gérée** : Pas de gestion serveur
- ✅ **Scaling automatique** : Selon la charge
- ✅ **Monitoring intégré** : Logs et métriques
- ✅ **Coûts optimisés** : Pay-per-use

**Prochaine étape** : Déployer et tester en production !


