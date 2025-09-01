#!/bin/bash

# 🚀 VIRIDA Gitea Actions Setup Script
# Configuration automatique de Gitea Actions avec act_runner

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.gitea.yml"

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables d'environnement
GITEA_URL="http://localhost:3000"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin123"
ADMIN_EMAIL="admin@virida.local"

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

# Attendre que Gitea soit prêt
wait_for_gitea() {
    log_info "Attente que Gitea soit prêt..."
    
    local max_attempts=60
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$GITEA_URL/api/v1/version" > /dev/null 2>&1; then
            log_success "Gitea est prêt !"
            return 0
        fi
        
        log_info "Tentative $attempt/$max_attempts - Gitea n'est pas encore prêt..."
        sleep 10
        ((attempt++))
    done
    
    log_error "Gitea n'est pas prêt après $max_attempts tentatives"
    exit 1
}

# Créer l'utilisateur admin
create_admin_user() {
    log_info "Création de l'utilisateur admin..."
    
    # Vérifier si l'utilisateur admin existe déjà
    if curl -s "$GITEA_URL/api/v1/admin/users" > /dev/null 2>&1; then
        log_info "Utilisateur admin existe déjà"
        return 0
    fi
    
    # Créer l'utilisateur admin
    local create_user_response=$(curl -s -X POST "$GITEA_URL/api/v1/admin/users" \
        -H "Content-Type: application/json" \
        -d "{
            \"username\": \"$ADMIN_USERNAME\",
            \"email\": \"$ADMIN_EMAIL\",
            \"password\": \"$ADMIN_PASSWORD\",
            \"admin\": true,
            \"login_name\": \"$ADMIN_USERNAME\"
        }")
    
    if [ $? -eq 0 ]; then
        log_success "Utilisateur admin créé avec succès"
    else
        log_warning "Impossible de créer l'utilisateur admin via API, création manuelle requise"
    fi
}

