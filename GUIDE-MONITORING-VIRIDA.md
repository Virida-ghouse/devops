# 📊 Guide de Configuration du Monitoring VIRIDA

## 📋 Vue d'ensemble

Ce guide explique comment configurer et utiliser le système de monitoring VIRIDA avec Prometheus et Grafana sur Clever Cloud.

## 🏗️ Architecture du Monitoring

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Services      │    │   Prometheus    │    │    Grafana      │
│   VIRIDA        │───▶│   (Collecte)    │───▶│  (Visualisation)│
│                 │    │                 │    │                 │
│ • 3D Visualizer │    │ • Métriques     │    │ • Dashboards    │
│ • API Gateway   │    │ • Alertes       │    │ • Graphiques    │
│ • AI Prediction │    │ • Règles        │    │ • Alertes       │
│ • Gitea Bridge  │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Déploiement

### 1. **Déploiement automatique**

```bash
# Déployer le monitoring complet
./scripts/deploy-monitoring.sh
```

### 2. **Déploiement manuel**

```bash
# Construire les images
cd monitoring/prometheus
docker build --tag crkdocker1/virida-prometheus:latest .
docker push crkdocker1/virida-prometheus:latest

cd ../grafana
docker build --tag crkdocker1/virida-grafana:latest .
docker push crkdocker1/virida-grafana:latest

# Créer les applications Clever Cloud
clever create --type docker --org orga_a7844a87-3356-462b-9e22-ce6c5437b0aa virida-prometheus
clever create --type docker --org orga_a7844a87-3356-462b-9e22-ce6c5437b0aa virida-grafana

# Déployer
clever deploy --alias virida-prometheus
clever deploy --alias virida-grafana
```

## 🔧 Configuration

### **Prometheus**

**URL d'accès :** `https://virida-prometheus.cleverapps.io`

**Configuration :**
- **Scrape interval :** 30 secondes
- **Retention :** 30 jours
- **Alertes :** Configurées pour tous les services VIRIDA

**Métriques collectées :**
- Métriques système (CPU, mémoire, disque)
- Métriques applicatives (requêtes, erreurs, latence)
- Métriques métier (prédictions IA, données IoT)
- Métriques de sécurité (tentatives de connexion)

### **Grafana**

**URL d'accès :** `https://virida-grafana.cleverapps.io`

**Identifiants par défaut :**
- **Utilisateur :** admin
- **Mot de passe :** Généré automatiquement

**Dashboards disponibles :**
1. **VIRIDA Overview** - Vue d'ensemble du système
2. **VIRIDA Services** - Détail des services
3. **VIRIDA Business** - Métriques métier

## 📊 Dashboards

### **1. VIRIDA Overview**
- Statut des services
- Utilisation CPU/Mémoire
- Taux de requêtes
- Temps de réponse
- Taux d'erreur
- Prédictions IA

### **2. VIRIDA Services**
- Performance 3D Visualizer
- Métriques API Gateway
- Performance AI Prediction Engine
- Activité Gitea Bridge
- Performance base de données

### **3. VIRIDA Business**
- Activité utilisateurs
- Collecte de données IoT
- Performance IA
- Score de satisfaction
- Conformité SLA

## 🚨 Alertes

### **Alertes Critiques**
- Service down
- Disque plein (>90%)
- Taux d'erreur élevé (>5%)
- Accès non autorisés

### **Alertes d'Avertissement**
- Utilisation CPU élevée (>80%)
- Utilisation mémoire élevée (>85%)
- Temps de réponse élevé (>2s)
- Échecs de prédictions IA

### **Configuration des Alertes**

Les alertes sont configurées dans `monitoring/prometheus/virida-alerts.yml` :

```yaml
- alert: ServiceDown
  expr: up == 0
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: "Service {{ $labels.job }} is down"
```

## 📈 Métriques Personnalisées

### **Métriques VIRIDA**

Pour ajouter des métriques personnalisées à vos services :

```javascript
// Exemple pour Node.js
const prometheus = require('prom-client');

// Compteur de prédictions IA
const aiPredictionsCounter = new prometheus.Counter({
  name: 'virida_ai_predictions_total',
  help: 'Total number of AI predictions',
  labelNames: ['model', 'status']
});

// Histogramme de temps de rendu 3D
const renderingDuration = new prometheus.Histogram({
  name: 'virida_3d_rendering_duration_seconds',
  help: '3D rendering duration in seconds',
  buckets: [0.1, 0.5, 1, 2, 5, 10]
});
```

### **Endpoint de métriques**

Ajoutez un endpoint `/metrics` à vos services :

```javascript
app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

## 🔄 Maintenance

### **Mise à jour des dashboards**

```bash
# Modifier les dashboards JSON
nano monitoring/grafana/dashboards/virida-overview.json

# Redéployer Grafana
clever deploy --alias virida-grafana
```

### **Ajout de nouvelles alertes**

```bash
# Modifier les règles d'alerte
nano monitoring/prometheus/virida-alerts.yml

# Redéployer Prometheus
clever deploy --alias virida-prometheus
```

### **Sauvegarde des données**

```bash
# Exporter les dashboards
curl -H "Authorization: Bearer $GRAFANA_TOKEN" \
  https://virida-grafana.cleverapps.io/api/dashboards/db/virida-overview > virida-overview-backup.json
```

## 🆘 Dépannage

### **Problèmes courants**

1. **Prometheus ne collecte pas de métriques**
   ```bash
   # Vérifier la configuration
   curl https://virida-prometheus.cleverapps.io/api/v1/targets
   ```

2. **Grafana ne se connecte pas à Prometheus**
   ```bash
   # Vérifier la datasource
   curl -H "Authorization: Bearer $GRAFANA_TOKEN" \
     https://virida-grafana.cleverapps.io/api/datasources
   ```

3. **Alertes ne se déclenchent pas**
   ```bash
   # Vérifier les règles
   curl https://virida-prometheus.cleverapps.io/api/v1/rules
   ```

### **Logs**

```bash
# Logs Prometheus
clever logs --app virida-prometheus

# Logs Grafana
clever logs --app virida-grafana
```

## 📚 Ressources

- [Documentation Prometheus](https://prometheus.io/docs/)
- [Documentation Grafana](https://grafana.com/docs/)
- [Métriques Prometheus](https://prometheus.io/docs/concepts/metric_types/)
- [Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)

## 🎯 Prochaines Étapes

1. **Configurer les notifications** (email, Slack, etc.)
2. **Ajouter des métriques personnalisées** à vos services
3. **Créer des dashboards spécifiques** à vos besoins
4. **Implémenter des alertes métier** personnalisées
5. **Intégrer avec des outils externes** (PagerDuty, etc.)

---

**🎉 Monitoring VIRIDA configuré et opérationnel !**


