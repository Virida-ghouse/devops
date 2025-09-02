#!/bin/bash

# Script de déploiement Kubernetes et ArgoCD pour VIRIDA
# Usage: ./deploy-kubernetes.sh [cluster-name]

set -e

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Variables
CLUSTER_NAME=${1:-"virida-cluster"}
NAMESPACE="virida"
ARGOCD_NAMESPACE="argocd"

log_info "🚀 Déploiement Kubernetes et ArgoCD pour VIRIDA"
log_info "Cluster: $CLUSTER_NAME"

# Vérifier les prérequis
log_info "Vérification des prérequis..."

if ! command -v kubectl &> /dev/null; then
    log_error "kubectl not found. Please install kubectl first."
    exit 1
fi

if ! command -v helm &> /dev/null; then
    log_error "helm not found. Please install helm first."
    exit 1
fi

log_success "Prérequis vérifiés"

# Vérifier la connexion au cluster
log_info "Vérification de la connexion au cluster..."
if ! kubectl cluster-info &> /dev/null; then
    log_error "Not connected to a Kubernetes cluster. Please configure kubectl first."
    exit 1
fi

log_success "Connecté au cluster Kubernetes"

# Créer les namespaces
log_info "Création des namespaces..."
kubectl apply -f k8s/services/namespace.yaml
kubectl apply -f k8s/monitoring/namespace.yaml || true

# Installer ArgoCD
log_info "Installation d'ArgoCD..."
kubectl create namespace $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Ajouter le repository Helm ArgoCD
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Installer ArgoCD avec Helm
helm upgrade --install argocd argo/argo-cd \
  --namespace $ARGOCD_NAMESPACE \
  --set global.domain=argocd.virida.local \
  --set server.service.type=LoadBalancer \
  --set server.ingress.enabled=true \
  --set server.ingress.ingressClassName=nginx \
  --set server.ingress.hosts[0]=argocd.virida.local \
  --set server.ingress.tls[0].secretName=argocd-server-tls \
  --set server.ingress.tls[0].hosts[0]=argocd.virida.local \
  --set configs.cm.url=https://argocd.virida.local \
  --set configs.rbac.policy.default=role:readonly \
  --set configs.rbac.policy.csv="p, role:admin, applications, *, */*, allow" \
  --set controller.metrics.enabled=true \
  --set notifications.enabled=true \
  --set applicationSet.enabled=true \
  --wait

log_success "ArgoCD installé"

# Attendre qu'ArgoCD soit prêt
log_info "Attente qu'ArgoCD soit prêt..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n $ARGOCD_NAMESPACE

# Récupérer le mot de passe admin ArgoCD
log_info "Récupération du mot de passe admin ArgoCD..."
ARGOCD_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
log_info "Mot de passe admin ArgoCD: $ARGOCD_PASSWORD"

# Créer les secrets VIRIDA
log_info "Création des secrets VIRIDA..."
kubectl apply -f k8s/services/secrets.yaml

# Déployer les services VIRIDA
log_info "Déploiement des services VIRIDA..."
kubectl apply -f k8s/services/frontend-3d-visualizer.yaml
kubectl apply -f k8s/services/backend-api-gateway.yaml
kubectl apply -f k8s/services/ai-ml-prediction.yaml

# Déployer le monitoring
log_info "Déploiement du monitoring..."
kubectl apply -f k8s/monitoring/prometheus.yaml
kubectl apply -f k8s/monitoring/grafana.yaml

# Créer les applications ArgoCD
log_info "Création des applications ArgoCD..."
kubectl apply -f k8s/applications/virida-apps.yaml

# Attendre que les services soient prêts
log_info "Attente que les services soient prêts..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend-3d-visualizer -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/backend-api-gateway -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/ai-ml-prediction -n $NAMESPACE

# Afficher le statut
log_info "Statut des déploiements..."
kubectl get pods -n $NAMESPACE
kubectl get pods -n $ARGOCD_NAMESPACE
kubectl get pods -n monitoring

# Afficher les services
log_info "Services exposés..."
kubectl get services -n $NAMESPACE
kubectl get services -n $ARGOCD_NAMESPACE
kubectl get services -n monitoring

# Afficher les ingresses
log_info "Ingresses configurés..."
kubectl get ingress -n $NAMESPACE
kubectl get ingress -n $ARGOCD_NAMESPACE
kubectl get ingress -n monitoring

# Résumé du déploiement
echo ""
log_success "🎉 Déploiement Kubernetes et ArgoCD terminé avec succès!"
echo ""
echo "📊 Résumé du déploiement:"
echo "  - Cluster: $CLUSTER_NAME"
echo "  - Namespace VIRIDA: $NAMESPACE"
echo "  - Namespace ArgoCD: $ARGOCD_NAMESPACE"
echo "  - Namespace Monitoring: monitoring"
echo ""
echo "🔗 Accès aux services:"
echo "  - ArgoCD: https://argocd.virida.local (admin / $ARGOCD_PASSWORD)"
echo "  - Frontend 3D: https://3d.virida.local"
echo "  - API Gateway: https://api.virida.local"
echo "  - AI/ML: https://ai.virida.local"
echo "  - Prometheus: https://prometheus.virida.local"
echo "  - Grafana: https://grafana.virida.local (admin / admin123)"
echo ""
echo "📋 Commandes utiles:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl get pods -n $ARGOCD_NAMESPACE"
echo "  kubectl get pods -n monitoring"
echo "  kubectl logs -f deployment/backend-api-gateway -n $NAMESPACE"
echo ""
log_info "Déploiement terminé à $(date)"
