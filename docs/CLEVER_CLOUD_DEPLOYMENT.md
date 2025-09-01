# ☁️ VIRIDA Clever Cloud Deployment Guide

## 📋 Vue d'Ensemble

Ce guide détaille le déploiement de l'infrastructure VIRIDA sur **Clever Cloud**, plateforme cloud française offrant une excellente intégration Docker et des services managés.

## 🎯 Avantages Clever Cloud pour VIRIDA

### **✅ Points Forts**
- **Hébergement français** : RGPD, souveraineté des données
- **Intégration Docker native** : Support complet des conteneurs
- **Auto-scaling automatique** : Adaptation à la charge
- **Monitoring intégré** : Métriques et alertes
- **SSL/TLS automatique** : Certificats Let's Encrypt
- **Backup automatisé** : Récupération de données
- **Support français** : Assistance technique en français

### **🔧 Services Utilisés**
- **Application Container** : Hébergement des conteneurs Docker
- **PostgreSQL Add-on** : Base de données managée
- **Redis Add-on** : Cache et session store (optionnel)
- **Object Storage** : Stockage des artefacts et backups

## 🚀 Préparation du Déploiement

### **1. Configuration Clever Cloud**

#### **Créer une Application**
```bash
# Via la console web Clever Cloud
1. Aller sur https://console.clever-cloud.com
2. Créer une nouvelle application
3. Choisir "Application Container"
4. Sélectionner votre organisation
5. Configurer le nom et la région
```

#### **Ajouter PostgreSQL Add-on**
```bash
# Dans votre application
1. Aller dans "Add-ons"
2. Ajouter "PostgreSQL"
3. Choisir le plan approprié
4. Noter les informations de connexion
```

### **2. Configuration Locale**

#### **Copier le Fichier d'Environnement**
```bash
# Copier le fichier d'exemple
cp env.clever-cloud.example .env.clever-cloud

# Éditer les variables
nano .env.clever-cloud
```

#### **Variables Requises**
```bash
# Clever Cloud (automatiques)
CC_APP_DOMAIN=your-app.cleverapps.io
CC_POSTGRESQL_ADDON_HOST=your-postgres-host.clever-cloud.com
CC_POSTGRESQL_ADDON_DB=your-database-name
CC_POSTGRESQL_ADDON_USER=your-database-user
CC_POSTGRESQL_ADDON_PASSWORD=your-database-password

# Gitea (à configurer)
GITEA_SECRET_KEY=your-super-secret-key
GITEA_INTERNAL_TOKEN=your-internal-token
GITEA_ADMIN_PASSWORD=your-secure-admin-password
GRAFANA_ADMIN_PASSWORD=your-secure-grafana-password
```

## 🐳 Déploiement Automatisé

### **1. Script de Déploiement**

#### **Déploiement Complet**
```bash
# Déploiement avec tous les tests
./scripts/deploy-clever-cloud.sh
```

#### **Déploiement Rapide**
```bash
# Déploiement sans tests (pour les environnements de test)
./scripts/deploy-clever-cloud.sh --skip-tests
```

#### **Déploiement avec Nettoyage**
```bash
# Déploiement avec nettoyage des images
./scripts/deploy-clever-cloud.sh --cleanup-images
```

### **2. Déploiement Manuel**

#### **Build des Images**
```bash
# Construction des images
docker-compose -f docker-compose.clever-cloud.yml build

# Tag pour Clever Cloud
docker tag virida-gitea:latest your-app.cleverapps.io/virida-gitea:latest
```

#### **Démarrage des Services**
```bash
# Démarrage de l'infrastructure
docker-compose -f docker-compose.clever-cloud.yml up -d

# Vérification du statut
docker-compose -f docker-compose.clever-cloud.yml ps
```

## 🔧 Configuration Post-Déploiement

### **1. Configuration Gitea**

#### **Première Connexion**
```bash
# Accéder à Gitea
https://your-app.cleverapps.io

# Identifiants par défaut
Username: admin
Password: [mot de passe configuré dans .env.clever-cloud]
```

#### **Configuration des Actions**
```bash
# Aller dans Admin > Actions > Runners
1. Vérifier que le runner est connecté
2. Copier le token du runner
3. Mettre à jour .env.clever-cloud
4. Redémarrer le runner
```

### **2. Configuration du Monitoring**

#### **Prometheus**
```bash
# Accès direct
https://your-app.cleverapps.io:9090

# Configuration des targets
# Éditer monitoring/prometheus/prometheus.yml
```

#### **Grafana**
```bash
# Accès via Traefik
https://your-app.cleverapps.io/grafana

# Identifiants par défaut
Username: admin
Password: [mot de passe configuré dans .env.clever-cloud]
```

## 📊 Monitoring et Observabilité

### **1. Métriques Clever Cloud**

#### **Métriques Système**
- **CPU Usage** : Utilisation des ressources
- **Memory Usage** : Consommation mémoire
- **Disk I/O** : Activité disque
- **Network I/O** : Trafic réseau

#### **Métriques Application**
- **Response Time** : Temps de réponse
- **Error Rate** : Taux d'erreur
- **Throughput** : Débit de requêtes

### **2. Alertes et Notifications**

#### **Configuration des Alertes**
```yaml
# monitoring/prometheus/alerts.yml
groups:
  - name: virida-alerts
    rules:
      - alert: HighCPUUsage
        expr: cpu_usage > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU usage is high"
```

#### **Intégration Slack/Email**
```bash
# Configuration des webhooks
# Dans la console Clever Cloud
# Alerts > Webhooks > Ajouter votre endpoint
```

## 🔒 Sécurité et Conformité

### **1. Chiffrement et Certificats**

