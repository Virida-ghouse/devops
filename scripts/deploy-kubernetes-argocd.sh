#!/bin/bash

# ☸️ VIRIDA Kubernetes + ArgoCD Deployment Script
# Script de déploiement de l'infrastructure Kubernetes avec ArgoCD

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$PROJECT_ROOT/k8s"
HELM_DIR="$PROJECT_ROOT/helm-charts"

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables d'environnement
CLUSTER_TYPE="${CLUSTER_TYPE:-k3s}"
DEPLOY_ENVIRONMENT="${DEPLOY_ENVIRONMENT:-development}"
SKIP_CLUSTER_SETUP="${SKIP_CLUSTER_SETUP:-false}"
SKIP_ARGOCD="${SKIP_ARGOCD:-false}"
SKIP_APPLICATIONS="${SKIP_APPLICATIONS:-false}"

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl n'est pas installé"
        exit 1
    fi
    
    # Vérifier helm
    if ! command -v helm &> /dev/null; then
        log_info "Helm n'est pas installé, installation en cours..."
        install_helm
    fi
    
    # Vérifier argocd CLI
    if ! command -v argocd &> /dev/null; then
        log_info "ArgoCD CLI n'est pas installé, installation en cours..."
        install_argocd_cli
    fi
    
    log_success "Prérequis vérifiés"
}

# Installation de Helm
install_helm() {
    log_info "Installation de Helm..."
    
    if command -v brew &> /dev/null; then
        brew install helm
    elif command -v curl &> /dev/null; then
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    else
        log_error "Impossible d'installer Helm automatiquement"
        log_info "Veuillez installer Helm manuellement: https://helm.sh/docs/intro/install/"
        exit 1
    fi
    
    log_success "Helm installé"
}

# Installation d'ArgoCD CLI
install_argocd_cli() {
    log_info "Installation d'ArgoCD CLI..."
    
    if command -v brew &> /dev/null; then
        brew install argocd
    elif command -v curl &> /dev/null; then
        curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
        sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
        rm argocd-linux-amd64
    else
        log_error "Impossible d'installer ArgoCD CLI automatiquement"
        log_info "Veuillez installer ArgoCD CLI manuellement: https://argo-cd.readthedocs.io/en/stable/cli_installation/"
        exit 1
    fi
    
    log_success "ArgoCD CLI installé"
}

# Configuration du cluster Kubernetes
setup_kubernetes_cluster() {
    if [ "$SKIP_CLUSTER_SETUP" = "true" ]; then
        log_warning "Configuration du cluster ignorée"
        return 0
    fi
    
    log_info "Configuration du cluster Kubernetes..."
    
    # Vérifier la connectivité au cluster
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Impossible de se connecter au cluster Kubernetes"
        log_info "Veuillez démarrer votre cluster Kubernetes (K3s, minikube, etc.)"
        exit 1
    fi
    
    # Appliquer la configuration du cluster
    log_info "Application de la configuration du cluster..."
    kubectl apply -f "$K8S_DIR/cluster-config/k3s-config.yaml"
    
    # Vérifier les namespaces
    log_info "Vérification des namespaces..."
    kubectl get namespaces | grep -E "(virida|argocd)" || {
        log_warning "Namespaces VIRIDA non trouvés, création..."
        kubectl apply -f "$K8S_DIR/cluster-config/k3s-config.yaml"
    }
    
    log_success "Cluster Kubernetes configuré"
}

# Installation d'ArgoCD
install_argocd() {
    if [ "$SKIP_ARGOCD" = "true" ]; then
        log_warning "Installation d'ArgoCD ignorée"
        return 0
    fi
    
    log_info "Installation d'ArgoCD..."
    
    # Créer le namespace ArgoCD s'il n'existe pas
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    # Installer ArgoCD
    log_info "Déploiement d'ArgoCD..."
    kubectl apply -f "$K8S_DIR/argocd/argocd-install.yaml"
    
    # Attendre qu'ArgoCD soit prêt
    log_info "Attente qu'ArgoCD soit prêt..."
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    
    # Récupérer le mot de passe admin
    local admin_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "$admin_password" > "$PROJECT_ROOT/.argocd-admin-password"
    
    log_success "ArgoCD installé et configuré"
    log_info "Mot de passe admin ArgoCD: $admin_password"
}

