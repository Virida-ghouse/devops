#!/bin/bash

# 🚀 VIRIDA Services Deployment Script
# Déploie tous les services VIRIDA via Jenkins

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
JENKINS_URL="http://localhost:30080"
JENKINS_USER="admin"
JENKINS_PASSWORD="admin"
VIRIDA_NAMESPACE="virida-apps"

echo -e "${BLUE}🚀 Déploiement des Services VIRIDA via Jenkins${NC}"
echo "=================================================="

# Fonction pour afficher les messages
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
    
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl n'est pas installé"
        exit 1
    fi
    
    if ! kubectl get namespace jenkins &> /dev/null; then
        log_error "Namespace Jenkins n'existe pas"
        exit 1
    fi
    
    log_success "Prérequis vérifiés"
}

# Création du namespace VIRIDA
create_virida_namespace() {
    log_info "Création du namespace VIRIDA..."
    
    if ! kubectl get namespace $VIRIDA_NAMESPACE &> /dev/null; then
        kubectl create namespace $VIRIDA_NAMESPACE
        log_success "Namespace $VIRIDA_NAMESPACE créé"
    else
        log_info "Namespace $VIRIDA_NAMESPACE existe déjà"
    fi
}

# Déploiement des services VIRIDA
deploy_virida_services() {
    log_info "Déploiement des services VIRIDA..."
    
    # Frontend 3D Visualizer
    log_info "Déploiement du Frontend 3D Visualizer..."
    kubectl apply -f k8s/virida-services/frontend-3d.yaml -n $VIRIDA_NAMESPACE
    
    # Backend API Gateway
    log_info "Déploiement du Backend API Gateway..."
    kubectl apply -f k8s/virida-services/backend-api-gateway.yaml -n $VIRIDA_NAMESPACE
    
    # AI/ML Prediction Engine
    log_info "Déploiement de l'AI/ML Prediction Engine..."
    kubectl apply -f k8s/virida-services/ai-ml-prediction.yaml -n $VIRIDA_NAMESPACE
    
    log_success "Services VIRIDA déployés"
}

# Configuration des pipelines Jenkins
setup_jenkins_pipelines() {
    log_info "Configuration des pipelines Jenkins..."
    
    # Attendre que Jenkins soit prêt
    log_info "Attente que Jenkins soit prêt..."
    kubectl wait --for=condition=ready pod -l app=jenkins -n jenkins --timeout=300s
    
    # Récupérer le token Jenkins
    log_info "Récupération du token Jenkins..."
    JENKINS_TOKEN=$(kubectl exec -n jenkins deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "admin")
    
    log_success "Jenkins est prêt sur $JENKINS_URL"
    log_info "Token initial: $JENKINS_TOKEN"
}

# Déploiement du monitoring
deploy_monitoring() {
    log_info "Déploiement du monitoring..."
    
    # Prometheus
    kubectl apply -f k8s/monitoring/prometheus.yaml -n $VIRIDA_NAMESPACE
    
    # Grafana
    kubectl apply -f k8s/monitoring/grafana.yaml -n $VIRIDA_NAMESPACE
    
    log_success "Monitoring déployé"
}

# Vérification du déploiement
verify_deployment() {
    log_info "Vérification du déploiement..."
    
    echo -e "\n${BLUE}📊 État des Services:${NC}"
    kubectl get pods -n $VIRIDA_NAMESPACE
    
    echo -e "\n${BLUE}🌐 Services exposés:${NC}"
    kubectl get svc -n $VIRIDA_NAMESPACE
    
    echo -e "\n${BLUE}📈 Monitoring:${NC}"
    kubectl get pods -n $VIRIDA_NAMESPACE -l app=prometheus
    kubectl get pods -n $VIRIDA_NAMESPACE -l app=grafana
}

# Affichage des informations d'accès
show_access_info() {
    echo -e "\n${GREEN}🎉 Déploiement VIRIDA terminé !${NC}"
    echo "=================================================="
    echo -e "${BLUE}🔗 Accès aux Services:${NC}"
    echo "• Jenkins: $JENKINS_URL"
    echo "• Frontend 3D: http://localhost:30081"
    echo "• Backend API: http://localhost:30082"
    echo "• AI/ML Engine: http://localhost:30083"
    echo "• Prometheus: http://localhost:30084"
    echo "• Grafana: http://localhost:30085"
    echo ""
    echo -e "${YELLOW}📝 Prochaines étapes:${NC}"
    echo "1. Accéder à Jenkins et configurer les pipelines"
    echo "2. Tester les services déployés"
    echo "3. Configurer les webhooks Gitea"
    echo "4. Lancer le premier build"
}

# Fonction principale
main() {
    check_prerequisites
    create_virida_namespace
    deploy_virida_services
    setup_jenkins_pipelines
    deploy_monitoring
    verify_deployment
    show_access_info
}

# Exécution
main "$@"

