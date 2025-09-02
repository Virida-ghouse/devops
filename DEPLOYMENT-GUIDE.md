# 🚀 Guide de Déploiement VIRIDA en Production

## 📋 Prérequis

- ✅ Cluster Kubernetes opérationnel
- ✅ ArgoCD installé et configuré
- ✅ Accès à un registry Docker (Docker Hub ou Gitea)
- ✅ Domaine configuré (virida.com)

## 🎯 Options de Registry

### Option 1: Docker Hub (Recommandé)
```bash
# 1. Créer un compte Docker Hub
# 2. Exécuter le script de déploiement
./scripts/deploy-to-production.sh votre-username-dockerhub
```

### Option 2: Gitea Container Registry
```bash
# 1. Configurer l'accès Gitea
# 2. Exécuter le script de déploiement
./scripts/deploy-to-production.sh virida gitea
```

## 🔄 Workflow GitOps

### 1. Développement
```bash
# Modifier le code
vim frontend/3d-visualizer/server.js

# Rebuild l'image
docker build -t virida-3d-visualizer:latest frontend/3d-visualizer/

# Tester localement
docker run -p 3000:3000 virida-3d-visualizer:latest
```

### 2. Registry
```bash
# Pousser vers le registry
./scripts/push-to-dockerhub.sh votre-username
# ou
./scripts/push-to-gitea.sh
```

### 3. Production (Automatique via GitOps)
```bash
# Mettre à jour les manifests
vim k8s/production/frontend-3d-visualizer.yaml

# Commit et push
git add k8s/production/
git commit -m "🚀 Deploy v1.1.0"
git push origin main

# ArgoCD déploie automatiquement ! 🎉
```

## 📊 Monitoring du Déploiement

### ArgoCD
```bash
# Interface web
https://argocd.cleverapps.io

# CLI
kubectl get applications -n argocd
kubectl describe application virida-production -n argocd
```

### Kubernetes
```bash
# Pods
kubectl get pods -n virida

# Services
kubectl get svc -n virida

# Ingress
kubectl get ingress -n virida
```

### Logs
```bash
# Logs des services
kubectl logs -f deployment/frontend-3d-visualizer -n virida
kubectl logs -f deployment/backend-api-gateway -n virida
kubectl logs -f deployment/ai-ml-prediction -n virida
```

## 🌐 URLs de Production

- **Frontend 3D Visualizer**: https://3d.virida.com
- **Backend API Gateway**: https://api.virida.com
- **AI/ML Prediction Engine**: https://ai.virida.com
- **Monitoring Grafana**: https://grafana.virida.com
- **Monitoring Prometheus**: https://prometheus.virida.com
- **ArgoCD GitOps**: https://argocd.cleverapps.io

## 🔧 Configuration

### Variables d'Environnement
```yaml
# k8s/services/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: virida-secrets
  namespace: virida
data:
  database-url: <base64-encoded>
  jwt-secret: <base64-encoded>
  gitea-secret-key: <base64-encoded>
  grafana-admin-password: <base64-encoded>
```

### Ressources
```yaml
# Limites par service
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Sécurité
```yaml
# Security Context
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
    - ALL
```

## 🚨 Rollback

### Via Git
```bash
# Rollback à la version précédente
git revert HEAD
git push origin main
# ArgoCD déploie automatiquement l'ancienne version
```

### Via ArgoCD
```bash
# Interface web ArgoCD
# 1. Sélectionner l'application
# 2. Cliquer sur "HISTORY"
# 3. Sélectionner la version précédente
# 4. Cliquer sur "SYNC"
```

### Via kubectl
```bash
# Rollback manuel
kubectl rollout undo deployment/frontend-3d-visualizer -n virida
kubectl rollout undo deployment/backend-api-gateway -n virida
kubectl rollout undo deployment/ai-ml-prediction -n virida
```

## 🔍 Troubleshooting

### Pods en CrashLoopBackOff
```bash
# Vérifier les logs
kubectl logs deployment/frontend-3d-visualizer -n virida

# Vérifier les événements
kubectl describe pod -l app=frontend-3d-visualizer -n virida
```

### Images non trouvées
```bash
# Vérifier les images disponibles
kubectl get pods -n virida -o jsonpath='{.items[*].spec.containers[*].image}'

# Vérifier les secrets de registry
kubectl get secrets -n virida
```

### ArgoCD ne synchronise pas
```bash
# Forcer la synchronisation
kubectl patch application virida-production -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"force":true}}}}'

# Vérifier les logs ArgoCD
kubectl logs deployment/argocd-application-controller -n argocd
```

## 📈 Scaling

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-3d-visualizer-hpa
  namespace: virida
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend-3d-visualizer
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🎉 Félicitations !

Votre infrastructure VIRIDA est maintenant déployée en production avec GitOps ! 

- ✅ Déploiements automatiques
- ✅ Rollback en un clic
- ✅ Monitoring complet
- ✅ Sécurité renforcée
- ✅ Scaling automatique
