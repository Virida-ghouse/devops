#!/bin/bash

# 🚀 VIRIDA Jenkins Clever Cloud Deployment Script
# Script de déploiement de Jenkins CI/CD sur Clever Cloud

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$PROJECT_ROOT/k8s"
JENKINS_DIR="$PROJECT_ROOT/k8s/jenkins"
PIPELINES_DIR="$PROJECT_ROOT/jenkins-pipelines"

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables d'environnement
DEPLOY_ENVIRONMENT="${DEPLOY_ENVIRONMENT:-clever-cloud}"
SKIP_CLUSTER_SETUP="${SKIP_CLUSTER_SETUP:-false}"
SKIP_JENKINS="${SKIP_JENKINS:-false}"
SKIP_PIPELINES="${SKIP_PIPELINES:-false}"
CLEANUP_IMAGES="${CLEANUP_IMAGES:-false}"

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
    
    # Vérifier la connectivité au cluster
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Impossible de se connecter au cluster Kubernetes"
        log_info "Veuillez démarrer votre cluster Kubernetes ou configurer le contexte"
        exit 1
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

# Configuration du cluster Clever Cloud
setup_clever_cloud_cluster() {
    if [ "$SKIP_CLUSTER_SETUP" = "true" ]; then
        log_warning "Configuration du cluster ignorée"
        return 0
    fi
    
    log_info "Configuration du cluster Clever Cloud..."
    
    # Appliquer la configuration Clever Cloud
    log_info "Application de la configuration Clever Cloud..."
    kubectl apply -f "$K8S_DIR/clever-cloud/clever-cloud-config.yaml"
    
    # Vérifier les namespaces
    log_info "Vérification des namespaces..."
    kubectl get namespaces | grep -E "(virida|jenkins)" || {
        log_warning "Namespaces VIRIDA non trouvés, création..."
        kubectl apply -f "$K8S_DIR/clever-cloud/clever-cloud-config.yaml"
    }
    
    # Configuration des secrets Clever Cloud
    log_info "Configuration des secrets Clever Cloud..."
    setup_clever_cloud_secrets
    
    log_success "Cluster Clever Cloud configuré"
}

# Configuration des secrets Clever Cloud
setup_clever_cloud_secrets() {
    log_info "Configuration des secrets Clever Cloud..."
    
    # Créer les secrets de base
    kubectl create secret generic clever-cloud-secrets \
        --from-literal=cc-app-domain="${CC_APP_DOMAIN:-virida.cleverapps.io}" \
        --from-literal=cc-region="${CC_REGION:-par}" \
        --from-literal=cc-environment="${CC_ENVIRONMENT:-production}" \
        --namespace virida-system \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Créer les secrets Jenkins
    kubectl create secret generic jenkins-secrets \
        --from-literal=jenkins-admin-password="${JENKINS_ADMIN_PASSWORD:-admin123}" \
        --from-literal=gitea-token="${GITEA_TOKEN:-admin123}" \
        --from-literal=docker-registry-credentials="${DOCKER_REGISTRY_CREDENTIALS:-admin123}" \
        --namespace jenkins \
        --dry-run=client -o yaml | kubectl apply -f -
    
    log_success "Secrets Clever Cloud configurés"
}

# Installation de Jenkins
install_jenkins() {
    if [ "$SKIP_JENKINS" = "true" ]; then
        log_warning "Installation de Jenkins ignorée"
        return 0
    fi
    
    log_info "Installation de Jenkins..."
    
    # Créer le namespace Jenkins s'il n'existe pas
    kubectl create namespace jenkins --dry-run=client -o yaml | kubectl apply -f -
    
    # Installer Jenkins
    log_info "Déploiement de Jenkins..."
    kubectl apply -f "$JENKINS_DIR/jenkins-install.yaml"
    
    # Attendre que Jenkins soit prêt
    log_info "Attente que Jenkins soit prêt..."
    kubectl wait --for=condition=available --timeout=600s deployment/jenkins -n jenkins
    
    # Récupérer le mot de passe admin
    local admin_password=$(kubectl -n jenkins get secret jenkins-secrets -o jsonpath="{.data.jenkins-admin-password}" | base64 -d)
    echo "$admin_password" > "$PROJECT_ROOT/.jenkins-admin-password"
    
    log_success "Jenkins installé et configuré"
    log_info "Mot de passe admin Jenkins: $admin_password"
}