#### **SSL/TLS Automatique**
- **Let's Encrypt** : Certificats gratuits et automatiques
- **Renouvellement** : Géré automatiquement par Clever Cloud
- **HSTS** : Headers de sécurité HTTP

#### **Chiffrement des Données**
- **TLS 1.3** : Chiffrement en transit
- **AES-256** : Chiffrement au repos
- **Key Rotation** : Rotation automatique des clés

### **2. Authentification et Autorisation**

#### **Gitea Security**
```bash
# Configuration de sécurité
GITEA__security__REQUIRE_SIGNIN_VIEW=true
GITEA__security__ENABLE_CAPTCHA=true
GITEA__security__LOGIN_ATTEMPT_WINDOW=10
GITEA__security__MAX_LOGIN_ATTEMPTS=5
```

#### **Traefik Security**
```bash
# Authentification basique pour l'admin
TRAEFIK_AUTH_USERS=admin:$$2y$$10$$hashed-password

# Limitation de débit
# Configuration dans traefik/traefik.yml
```

## 📈 Scaling et Performance

### **1. Auto-Scaling Clever Cloud**

#### **Configuration du Scaling**
```bash
# Dans la console Clever Cloud
# Scaling > Configuration
- Min instances: 1
- Max instances: 5
- CPU threshold: 70%
- Memory threshold: 80%
```

#### **Optimisations Docker**
```bash
# Limites de ressources
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 512M
```

### **2. Performance Monitoring**

#### **Métriques de Performance**
- **Response Time** : < 200ms
- **Throughput** : > 1000 req/s
- **Error Rate** : < 1%
- **Uptime** : > 99.9%

#### **Optimisations Recommandées**
```bash
# Cache Redis
# Load Balancing
# CDN pour les assets statiques
# Compression Gzip
```

## 🚨 Troubleshooting

### **1. Problèmes Courants**

#### **Service Non Accessible**
```bash
# Vérifier les logs
docker-compose -f docker-compose.clever-cloud.yml logs gitea

# Vérifier la connectivité
curl -v https://your-app.cleverapps.io

# Vérifier les ports
netstat -tlnp | grep :3000
```

#### **Base de Données Non Connectée**
```bash
# Vérifier les variables d'environnement
echo $CC_POSTGRESQL_ADDON_HOST

# Tester la connexion
psql -h $CC_POSTGRESQL_ADDON_HOST -U $CC_POSTGRESQL_ADDON_USER -d $CC_POSTGRESQL_ADDON_DB
```

### **2. Logs et Debug**

#### **Accès aux Logs**
```bash
# Logs en temps réel
docker-compose -f docker-compose.clever-cloud.yml logs -f

# Logs d'un service spécifique
docker-compose -f docker-compose.clever-cloud.yml logs gitea

# Logs Clever Cloud
# Console > Applications > Votre App > Logs
```

#### **Debug des Conteneurs**
```bash
# Shell dans un conteneur
docker-compose -f docker-compose.clever-cloud.yml exec gitea sh

# Inspection des conteneurs
docker inspect virida-gitea
```

## 🔄 Maintenance et Mises à Jour

### **1. Mises à Jour Automatiques**

#### **Configuration des Mises à Jour**
```bash
# Dans la console Clever Cloud
# Applications > Votre App > Settings > Auto-update
- Enable: true
- Schedule: Weekly
- Time: Sunday 2:00 AM
```

#### **Rollback Automatique**
```bash
# Configuration du rollback
# En cas d'échec de mise à jour
# Retour automatique à la version précédente
```

### **2. Sauvegarde et Récupération**

#### **Sauvegarde Automatique**
```bash
# PostgreSQL
# Gérée automatiquement par Clever Cloud
# Rétention: 30 jours

# Volumes Docker
# Sauvegarde des données Gitea
docker run --rm -v virida_gitea_data:/data -v $(pwd):/backup alpine tar czf /backup/gitea-backup.tar.gz /data
```

#### **Récupération de Données**
```bash
# Restauration PostgreSQL
# Via la console Clever Cloud
# Add-ons > PostgreSQL > Backups > Restore

# Restauration des volumes
docker run --rm -v virida_gitea_data:/data -v $(pwd):/backup alpine tar xzf /backup/gitea-backup.tar.gz -C /
```

## 📚 Ressources et Support

### **1. Documentation Officielle**

- **Clever Cloud** : [https://www.clever-cloud.com/doc/](https://www.clever-cloud.com/doc/)
- **Gitea Actions** : [https://docs.gitea.com/usage/actions/overview](https://docs.gitea.com/usage/actions/overview)
- **Docker Compose** : [https://docs.docker.com/compose/](https://docs.docker.com/compose/)

### **2. Support et Communauté**

- **Support Clever Cloud** : support@clever-cloud.com
- **Documentation VIRIDA** : docs.virida.local
- **Issues Gitea** : Gitea Issues
- **Wiki VIRIDA** : Gitea Wiki

### **3. Outils Recommandés**

- **Clever Tools CLI** : Outil en ligne de commande
- **Clever Cloud Console** : Interface web d'administration
- **Clever Cloud Mobile** : Application mobile

---

## 🎯 Prochaines Étapes

### **Phase 1 - Déploiement Initial**
- [x] Configuration Clever Cloud
- [x] Déploiement de l'infrastructure
- [x] Configuration Gitea Actions

### **Phase 2 - Optimisation**
- [ ] Configuration du monitoring avancé
- [ ] Mise en place des alertes
- [ ] Optimisation des performances

### **Phase 3 - Production**
- [ ] Tests de charge
- [ ] Configuration du backup
- [ ] Documentation de l'équipe

---

*Dernière mise à jour : $(date)*
*Version : 1.0.0*
*Environnement : Clever Cloud*