# Configuration des applications ArgoCD
setup_argocd_applications() {
    if [ "$SKIP_APPLICATIONS" = "true" ]; then
        log_warning "Configuration des applications ignorée"
        return 0
    fi
    
    log_info "Configuration des applications ArgoCD..."
    
    # Attendre qu'ArgoCD soit complètement prêt
    sleep 30
    
    # Appliquer les applications
    log_info "Déploiement des applications VIRIDA..."
    kubectl apply -f "$K8S_DIR/argocd/applications/virida-apps.yaml"
    
    # Vérifier le statut des applications
    log_info "Vérification du statut des applications..."
    kubectl get applications -n argocd
    
    log_success "Applications ArgoCD configurées"
}

# Configuration du monitoring
setup_monitoring() {
    log_info "Configuration du monitoring..."
    
    # Déployer Prometheus
    log_info "Déploiement de Prometheus..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace virida-monitoring \
        --create-namespace \
        --set prometheus.prometheusSpec.retention=7d \
        --set grafana.adminPassword=admin \
        --set grafana.service.type=ClusterIP
    
    # Déployer Grafana dashboards
    log_info "Configuration des dashboards Grafana..."
    kubectl apply -f "$K8S_DIR/monitoring/grafana-dashboards/"
    
    log_success "Monitoring configuré"
}

# Configuration de l'ingress
setup_ingress() {
    log_info "Configuration de l'ingress..."
    
    # Installer NGINX Ingress Controller
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace virida-system \
        --create-namespace \
        --set controller.service.type=NodePort \
        --set controller.ingressClassResource.name=nginx \
        --set controller.ingressClassResource.default=true
    
    # Configurer les ingress VIRIDA
    log_info "Configuration des ingress VIRIDA..."
    kubectl apply -f "$K8S_DIR/ingress/"
    
    log_success "Ingress configuré"
}

# Configuration des secrets et ConfigMaps
setup_secrets() {
    log_info "Configuration des secrets et ConfigMaps..."
    
    # Créer les secrets de base
    kubectl create secret generic virida-secrets \
        --from-literal=postgres-password=virida_password \
        --from-literal=redis-password=virida_redis_password \
        --from-literal=jwt-secret=virida_jwt_secret_2024 \
        --namespace virida-apps \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Créer les ConfigMaps
    kubectl create configmap virida-config \
        --from-literal=environment=$DEPLOY_ENVIRONMENT \
        --from-literal=api-url=http://backend-api-gateway:3000 \
        --from-literal=monitoring-enabled=true \
        --namespace virida-apps \
        --dry-run=client -o yaml | kubectl apply -f -
    
    log_success "Secrets et ConfigMaps configurés"
}