# Configuration des pipelines Jenkins
setup_jenkins_pipelines() {
    if [ "$SKIP_PIPELINES" = "true" ]; then
        log_warning "Configuration des pipelines ignorée"
        return 0
    fi
    
    log_info "Configuration des pipelines Jenkins..."
    
    # Attendre que Jenkins soit complètement prêt
    sleep 60
    
    # Créer les jobs Jenkins
    log_info "Création des jobs Jenkins..."
    create_jenkins_jobs
    
    log_success "Pipelines Jenkins configurés"
}

# Création des jobs Jenkins
create_jenkins_jobs() {
    log_info "Création des jobs Jenkins..."
    
    # Job Frontend 3D Visualizer
    create_jenkins_job "frontend-3d-visualizer" \
        "VIRIDA Frontend 3D Visualizer" \
        "Pipeline pour le service Frontend 3D Visualizer" \
        "main" \
        "https://gitea.virida.local/frontend/3d-visualizer.git"
    
    # Job Backend API Gateway
    create_jenkins_job "backend-api-gateway" \
        "VIRIDA Backend API Gateway" \
        "Pipeline pour le service Backend API Gateway" \
        "main" \
        "https://gitea.virida.local/backend/api-gateway.git"
    
    # Job AI/ML Prediction Engine
    create_jenkins_job "ai-ml-prediction-engine" \
        "VIRIDA AI/ML Prediction Engine" \
        "Pipeline pour le service AI/ML Prediction Engine" \
        "main" \
        "https://gitea.virida.local/ai-ml/prediction-engine.git"
    
    log_success "Jobs Jenkins créés"
}

# Création d'un job Jenkins
create_jenkins_job() {
    local job_name="$1"
    local display_name="$2"
    local description="$3"
    local branch="$4"
    local repo_url="$5"
    
    log_info "Création du job: $display_name"
    
    # Créer le job via l'API Jenkins
    local jenkins_url="http://localhost:8080"
    local admin_password=$(cat "$PROJECT_ROOT/.jenkins-admin-password" 2>/dev/null || echo "admin123")
    
    # Configuration XML du job
    local job_config="
    <?xml version='1.1' encoding='UTF-8'?>
    <flow-definition plugin='workflow-job@1289.vd1c337fd5354'>
        <description>$description</description>
        <keepDependencies>false</keepDependencies>
        <properties/>
        <definition class='org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition' plugin='workflow-cps@3697.vb_470e4543b_dc'>
            <script>
                // Pipeline sera chargé depuis le repository
                checkout([\$class: 'GitSCM', branches: [[name: '*/$branch']], userRemoteConfigs: [[url: '$repo_url', credentialsId: 'gitea-credentials']]])
                load 'Jenkinsfile'
            </script>
            <sandbox>true</sandbox>
        </definition>
        <triggers>
            <hudson.triggers.SCMTrigger>
                <spec>H/5 * * * *</spec>
            </hudson.triggers.SCMTrigger>
        </triggers>
        <disabled>false</disabled>
    </flow-definition>
    "
    
    # Créer le job via l'API REST
    curl -X POST \
        -u "admin:$admin_password" \
        -H "Content-Type: application/xml" \
        -d "$job_config" \
        "$jenkins_url/createItem?name=$job_name" || {
        log_warning "Impossible de créer le job $job_name via API, création manuelle requise"
    }
}

# Configuration de l'ingress et du monitoring
setup_ingress_monitoring() {
    log_info "Configuration de l'ingress et du monitoring..."
    
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
    kubectl apply -f "$K8S_DIR/ingress/" 2>/dev/null || {
        log_warning "Aucun fichier ingress trouvé, création manuelle requise"
    }
    
    # Configuration du monitoring
    setup_monitoring
    
    log_success "Ingress et monitoring configurés"
}

# Configuration du monitoring
setup_monitoring() {
    log_info "Configuration du monitoring..."
    
    # Déployer Prometheus
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace virida-monitoring \
        --create-namespace \
        --set prometheus.prometheusSpec.retention=7d \
        --set grafana.adminPassword=admin \
        --set grafana.service.type=ClusterIP
    
    log_success "Monitoring configuré"
}

