#!/bin/bash

# 🚀 VIRIDA Deployment Script
# Script pour déployer VIRIDA dans différents environnements

set -e

# Couleurs pour les messages
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

# Fonction d'aide
show_help() {
    echo "🚀 VIRIDA Deployment Script"
    echo ""
    echo "Usage: $0 [ENVIRONMENT] [ACTION]"
    echo ""
    echo "Environments:"
    echo "  dev       - Environnement de développement"
    echo "  staging   - Environnement de staging"
    echo "  prod      - Environnement de production"
    echo ""
    echo "Actions:"
    echo "  build     - Construire les images Docker"
    echo "  deploy    - Déployer les services"
    echo "  stop      - Arrêter les services"
    echo "  restart   - Redémarrer les services"
    echo "  logs      - Afficher les logs"
    echo "  status    - Afficher le statut des services"
    echo "  clean     - Nettoyer les ressources"
    echo ""
    echo "Examples:"
    echo "  $0 dev build"
    echo "  $0 staging deploy"
    echo "  $0 prod restart"
    echo "  $0 dev logs"
}

# Vérification des arguments
if [ $# -lt 2 ]; then
    show_help
    exit 1
fi

ENVIRONMENT=$1
ACTION=$2

# Validation de l'environnement
case $ENVIRONMENT in
    dev|staging|prod)
        ;;
    *)
        log_error "Environnement invalide: $ENVIRONMENT"
        show_help
        exit 1
        ;;
esac

# Validation de l'action
case $ACTION in
    build|deploy|stop|restart|logs|status|clean)
        ;;
    *)
        log_error "Action invalide: $ACTION"
        show_help
        exit 1
        ;;
esac

# Configuration des variables d'environnement
COMPOSE_FILE="docker-compose.${ENVIRONMENT}.yml"
ENV_FILE=".env.${ENVIRONMENT}"

# Vérification de l'existence des fichiers
if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "Fichier Docker Compose non trouvé: $COMPOSE_FILE"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    log_warning "Fichier d'environnement non trouvé: $ENV_FILE"
    log_info "Création du fichier d'environnement par défaut..."
    create_env_file
fi

# Fonction pour créer le fichier d'environnement
create_env_file() {
    case $ENVIRONMENT in
        dev)
            cat > "$ENV_FILE" << EOF
# 🚀 VIRIDA Development Environment
NODE_ENV=development
LOG_LEVEL=debug

# Database
POSTGRES_DB=virida_dev
POSTGRES_USER=virida
POSTGRES_PASSWORD=virida123

# Redis
REDIS_URL=redis://redis:6379

# JWT
JWT_SECRET=dev-jwt-secret-key

# Monitoring
GRAFANA_PASSWORD=admin123
EOF
            ;;
        staging)
            cat > "$ENV_FILE" << EOF
# 🚀 VIRIDA Staging Environment
NODE_ENV=staging
LOG_LEVEL=info

# Database
STAGING_DATABASE_URL=postgresql://virida:staging_password@postgres:5432/virida_staging
STAGING_POSTGRES_DB=virida_staging
STAGING_POSTGRES_USER=virida
STAGING_POSTGRES_PASSWORD=staging_password

# Redis
STAGING_REDIS_URL=redis://redis:6379

# JWT
STAGING_JWT_SECRET=staging-jwt-secret-key

# Monitoring
STAGING_GRAFANA_PASSWORD=staging_grafana_password
EOF
            ;;
        prod)
            cat > "$ENV_FILE" << EOF
# 🚀 VIRIDA Production Environment
NODE_ENV=production
LOG_LEVEL=warn

# Database
PROD_DATABASE_URL=postgresql://virida:production_password@postgres:5432/virida_prod
PROD_POSTGRES_DB=virida_prod
PROD_POSTGRES_USER=virida
PROD_POSTGRES_PASSWORD=production_password

# Redis
PROD_REDIS_URL=redis://redis:6379

# JWT
PROD_JWT_SECRET=production-jwt-secret-key

# Monitoring
PROD_GRAFANA_PASSWORD=production_grafana_password
EOF
            ;;
    esac
    log_success "Fichier d'environnement créé: $ENV_FILE"
}

# Fonction pour construire les images
build_images() {
    log_info "Construction des images Docker pour l'environnement $ENVIRONMENT..."
    
    # Construction des images frontend
    log_info "Construction de l'image 3D Visualizer..."
    docker build -t virida/3d-visualizer:$ENVIRONMENT ../../frontend/3d-visualizer/
    
    log_info "Construction de l'image Dashboard..."
    docker build -t virida/dashboard:$ENVIRONMENT ../../frontend/dashboard/
    
    # Construction des images backend
    log_info "Construction de l'image API Gateway..."
    docker build -t virida/api-gateway:$ENVIRONMENT ../../backend/api-gateway/
    
    log_info "Construction de l'image Auth Service..."
    docker build -t virida/auth-service:$ENVIRONMENT ../../backend/auth-service/
    
    # Construction des images AI/ML
    log_info "Construction de l'image Prediction Engine..."
    docker build -t virida/prediction-engine:$ENVIRONMENT ../../ai-ml/prediction-engine/
    
    log_info "Construction de l'image Eve Assistant..."
    docker build -t virida/eve-assistant:$ENVIRONMENT ../../ai-ml/eve-assistant/
    
    # Construction des images IoT
    log_info "Construction de l'image Sensor Collector..."
    docker build -t virida/sensor-collector:$ENVIRONMENT ../../iot/sensor-collector/
    
    log_success "Toutes les images ont été construites avec succès"
}

# Fonction pour déployer les services
deploy_services() {
    log_info "Déploiement des services pour l'environnement $ENVIRONMENT..."
    
    # Chargement des variables d'environnement
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
    
    # Déploiement avec Docker Compose
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    
    log_success "Services déployés avec succès"
    
    # Affichage du statut
    show_status
}

# Fonction pour arrêter les services
stop_services() {
    log_info "Arrêt des services pour l'environnement $ENVIRONMENT..."
    
    docker-compose -f "$COMPOSE_FILE" down
    
    log_success "Services arrêtés avec succès"
}

# Fonction pour redémarrer les services
restart_services() {
    log_info "Redémarrage des services pour l'environnement $ENVIRONMENT..."
    
    docker-compose -f "$COMPOSE_FILE" restart
    
    log_success "Services redémarrés avec succès"
}

# Fonction pour afficher les logs
show_logs() {
    log_info "Affichage des logs pour l'environnement $ENVIRONMENT..."
    
    docker-compose -f "$COMPOSE_FILE" logs -f
}

# Fonction pour afficher le statut
show_status() {
    log_info "Statut des services pour l'environnement $ENVIRONMENT..."
    
    docker-compose -f "$COMPOSE_FILE" ps
}

# Fonction pour nettoyer les ressources
clean_resources() {
    log_info "Nettoyage des ressources pour l'environnement $ENVIRONMENT..."
    
    # Arrêt des services
    docker-compose -f "$COMPOSE_FILE" down
    
    # Suppression des images
    docker rmi $(docker images "virida/*:$ENVIRONMENT" -q) 2>/dev/null || true
    
    # Nettoyage des volumes
    docker volume prune -f
    
    log_success "Ressources nettoyées avec succès"
}

# Exécution de l'action
case $ACTION in
    build)
        build_images
        ;;
    deploy)
        deploy_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    clean)
        clean_resources
        ;;
esac

log_success "Action '$ACTION' terminée pour l'environnement '$ENVIRONMENT'"
