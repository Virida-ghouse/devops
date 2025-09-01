#!/bin/bash

# 🚀 VIRIDA Docker Build Automation Script
# Script d'automatisation pour les builds Docker de tous les services

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCKERFILES_DIR="$PROJECT_ROOT/dockerfiles"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.dev.yml"

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables d'environnement
BUILD_TARGET="${BUILD_TARGET:-all}"
BUILD_PLATFORM="${BUILD_PLATFORM:-linux/amd64,linux/arm64}"
PUSH_IMAGES="${PUSH_IMAGES:-false}"
REGISTRY_URL="${REGISTRY_URL:-registry.virida.local}"
CACHE_FROM="${CACHE_FROM:-false}"
PARALLEL_BUILDS="${PARALLEL_BUILDS:-4}"

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
    
    log_success "Prérequis vérifiés"
}

# Construction d'un service spécifique
build_service() {
    local service_name="$1"
    local dockerfile_path="$2"
    local context_path="$3"
    local build_args="$4"
    
    log_info "Construction de $service_name..."
    
    local build_cmd="docker build"
    
    # Ajouter les arguments de build
    if [ -n "$build_args" ]; then
        build_cmd="$build_cmd $build_args"
    fi
    
    # Ajouter le cache si activé
    if [ "$CACHE_FROM" = "true" ]; then
        build_cmd="$build_cmd --cache-from $REGISTRY_URL/$service_name:latest"
    fi
    
    # Ajouter la plateforme multi-arch
    build_cmd="$build_cmd --platform $BUILD_PLATFORM"
    
    # Ajouter les métadonnées
    build_cmd="$build_cmd --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    build_cmd="$build_cmd --build-arg VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
    build_cmd="$build_cmd --build-arg VERSION=$(git describe --tags --always 2>/dev/null || echo 'dev')"
    
    # Construire l'image
    build_cmd="$build_cmd -t $service_name:latest"
    build_cmd="$build_cmd -t $service_name:$(git rev-parse --short HEAD 2>/dev/null || echo 'dev')"
    
    if [ "$PUSH_IMAGES" = "true" ]; then
        build_cmd="$build_cmd -t $REGISTRY_URL/$service_name:latest"
        build_cmd="$build_cmd -t $REGISTRY_URL/$service_name:$(git rev-parse --short HEAD 2>/dev/null || echo 'dev')"
    fi
    
    build_cmd="$build_cmd -f $dockerfile_path $context_path"
    
    log_info "Commande de build: $build_cmd"
    
    if eval "$build_cmd"; then
        log_success "$service_name construit avec succès"
        
        # Pousser l'image si demandé
        if [ "$PUSH_IMAGES" = "true" ]; then
            push_image "$service_name"
        fi
    else
        log_error "Échec de la construction de $service_name"
        return 1
    fi
}

# Pousser une image vers le registry
push_image() {
    local service_name="$1"
    
    log_info "Poussée de $service_name vers le registry..."
    
    if docker push "$REGISTRY_URL/$service_name:latest" && \
       docker push "$REGISTRY_URL/$service_name:$(git rev-parse --short HEAD 2>/dev/null || echo 'dev')"; then
        log_success "$service_name poussé avec succès"
    else
        log_error "Échec de la poussée de $service_name"
        return 1
    fi
}

# Construction des services frontend
build_frontend_services() {
    log_info "Construction des services frontend..."
    
    # 3D Visualizer
    if [ -f "$PROJECT_ROOT/frontend/3d-visualizer/package.json" ]; then
        build_service "virida-3d-visualizer" \
                     "$DOCKERFILES_DIR/frontend/3d-visualizer/Dockerfile" \
                     "$PROJECT_ROOT/frontend/3d-visualizer" \
                     "--target dev"
    else
        log_warning "3D Visualizer non trouvé, ignoré"
    fi
    
    # Dashboard
    if [ -f "$PROJECT_ROOT/frontend/dashboard/package.json" ]; then
        build_service "virida-dashboard" \
                     "$DOCKERFILES_DIR/frontend/dashboard/Dockerfile" \
                     "$PROJECT_ROOT/frontend/dashboard" \
                     "--target dev"
    else
        log_warning "Dashboard non trouvé, ignoré"
    fi
}

# Construction des services backend
build_backend_services() {
    log_info "Construction des services backend..."
    
    # API Gateway
    if [ -f "$PROJECT_ROOT/backend/api-gateway/package.json" ]; then
        build_service "virida-api-gateway" \
                     "$DOCKERFILES_DIR/backend/api-gateway/Dockerfile" \
                     "$PROJECT_ROOT/backend/api-gateway" \
                     "--target dev"
    else
        log_warning "API Gateway non trouvé, ignoré"
    fi
    
    # User Service
    if [ -f "$PROJECT_ROOT/backend/user-service/package.json" ]; then
        build_service "virida-user-service" \
                     "$DOCKERFILES_DIR/backend/user-service/Dockerfile" \
                     "$PROJECT_ROOT/backend/user-service" \
                     "--target dev"
    else
        log_warning "User Service non trouvé, ignoré"
    fi
}