# Tests de validation
run_validation_tests() {
    log_info "Exécution des tests de validation..."
    
    # Vérifier les pods
    log_info "Vérification des pods..."
    kubectl get pods --all-namespaces | grep -E "(virida|jenkins)"
    
    # Vérifier les services
    log_info "Vérification des services..."
    kubectl get services --all-namespaces | grep -E "(virida|jenkins)"
    
    # Vérifier les ingress
    log_info "Vérification des ingress..."
    kubectl get ingress --all-namespaces
    
    # Tests de connectivité Jenkins
    log_info "Tests de connectivité Jenkins..."
    local jenkins_service=$(kubectl get service -n jenkins -l app.kubernetes.io/name=jenkins -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$jenkins_service" ]; then
        kubectl port-forward -n jenkins service/$jenkins_service 8080:80 &
        local port_forward_pid=$!
        sleep 10
        
        if curl -s http://localhost:8080 > /dev/null; then
            log_success "Service Jenkins accessible"
        else
            log_warning "Service Jenkins non accessible"
        fi
        
        kill $port_forward_pid 2>/dev/null || true
    fi
    
    log_success "Tests de validation terminés"
}

# Nettoyage
cleanup() {
    log_info "Nettoyage..."
    
    if [ "$CLEANUP_IMAGES" = "true" ]; then
        log_info "Nettoyage des images Docker..."
        docker image prune -f
        
        # Supprimer les images VIRIDA non utilisées
        docker images | grep "virida-" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
    fi
    
    log_success "Nettoyage terminé"
}

# Affichage des informations de déploiement
show_deployment_info() {
    log_success "Déploiement Jenkins VIRIDA sur Clever Cloud terminé !"
    echo ""
    echo "☁️ **Infrastructure Clever Cloud**"
    echo "=================================="
    echo "Environnement:     $DEPLOY_ENVIRONMENT"
    echo "Namespaces:        virida-system, virida-apps, virida-monitoring, jenkins"
    echo ""
    echo "🚀 **Jenkins CI/CD**"
    echo "URL:               http://localhost:8080 (port-forward)"
    echo "Username:          admin"
    echo "Password:          $(cat $PROJECT_ROOT/.jenkins-admin-password 2>/dev/null || echo 'non configuré')"
    echo ""
    echo "📊 **Monitoring**"
    echo "Prometheus:        http://localhost:9090 (port-forward)"
    echo "Grafana:           http://localhost:3000 (port-forward)"
    echo "  - Username:      admin"
    echo "  - Password:      admin"
    echo ""
    echo "🔧 **Commandes Utiles**"
    echo "Port-forward Jenkins:   kubectl port-forward -n jenkins service/jenkins 8080:80"
    echo "Port-forward Grafana:  kubectl port-forward -n virida-monitoring service/prometheus-grafana 3000:80"
    echo "Statut des pods:       kubectl get pods --all-namespaces"
    echo "Logs Jenkins:          kubectl logs -n jenkins deployment/jenkins"
    echo ""
    echo "📚 **Documentation**"
    echo "Jenkins:           https://www.jenkins.io/doc/"
    echo "Kubernetes:        https://kubernetes.io/docs/"
    echo "Clever Cloud:      https://www.clever-cloud.com/doc/"
}

# Affichage de l'aide
show_help() {
    echo "🚀 VIRIDA Jenkins Clever Cloud Deployment Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --environment ENV        Environnement (défaut: clever-cloud)"
    echo "  --skip-cluster-setup     Ignorer la configuration du cluster"
    echo "  --skip-jenkins           Ignorer l'installation de Jenkins"
    echo "  --skip-pipelines         Ignorer la configuration des pipelines"
    echo "  --cleanup-images         Nettoyer les images après déploiement"
    echo "  --help                   Afficher cette aide"
    echo ""
    echo "EXEMPLES:"
    echo "  $0                                    # Déploiement complet"
    echo "  $0 --skip-cluster-setup              # Cluster déjà configuré"
    echo "  $0 --environment production           # Déploiement en production"
}

# Fonction principale
main() {
    # Parsing des arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --environment)
                DEPLOY_ENVIRONMENT="$2"
                shift 2
                ;;
            --skip-cluster-setup)
                SKIP_CLUSTER_SETUP="true"
                shift
                ;;
            --skip-jenkins)
                SKIP_JENKINS="true"
                shift
                ;;
            --skip-pipelines)
                SKIP_PIPELINES="true"
                shift
                ;;
            --cleanup-images)
                CLEANUP_IMAGES="true"
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
    
    log_info "🚀 Déploiement Jenkins VIRIDA sur Clever Cloud - Environnement: $DEPLOY_ENVIRONMENT"
    
    # Vérification des prérequis
    check_prerequisites
    
    # Configuration du cluster
    setup_clever_cloud_cluster
    
    # Installation de Jenkins
    install_jenkins
    
    # Configuration des pipelines
    setup_jenkins_pipelines
    
    # Configuration de l'ingress et monitoring
    setup_ingress_monitoring
    
    # Tests de validation
    run_validation_tests
    
    # Nettoyage
    cleanup
    
    # Informations de déploiement
    show_deployment_info
}

# Exécution du script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