# Tests de validation
run_validation_tests() {
    log_info "Exécution des tests de validation..."
    
    # Vérifier les pods
    log_info "Vérification des pods..."
    kubectl get pods --all-namespaces | grep -E "(virida|argocd)"
    
    # Vérifier les services
    log_info "Vérification des services..."
    kubectl get services --all-namespaces | grep -E "(virida|argocd)"
    
    # Vérifier les ingress
    log_info "Vérification des ingress..."
    kubectl get ingress --all-namespaces
    
    # Tests de connectivité
    log_info "Tests de connectivité..."
    local frontend_service=$(kubectl get service -n virida-apps -l app.kubernetes.io/name=frontend-3d-visualizer -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$frontend_service" ]; then
        kubectl port-forward -n virida-apps service/$frontend_service 3001:3000 &
        local port_forward_pid=$!
        sleep 5
        
        if curl -s http://localhost:3001 > /dev/null; then
            log_success "Service frontend accessible"
        else
            log_warning "Service frontend non accessible"
        fi
        
        kill $port_forward_pid 2>/dev/null || true
    fi
    
    log_success "Tests de validation terminés"
}

# Affichage des informations de déploiement
show_deployment_info() {
    log_success "Déploiement Kubernetes + ArgoCD VIRIDA terminé !"
    echo ""
    echo "☸️ **Infrastructure Kubernetes**"
    echo "=================================="
    echo "Cluster:           $CLUSTER_TYPE"
    echo "Environnement:     $DEPLOY_ENVIRONMENT"
    echo "Namespaces:        virida-system, virida-apps, virida-monitoring, argocd"
    echo ""
    echo "🚀 **ArgoCD GitOps**"
    echo "URL:               http://localhost:8080 (port-forward)"
    echo "Username:          admin"
    echo "Password:          $(cat $PROJECT_ROOT/.argocd-admin-password 2>/dev/null || echo 'non configuré')"
    echo ""
    echo "📊 **Monitoring**"
    echo "Prometheus:        http://localhost:9090 (port-forward)"
    echo "Grafana:           http://localhost:3000 (port-forward)"
    echo "  - Username:      admin"
    echo "  - Password:      admin"
    echo ""
    echo "🔧 **Commandes Utiles**"
    echo "Port-forward ArgoCD:  kubectl port-forward -n argocd service/argocd-server 8080:80"
    echo "Port-forward Grafana: kubectl port-forward -n virida-monitoring service/prometheus-grafana 3000:80"
    echo "Statut des apps:      kubectl get applications -n argocd"
    echo "Logs d'une app:       kubectl logs -n argocd deployment/argocd-server"
    echo ""
    echo "📚 **Documentation**"
    echo "ArgoCD:            https://argo-cd.readthedocs.io/"
    echo "Kubernetes:        https://kubernetes.io/docs/"
    echo "Helm:              https://helm.sh/docs/"
}

# Affichage de l'aide
show_help() {
    echo "☸️ VIRIDA Kubernetes + ArgoCD Deployment Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --cluster-type TYPE      Type de cluster (k3s, minikube, kind)"
    echo "  --environment ENV        Environnement (development, staging, production)"
    echo "  --skip-cluster-setup     Ignorer la configuration du cluster"
    echo "  --skip-argocd            Ignorer l'installation d'ArgoCD"
    echo "  --skip-applications      Ignorer la configuration des applications"
    echo "  --help                   Afficher cette aide"
    echo ""
    echo "EXEMPLES:"
    echo "  $0                                    # Déploiement complet"
    echo "  $0 --cluster-type minikube            # Déploiement sur minikube"
    echo "  $0 --skip-cluster-setup               # Cluster déjà configuré"
    echo "  $0 --environment production            # Déploiement en production"
}

# Fonction principale
main() {
    # Parsing des arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cluster-type)
                CLUSTER_TYPE="$2"
                shift 2
                ;;
            --environment)
                DEPLOY_ENVIRONMENT="$2"
                shift 2
                ;;
            --skip-cluster-setup)
                SKIP_CLUSTER_SETUP="true"
                shift
                ;;
            --skip-argocd)
                SKIP_ARGOCD="true"
                shift
                ;;
            --skip-applications)
                SKIP_APPLICATIONS="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log_info "🚀 Déploiement VIRIDA Kubernetes + ArgoCD - Cluster: $CLUSTER_TYPE, Environnement: $DEPLOY_ENVIRONMENT"
    
    # Vérification des prérequis
    check_prerequisites
    
    # Configuration du cluster
    setup_kubernetes_cluster
    
    # Installation d'ArgoCD
    install_argocd
    
    # Configuration des applications
    setup_argocd_applications
    
    # Configuration du monitoring
    setup_monitoring
    
    # Configuration de l'ingress
    setup_ingress
    
    # Configuration des secrets
    setup_secrets
    
    # Tests de validation
    run_validation_tests
    
    # Informations de déploiement
    show_deployment_info
}

# Exécution du script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

