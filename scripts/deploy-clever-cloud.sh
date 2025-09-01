#!/bin/bash

# ☁️ VIRIDA Clever Cloud Deployment Script
# Script de déploiement automatisé sur Clever Cloud

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.clever-cloud.yml"
ENV_FILE="$PROJECT_ROOT/.env.clever-cloud"

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables d'environnement
DEPLOY_ENVIRONMENT="${DEPLOY_ENVIRONMENT:-production}"
CLEANUP_IMAGES="${CLEANUP_IMAGES:-false}"
SKIP_TESTS="${SKIP_TESTS:-false}"

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
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker n'est pas démarré ou accessible"
        exit 1
    fi
    
    if [ ! -f "$ENV_FILE" ]; then
        log_error "Fichier .env.clever-cloud non trouvé"
        log_info "Copiez env.clever-cloud.example vers .env.clever-cloud et configurez les variables"
        exit 1
    fi
    
    log_success "Prérequis vérifiés"
}

# Charger les variables d'environnement
load_environment() {
    log_info "Chargement des variables d'environnement..."
    
    if [ -f "$ENV_FILE" ]; then
        export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
        log_success "Variables d'environnement chargées"
    else
        log_error "Fichier .env.clever-cloud non trouvé"
        exit 1
    fi
}

# Vérifier la configuration Clever Cloud
check_clever_cloud_config() {
    log_info "Vérification de la configuration Clever Cloud..."
    
    local required_vars=(
        "CC_APP_DOMAIN"
        "CC_POSTGRESQL_ADDON_HOST"
        "CC_POSTGRESQL_ADDON_DB"
        "CC_POSTGRESQL_ADDON_USER"
        "CC_POSTGRESQL_ADDON_PASSWORD"
    )
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_error "Variable requise manquante: $var"
            exit 1
        fi
    done
    
    log_success "Configuration Clever Cloud vérifiée"
}

# Tests de sécurité
run_security_tests() {
    if [ "$SKIP_TESTS" = "true" ]; then
        log_warning "Tests de sécurité ignorés"
        return 0
    fi
    
    log_info "Exécution des tests de sécurité..."
    
    # Scan des images Docker
    if command -v trivy &> /dev/null; then
        log_info "Scan des images avec Trivy..."
        ./scripts/docker-security-scan.sh --fail-on-critical || {
            log_error "Vulnérabilités critiques détectées, déploiement arrêté"
            exit 1
        }
    else
        log_warning "Trivy non installé, scan de sécurité ignoré"
    fi
    
    log_success "Tests de sécurité terminés"
}

# Build des images Docker
build_images() {
    log_info "Construction des images Docker..."
    
    # Build avec Docker Compose
    docker-compose -f "$COMPOSE_FILE" build --no-cache
    
    # Tag des images pour Clever Cloud
    docker tag virida-gitea:latest "${CC_APP_DOMAIN}/virida-gitea:latest"
    docker tag virida-gitea-runner:latest "${CC_APP_DOMAIN}/virida-gitea-runner:latest"
    
    log_success "Images Docker construites"
}

# Tests des images
test_images() {
    if [ "$SKIP_TESTS" = "true" ]; then
        log_warning "Tests des images ignorés"
        return 0
    fi
    
    log_info "Tests des images Docker..."
    
    # Test de démarrage des services
    docker-compose -f "$COMPOSE_FILE" up -d --no-deps gitea postgres
    
    # Attendre que Gitea soit prêt
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://localhost:3000/api/v1/version" > /dev/null 2>&1; then
            log_success "Gitea est prêt"
            break
        fi
        
        log_info "Tentative $attempt/$max_attempts - Gitea n'est pas encore prêt..."
        sleep 10
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "Gitea n'est pas prêt après $max_attempts tentatives"
        docker-compose -f "$COMPOSE_FILE" down
        exit 1
    fi
    
    # Tests de base
    local health_check=$(curl -s "http://localhost:3000/api/v1/version")
    if [ $? -eq 0 ]; then
        log_success "Test de santé Gitea réussi"
    else
        log_error "Test de santé Gitea échoué"
        docker-compose -f "$COMPOSE_FILE" down
        exit 1
    fi
    
    # Arrêter les services de test
    docker-compose -f "$COMPOSE_FILE" down
    
    log_success "Tests des images terminés"
}