# Générer le token d'authentification
generate_auth_token() {
    log_info "Génération du token d'authentification..."
    
    local token_response=$(curl -s -X POST "$GITEA_URL/api/v1/users/$ADMIN_USERNAME/tokens" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"virida-setup-token\"
        }" \
        -u "$ADMIN_USERNAME:$ADMIN_PASSWORD")
    
    if [ $? -eq 0 ]; then
        local token=$(echo "$token_response" | grep -o '"sha1":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$token" ]; then
            log_success "Token d'authentification généré"
            echo "$token" > "$PROJECT_ROOT/.gitea-auth-token"
            echo "$token"
        else
            log_error "Impossible d'extraire le token de la réponse"
            return 1
        fi
    else
        log_error "Impossible de générer le token d'authentification"
        return 1
    fi
}

# Créer les organisations VIRIDA
create_virida_organizations() {
    local auth_token="$1"
    
    log_info "Création des organisations VIRIDA..."
    
    local organizations=(
        "frontend"
        "backend"
        "ai-ml"
        "iot"
        "devops"
        "shared"
        "web-app"
    )
    
    for org in "${organizations[@]}"; do
        log_info "Création de l'organisation: $org"
        
        local create_org_response=$(curl -s -X POST "$GITEA_URL/api/v1/orgs" \
            -H "Content-Type: application/json" \
            -H "Authorization: token $auth_token" \
            -d "{
                \"username\": \"$org\",
                \"full_name\": \"VIRIDA $org\",
                \"description\": \"Organisation VIRIDA pour $org\",
                \"website\": \"https://virida.local\",
                \"visibility\": \"public\"
            }")
        
        if [ $? -eq 0 ]; then
            log_success "Organisation $org créée"
        else
            log_warning "Impossible de créer l'organisation $org (peut-être déjà existante)"
        fi
    done
}

# Créer les projets dans chaque organisation
create_virida_projects() {
    local auth_token="$1"
    
    log_info "Création des projets VIRIDA..."
    
    # Structure des projets par organisation
    declare -A projects=(
        ["frontend"]="3d-visualizer dashboard"
        ["backend"]="api-gateway user-service auth-service"
        ["ai-ml"]="prediction-engine training-service model-registry"
        ["iot"]="device-management sensor-service edge-computing"
        ["devops"]="ci-cd-pipelines monitoring logging"
        ["shared"]="api-definition common-libs utils"
        ["web-app"]="main-app admin-panel"
    )
    
    for org in "${!projects[@]}"; do
        log_info "Création des projets pour l'organisation: $org"
        
        for project in ${projects[$org]}; do
            log_info "Création du projet: $org/$project"
            
            local create_project_response=$(curl -s -X POST "$GITEA_URL/api/v1/orgs/$org/repos" \
                -H "Content-Type: application/json" \
                -H "Authorization: token $auth_token" \
                -d "{
                    \"name\": \"$project\",
                    \"description\": \"Projet VIRIDA $org/$project\",
                    \"private\": false,
                    \"auto_init\": true,
                    \"gitignores\": \"Node\",
                    \"license\": \"MIT\",
                    \"readme\": \"Default\"
                }")
            
            if [ $? -eq 0 ]; then
                log_success "Projet $org/$project créé"
            else
                log_warning "Impossible de créer le projet $org/$project"
            fi
        done
    done
}

# Configurer les runners Gitea Actions
setup_gitea_actions() {
    log_info "Configuration de Gitea Actions..."
    
    # Vérifier que le runner est connecté
    local runner_status=$(docker exec virida-gitea-runner wget -qO- http://localhost:8080/health 2>/dev/null || echo "unhealthy")
    
    if [ "$runner_status" = "healthy" ]; then
        log_success "Runner Gitea Actions connecté"
    else
        log_warning "Runner Gitea Actions non connecté, vérification manuelle requise"
        log_info "Vérifiez l'état du runner dans l'interface admin de Gitea"
    fi
}

# Créer un exemple de workflow Gitea Actions
create_example_workflow() {
    log_info "Création d'un exemple de workflow Gitea Actions..."
    
    local workflow_dir="$PROJECT_ROOT/examples/gitea-actions"
    mkdir -p "$workflow_dir"
    
    cat > "$workflow_dir/.gitea/workflows/ci-cd.yml" << 'EOF'
# 🚀 VIRIDA CI/CD Pipeline - Gitea Actions
# Workflow d'exemple pour l'intégration continue

name: VIRIDA CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: registry.virida.local:5000
  IMAGE_NAME: ${{ gitea.repository }}

jobs:
  # ========================================
  # BUILD & TEST
  # ========================================
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Run linting
        run: npm run lint
        
      - name: Build application
        run: npm run build

  # ========================================
  # DOCKER BUILD
  # ========================================
  docker-build:
    runs-on: ubuntu-latest
    needs: build-and-test
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
        
      - name: Build Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: false
          tags: ${{ env.IMAGE_NAME }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # ========================================
  # SECURITY SCAN
  # ========================================
  security-scan:
    runs-on: ubuntu-latest
    needs: docker-build
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.IMAGE_NAME }}:latest
          format: 'sarif'
          output: 'trivy-results.sarif'
          
      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  # ========================================
  # DEPLOY TO DEVELOPMENT
  # ========================================
  deploy-dev:
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.ref == 'refs/heads/develop'
    environment: development
    steps:
      - name: Deploy to development
        run: |
          echo "Déploiement vers l'environnement de développement"
          # Ajoutez ici vos commandes de déploiement
          
  # ========================================
  # DEPLOY TO PRODUCTION
  # ========================================
  deploy-prod:
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy to production
        run: |
          echo "Déploiement vers l'environnement de production"
          # Ajoutez ici vos commandes de déploiement
EOF

    log_success "Exemple de workflow créé dans $workflow_dir"
}

# Affichage des informations de connexion
show_connection_info() {
    log_success "Configuration Gitea Actions terminée !"
    echo ""
    echo "🌐 **Accès aux Services VIRIDA**"
    echo "=================================="
    echo "Gitea:          http://localhost:3000"
    echo "  - Admin:      $ADMIN_USERNAME / $ADMIN_PASSWORD"
    echo "  - Email:      $ADMIN_EMAIL"
    echo ""
    echo "📊 **Monitoring**"
    echo "Prometheus:     http://localhost:9090"
    echo "Grafana:        http://localhost:3001 (admin/admin)"
    echo ""
    echo "🔧 **Configuration Requise**"
    echo "1. Connectez-vous à Gitea avec les identifiants admin"
    echo "2. Allez dans Admin > Actions > Runners"
    echo "3. Copiez le token du runner et mettez-le dans .env.gitea"
    echo "4. Redémarrez le runner: docker-compose restart gitea-runner"
    echo ""
    echo "📚 **Documentation**"
    echo "Gitea Actions:  https://docs.gitea.com/usage/actions/overview"
    echo "act_runner:     https://gitea.com/gitea/act_runner"
}

# Fonction principale
main() {
    log_info "🚀 Configuration de VIRIDA Gitea Actions..."
    
    # Vérification des prérequis
    check_prerequisites
    
    # Attendre que Gitea soit prêt
    wait_for_gitea
    
    # Créer l'utilisateur admin
    create_admin_user
    
    # Générer le token d'authentification
    local auth_token=$(generate_auth_token)
    if [ -z "$auth_token" ]; then
        log_error "Impossible de générer le token d'authentification"
        exit 1
    fi
    
    # Créer les organisations et projets
    create_virida_organizations "$auth_token"
    create_virida_projects "$auth_token"
    
    # Configurer Gitea Actions
    setup_gitea_actions
    
    # Créer un exemple de workflow
    create_example_workflow
    
    # Afficher les informations de connexion
    show_connection_info
}

# Exécution du script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

