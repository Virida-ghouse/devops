#!/bin/bash

# ========================================
# VIRIDA CI/CD Deployment Script
# ========================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-staging}
CLEVER_TOKEN=${CLEVER_TOKEN}
CLEVER_SECRET=${CLEVER_SECRET}

# Functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if [ -z "$CLEVER_TOKEN" ]; then
        error "CLEVER_TOKEN environment variable is required"
    fi
    
    if [ -z "$CLEVER_SECRET" ]; then
        error "CLEVER_SECRET environment variable is required"
    fi
    
    if ! command -v clever &> /dev/null; then
        error "Clever CLI is not installed. Please install it first."
    fi
    
    success "Prerequisites check passed"
}

# Deploy application
deploy_app() {
    local app_name=$1
    local app_path=$2
    local alias=$3
    
    log "Deploying $app_name to $ENVIRONMENT..."
    
    cd "$app_path"
    
    # Check if clever.json exists
    if [ ! -f "clevercloud.json" ]; then
        warning "No clevercloud.json found in $app_path, skipping..."
        return 0
    fi
    
    # Deploy
    if clever deploy --alias "$alias"; then
        success "$app_name deployed successfully"
    else
        error "Failed to deploy $app_name"
    fi
    
    cd - > /dev/null
}

# Health check
health_check() {
    local url=$1
    local service_name=$2
    local max_attempts=10
    local attempt=1
    
    log "Performing health check for $service_name..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url/health" > /dev/null 2>&1; then
            success "$service_name health check passed"
            return 0
        fi
        
        warning "Health check attempt $attempt/$max_attempts failed for $service_name"
        sleep 30
        ((attempt++))
    done
    
    error "Health check failed for $service_name after $max_attempts attempts"
}

# Main deployment function
main() {
    log "Starting VIRIDA deployment to $ENVIRONMENT environment"
    
    # Check prerequisites
    check_prerequisites
    
    # Login to Clever Cloud
    log "Logging in to Clever Cloud..."
    if ! clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET"; then
        error "Failed to login to Clever Cloud"
    fi
    
    # Deploy applications
    case $ENVIRONMENT in
        "staging")
            deploy_app "Frontend 3D" "apps/frontend-3d" "virida-frontend-3d-staging"
            deploy_app "AI/ML" "apps/ai-ml" "virida-ai-ml-staging"
            # Note: Gitea/Drone deployment disabled - Gitea environment not working
            # Only Gitea database is available on Clever Cloud
            
            # Health checks
            health_check "https://virida-frontend-3d-staging.cleverapps.io" "Frontend 3D Staging"
            health_check "https://virida-ai-ml-staging.cleverapps.io" "AI/ML Staging"
            # Note: Gitea/Drone health check disabled - Gitea environment not working
            ;;
        "production")
            deploy_app "Frontend 3D" "apps/frontend-3d" "virida-frontend-3d"
            deploy_app "AI/ML" "apps/ai-ml" "virida-ai-ml"
            # Note: Gitea/Drone deployment disabled - Gitea environment not working
            # Only Gitea database is available on Clever Cloud
            
            # Health checks
            health_check "https://virida-frontend-3d.cleverapps.io" "Frontend 3D Production"
            health_check "https://virida-ai-ml.cleverapps.io" "AI/ML Production"
            # Note: Gitea/Drone health check disabled - Gitea environment not working
            ;;
        *)
            error "Invalid environment: $ENVIRONMENT. Use 'staging' or 'production'"
            ;;
    esac
    
    success "VIRIDA deployment to $ENVIRONMENT completed successfully!"
    
    # Display URLs
    log "Deployed services:"
    case $ENVIRONMENT in
        "staging")
            echo "  - Frontend 3D: https://virida-frontend-3d-staging.cleverapps.io"
            echo "  - AI/ML: https://virida-ai-ml-staging.cleverapps.io"
            echo "  - Gitea/Drone: https://gitea-drone-ci-staging.cleverapps.io"
            ;;
        "production")
            echo "  - Frontend 3D: https://virida-frontend-3d.cleverapps.io"
            echo "  - AI/ML: https://virida-ai-ml.cleverapps.io"
            echo "  - Gitea/Drone: https://gitea-drone-ci.cleverapps.io"
            ;;
    esac
}

# Run main function
main "$@"