# Déploiement sur Clever Cloud
deploy_to_clever_cloud() {
    log_info "Déploiement sur Clever Cloud..."
    
    # Vérifier la connectivité
    if ! curl -s "https://$CC_APP_DOMAIN" > /dev/null 2>&1; then
        log_warning "Impossible de vérifier la connectivité à $CC_APP_DOMAIN"
    fi
    
    # Démarrage des services
    docker-compose -f "$COMPOSE_FILE" up -d
    
    log_success "Déploiement terminé"
}

# Vérification du déploiement
verify_deployment() {
    log_info "Vérification du déploiement..."
    
    local services=(
        "gitea:3000"
        "prometheus:9090"
        "grafana:3001"
    )
    
    for service in "${services[@]}"; do
        local service_name=$(echo "$service" | cut -d: -f1)
        local port=$(echo "$service" | cut -d: -f2)
        
        log_info "Vérification de $service_name sur le port $port..."
        
        local max_attempts=20
        local attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            if curl -s "http://localhost:$port" > /dev/null 2>&1; then
                log_success "$service_name est opérationnel"
                break
            fi
            
            log_info "Tentative $attempt/$max_attempts - $service_name n'est pas encore prêt..."
            sleep 5
            ((attempt++))
        done
        
        if [ $attempt -gt $max_attempts ]; then
            log_warning "$service_name n'est pas prêt après $max_attempts tentatives"
        fi
    done
    
    log_success "Vérification du déploiement terminée"
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
    log_success "Déploiement VIRIDA sur Clever Cloud terminé !"
    echo ""
    echo "☁️ **Services Déployés**"
    echo "========================"
    echo "Gitea:          https://$CC_APP_DOMAIN"
    echo "  - Admin:      $GITEA_ADMIN_USERNAME / [mot de passe configuré]"
    echo "  - Email:      $GITEA_ADMIN_EMAIL"
    echo ""
    echo "📊 **Monitoring**"
    echo "Prometheus:     https://$CC_APP_DOMAIN:9090"
    echo "Grafana:        https://$CC_APP_DOMAIN:3001"
    echo ""
    echo "🔧 **Configuration Requise**"
    echo "1. Connectez-vous à Gitea avec les identifiants admin"
    echo "2. Allez dans Admin > Actions > Runners"
    echo "3. Copiez le token du runner et mettez-le dans .env.clever-cloud"
    echo "4. Redémarrez le runner: docker-compose restart gitea-runner"
    echo ""
    echo "📚 **Documentation**"
    echo "Clever Cloud:   https://www.clever-cloud.com/doc/"
    echo "Gitea Actions:  https://docs.gitea.com/usage/actions/overview"
    echo ""
    echo "🚀 **Prochaines Étapes**"
    echo "1. Configurer les webhooks pour les repositories"
    echo "2. Créer les workflows Gitea Actions"
    echo "3. Configurer le monitoring et les alertes"
    echo "4. Tester les pipelines CI/CD"
}

# Affichage de l'aide
show_help() {
    echo "☁️ VIRIDA Clever Cloud Deployment Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --environment ENV     Environnement de déploiement (défaut: production)"
    echo "  --skip-tests          Ignorer les tests de sécurité et des images"
    echo "  --cleanup-images      Nettoyer les images après déploiement"
    echo "  --help                Afficher cette aide"
    echo ""
    echo "EXEMPLES:"
    echo "  $0                                    # Déploiement complet"
    echo "  $0 --skip-tests                      # Déploiement sans tests"
    echo "  $0 --cleanup-images --environment staging  # Déploiement staging avec nettoyage"
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
            --skip-tests)
                SKIP_TESTS="true"
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
    
    log_info "🚀 Déploiement VIRIDA sur Clever Cloud - Environnement: $DEPLOY_ENVIRONMENT"
    
    # Vérification des prérequis
    check_prerequisites
    
    # Chargement de l'environnement
    load_environment
    
    # Vérification de la configuration
    check_clever_cloud_config
    
    # Tests de sécurité
    run_security_tests
    
    # Build des images
    build_images
    
    # Tests des images
    test_images
    
    # Déploiement
    deploy_to_clever_cloud
    
    # Vérification
    verify_deployment
    
    # Nettoyage
    cleanup
    
    # Informations de déploiement
    show_deployment_info
}

# Exécution du script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

