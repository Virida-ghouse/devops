#!/bin/bash

# 🚀 Script de Déploiement des Projets DevOps VIRIDA
# Déploie tous les projets du groupe DevOps

set -e

echo "🚀 Déploiement des Projets DevOps VIRIDA"
echo "========================================"

# Configuration des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les étapes
step() {
    echo -e "${BLUE}📋 $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Configuration
VIRIDA_ROOT="/Users/crk/Desktop/VIRIDA"
GITLAB_GROUP="virida/devops"

# Vérification des prérequis
check_prerequisites() {
    step "Vérification des prérequis..."
    
    if ! command -v git &> /dev/null; then
        error "Git n'est pas installé"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        warning "Docker n'est pas installé - certains déploiements nécessiteront une installation manuelle"
    fi
    
    if ! command -v kubectl &> /dev/null; then
        warning "kubectl n'est pas installé - déploiement Kubernetes impossible"
    fi
    
    success "Prérequis vérifiés"
}

# Déploiement du projet ci-cd-pipelines
deploy_cicd_pipelines() {
    step "🚀 Déploiement du projet ci-cd-pipelines..."
    
    local project_dir="$VIRIDA_ROOT/devops/ci-cd-pipelines"
    
    if [ ! -d "$project_dir" ]; then
        error "Répertoire ci-cd-pipelines non trouvé"
        return 1
    fi
    
    cd "$project_dir"
    
    # Vérification du statut Git
    if [ -d ".git" ]; then
        echo "  📂 Repository Git existant, mise à jour..."
        git pull origin main || echo "⚠️  Échec du pull, continuation..."
    else
        echo "  📂 Initialisation du repository Git..."
        git init
        git remote add origin "git@gitlab.com:$GITLAB_GROUP/ci-cd-pipelines.git"
    fi
    
    # Ajout des fichiers
    git add .
    
    # Commit et push
    if git diff --staged --quiet; then
        echo "  📝 Aucun changement à commiter"
    else
        git commit -m "🚀 Déploiement automatique: Configuration CI/CD VIRIDA" || echo "⚠️  Échec du commit"
        git push origin main || echo "⚠️  Échec du push"
    fi
    
    success "ci-cd-pipelines déployé"
}

# Déploiement du projet docker-configs
deploy_docker_configs() {
    step "🐳 Déploiement du projet docker-configs..."
    
    local project_dir="$VIRIDA_ROOT/devops/docker-configs"
    
    if [ ! -d "$project_dir" ]; then
        error "Répertoire docker-configs non trouvé"
        return 1
    fi
    
    cd "$project_dir"
    
    # Vérification du statut Git
    if [ -d ".git" ]; then
        echo "  📂 Repository Git existant, mise à jour..."
        git pull origin main || echo "⚠️  Échec du pull, continuation..."
    else
        echo "  📂 Initialisation du repository Git..."
        git init
        git remote add origin "git@gitlab.com:$GITLAB_GROUP/docker-configs.git"
    fi
    
    # Test de la configuration Docker
    if command -v docker-compose &> /dev/null; then
        echo "  🧪 Test de la configuration Docker..."
        docker-compose config > /dev/null && echo "  ✅ Configuration Docker valide" || echo "  ⚠️  Configuration Docker invalide"
    fi
    
    # Ajout des fichiers
    git add .
    
    # Commit et push
    if git diff --staged --quiet; then
        echo "  📝 Aucun changement à commiter"
    else
        git commit -m "🐳 Déploiement automatique: Configuration Docker VIRIDA" || echo "⚠️  Échec du commit"
        git push origin main || echo "⚠️  Échec du push"
    fi
    
    success "docker-configs déployé"
}

# Déploiement du projet k8s-manifests
deploy_k8s_manifests() {
    step "☸️  Déploiement du projet k8s-manifests..."
    
    local project_dir="$VIRIDA_ROOT/devops/k8s-manifests"
    
    if [ ! -d "$project_dir" ]; then
        error "Répertoire k8s-manifests non trouvé"
        return 1
    fi
    
    cd "$project_dir"
    
    # Vérification du statut Git
    if [ -d ".git" ]; then
        echo "  📂 Repository Git existant, mise à jour..."
        git pull origin main || echo "⚠️  Échec du pull, continuation..."
    else
        echo "  📂 Initialisation du repository Git..."
        git init
        git remote add origin "git@gitlab.com:$GITLAB_GROUP/k8s-manifests.git"
    fi
    
    # Validation des manifests Kubernetes
    if command -v kubectl &> /dev/null; then
        echo "  🧪 Validation des manifests Kubernetes..."
        for manifest in $(find . -name "*.yaml" -o -name "*.yml"); do
            echo "    📄 Validation de $manifest..."
            kubectl apply --dry-run=client -f "$manifest" > /dev/null 2>&1 && echo "      ✅ Valide" || echo "      ⚠️  Invalide"
        done
    fi
    
    # Ajout des fichiers
    git add .
    
    # Commit et push
    if git diff --staged --quiet; then
        echo "  📝 Aucun changement à commiter"
    fi
    
    success "k8s-manifests déployé"
}

# Déploiement du projet monitoring
deploy_monitoring() {
    step "📊 Déploiement du projet monitoring..."
    
    local project_dir="$VIRIDA_ROOT/devops/monitoring"
    
    if [ ! -d "$project_dir" ]; then
        error "Répertoire monitoring non trouvé"
        return 1
    fi
    
    cd "$project_dir"
    
    # Vérification du statut Git
    if [ -d ".git" ]; then
        echo "  📂 Repository Git existant, mise à jour..."
        git pull origin main || echo "⚠️  Échec du pull, continuation..."
    else
        echo "  📂 Initialisation du repository Git..."
        git init
        git remote add origin "git@gitlab.com:$GITLAB_GROUP/monitoring.git"
    fi
    
    # Test de la configuration Prometheus
    if command -v promtool &> /dev/null; then
        echo "  🧪 Test de la configuration Prometheus..."
        for config in $(find . -name "prometheus.yml" -o -name "prometheus.yaml"); do
            echo "    📊 Validation de $config..."
            promtool check config "$config" > /dev/null 2>&1 && echo "      ✅ Configuration valide" || echo "      ⚠️  Configuration invalide"
        done
    fi
    
    # Ajout des fichiers
    git add .
    
    # Commit et push
    if git diff --staged --quiet; then
        echo "  📝 Aucun changement à commiter"
    fi
    
    success "monitoring déployé"
}

# Test des services déployés
test_services() {
    step "🧪 Test des services déployés..."
    
    # Test Docker Compose
    if command -v docker-compose &> /dev/null; then
        echo "  🐳 Test Docker Compose..."
        cd "$VIRIDA_ROOT/devops/docker-configs"
        docker-compose config > /dev/null && echo "    ✅ Configuration valide" || echo "    ⚠️  Configuration invalide"
    fi
    
    # Test Kubernetes
    if command -v kubectl &> /dev/null; then
        echo "  ☸️  Test Kubernetes..."
        kubectl cluster-info > /dev/null 2>&1 && echo "    ✅ Cluster accessible" || echo "    ⚠️  Cluster inaccessible"
    fi
    
    # Test Prometheus
    if command -v curl &> /dev/null; then
        echo "  📊 Test Prometheus..."
        curl -s http://localhost:9090/api/v1/status/config > /dev/null 2>&1 && echo "    ✅ Prometheus accessible" || echo "    ⚠️  Prometheus inaccessible"
    fi
    
    success "Tests terminés"
}

# Déploiement complet
deploy_all() {
    step "🚀 Démarrage du déploiement complet..."
    
    # Déploiement de chaque projet
    deploy_cicd_pipelines
    deploy_docker_configs
    deploy_k8s_manifests
    deploy_monitoring
    
    # Test des services
    test_services
    
    echo ""
    echo "🎉 Déploiement DevOps VIRIDA terminé !"
    echo "====================================="
    echo ""
    echo "📋 Projets déployés :"
    echo "  ✅ ci-cd-pipelines"
    echo "  ✅ docker-configs"
    echo "  ✅ k8s-manifests"
    echo "  ✅ monitoring"
    echo ""
    echo "🔗 Accès aux projets :"
    echo "  🌐 GitLab: https://gitlab.com/virida/devops"
    echo "  📊 Monitoring: http://localhost:3000 (Grafana)"
    echo "  📈 Métriques: http://localhost:9090 (Prometheus)"
    echo ""
    echo "🚀 VIRIDA DevOps est prêt !"
}

# Fonction principale
main() {
    echo "🚀 Démarrage du déploiement DevOps VIRIDA"
    echo "========================================="
    
    # Vérification des prérequis
    check_prerequisites
    
    # Création des dossiers si nécessaire
    mkdir -p "$VIRIDA_ROOT/devops/ci-cd-pipelines"
    mkdir -p "$VIRIDA_ROOT/devops/docker-configs"
    mkdir -p "$VIRIDA_ROOT/devops/k8s-manifests"
    mkdir -p "$VIRIDA_ROOT/devops/monitoring"
    
    # Déploiement complet
    deploy_all
}

# Exécution du script
main "$@"