# Construction des services AI/ML
build_ai_ml_services() {
    log_info "Construction des services AI/ML..."
    
    # Prediction Engine
    if [ -f "$PROJECT_ROOT/ai-ml/prediction-engine/requirements.txt" ]; then
        build_service "virida-prediction-engine" \
                     "$DOCKERFILES_DIR/ai-ml/prediction-engine/Dockerfile" \
                     "$PROJECT_ROOT/ai-ml/prediction-engine" \
                     "--target dev"
    else
        log_warning "Prediction Engine non trouvé, ignoré"
    fi
}

# Construction des services d'infrastructure
build_infrastructure_services() {
    log_info "Construction des services d'infrastructure..."
    
    # Les services d'infrastructure utilisent des images officielles
    # Pas besoin de construire des images personnalisées
    log_info "Services d'infrastructure utilisent des images officielles"
}

# Construction de tous les services
build_all_services() {
    log_info "Construction de tous les services VIRIDA..."
    
    # Construction séquentielle pour éviter la surcharge
    build_frontend_services
    build_backend_services
    build_ai_ml_services
    build_infrastructure_services
    
    log_success "Tous les services ont été construits"
}

# Construction avec Docker Compose
build_with_compose() {
    log_info "Construction avec Docker Compose..."
    
    if [ -f "$COMPOSE_FILE" ]; then
        docker-compose -f "$COMPOSE_FILE" build --parallel --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
        log_success "Construction Docker Compose terminée"
    else
        log_error "Fichier docker-compose.dev.yml non trouvé"
        return 1
    fi
}

# Nettoyage des images
cleanup_images() {
    log_info "Nettoyage des images Docker..."
    
    # Supprimer les images sans tag
    docker image prune -f
    
    # Supprimer les images VIRIDA non utilisées
    docker images | grep "virida-" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
    
    log_success "Nettoyage terminé"
}

# Affichage de l'aide
show_help() {
    echo "🚀 VIRIDA Docker Build Script"
    echo ""
    echo "Usage: $0 [OPTIONS] [TARGET]"
    echo ""
    echo "TARGETS:"
    echo "  all              Construire tous les services (défaut)"
    echo "  frontend         Construire les services frontend"
    echo "  backend          Construire les services backend"
    echo "  ai-ml            Construire les services AI/ML"
    echo "  infrastructure   Construire les services d'infrastructure"
    echo "  compose          Utiliser Docker Compose pour la construction"
    echo ""
    echo "OPTIONS:"
    echo "  --target TARGET     Cible de construction (dev, prod, all)"
    echo "  --platform PLATFORM Plateformes cibles (défaut: linux/amd64,linux/arm64)"
    echo "  --push              Pousser les images vers le registry"
    echo "  --registry URL      URL du registry (défaut: registry.virida.local)"
    echo "  --cache-from        Utiliser le cache du registry"
    echo "  --parallel N        Nombre de builds parallèles (défaut: 4)"
    echo "  --cleanup           Nettoyer les images après construction"
    echo "  -h, --help          Afficher cette aide"
    echo ""
    echo "EXEMPLES:"
    echo "  $0                                    # Construire tous les services"
    echo "  $0 frontend                           # Construire les services frontend"
    echo "  $0 --target prod --push               # Construire en production et pousser"
    echo "  $0 --platform linux/arm64             # Construire pour ARM64 uniquement"
}

# Fonction principale
main() {
    local target="all"
    local cleanup=false
    
    # Parsing des arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target)
                BUILD_TARGET="$2"
                shift 2
                ;;
            --platform)
                BUILD_PLATFORM="$2"
                shift 2
                ;;
            --push)
                PUSH_IMAGES="true"
                shift
                ;;
            --registry)
                REGISTRY_URL="$2"
                shift 2
                ;;
            --cache-from)
                CACHE_FROM="true"
                shift
                ;;
            --parallel)
                PARALLEL_BUILDS="$2"
                shift 2
                ;;
            --cleanup)
                cleanup=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            all|frontend|backend|ai-ml|infrastructure|compose)
                target="$1"
                shift
                ;;
            *)
                log_error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Vérification des prérequis
    check_prerequisites
    
    # Construction selon la cible
    case $target in
        all)
            build_all_services
            ;;
        frontend)
            build_frontend_services
            ;;
        backend)
            build_backend_services
            ;;
        ai-ml)
            build_ai_ml_services
            ;;
        infrastructure)
            build_infrastructure_services
            ;;
        compose)
            build_with_compose
            ;;
        *)
            log_error "Cible inconnue: $target"
            exit 1
            ;;
    esac
    
    # Nettoyage si demandé
    if [ "$cleanup" = "true" ]; then
        cleanup_images
    fi
    
    log_success "Construction terminée avec succès !"
}

# Exécution du script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

