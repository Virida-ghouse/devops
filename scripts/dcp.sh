#!/bin/bash

# 🚀 DCP - Deploy Complete Pipeline VIRIDA
# Script de déploiement complet de l'infrastructure DevOps VIRIDA

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Fonctions de logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️ $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

info() {
    echo -e "${PURPLE}[$(date +'%Y-%m-%d %H:%M:%S')] ℹ️ $1${NC}"
}

# Configuration
ORGANIZATION_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"
CLEVER_ALIAS_PREFIX="virida"
GITLAB_URL="https://gitlab.com/virida/"

# Applications à déployer
APPS=(
    "frontend-3d:Node.js:3000:🟢"
    "ai-ml:Python:8000:🔵"
    "gitlab-runner:Ubuntu:8080:🟡"
)

# Fonction pour afficher le header
show_header() {
    clear
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                        🚀 DCP - VIRIDA DEPLOYMENT                           ║${NC}"
    echo -e "${WHITE}║                    Deploy Complete Pipeline Infrastructure                   ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📋 Configuration:${NC}"
    echo -e "${CYAN}  - Organisation: $ORGANIZATION_ID${NC}"
    echo -e "${CYAN}  - GitLab: $GITLAB_URL${NC}"
    echo -e "${CYAN}  - Applications: ${#APPS[@]}${NC}"
    echo ""
}

# Fonction pour vérifier les prérequis
check_prerequisites() {
    log "🔍 Vérification des prérequis..."
    
    # Vérification de Clever Tools
    if ! command -v clever &> /dev/null; then
        error "Clever Tools n'est pas installé"
        log "Installation de Clever Tools..."
        npm install -g clever-tools
        if [ $? -eq 0 ]; then
            success "Clever Tools installé"
        else
            error "Échec de l'installation de Clever Tools"
            exit 1
        fi
    else
        success "Clever Tools OK"
    fi
    
    # Vérification des credentials
    if [ -z "$CLEVER_TOKEN" ] || [ -z "$CLEVER_SECRET" ]; then
        error "CLEVER_TOKEN et CLEVER_SECRET doivent être définis"
        log "Définissez-les avec:"
        echo "export CLEVER_TOKEN='votre_token'"
        echo "export CLEVER_SECRET='votre_secret'"
        echo "export GITLAB_TOKEN='votre_token_gitlab'"
        exit 1
    fi
    
    # Vérification de GitLab Token
    if [ -z "$GITLAB_TOKEN" ]; then
        warning "GITLAB_TOKEN non défini, certaines fonctionnalités seront limitées"
    fi
    
    success "Prérequis OK"
}

# Fonction pour se connecter à Clever Cloud
connect_clever_cloud() {
    log "🔐 Connexion à Clever Cloud..."
    if clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET" &> /dev/null; then
        success "Connexion Clever Cloud réussie"
    else
        error "Échec de la connexion Clever Cloud"
        exit 1
    fi
}

# Fonction pour déployer une application
deploy_app() {
    local app_name=$1
    local app_type=$2
    local app_port=$3
    local app_icon=$4
    local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
    
    log "🏗️ Déploiement de $app_name ($app_type)..."
    
    # Vérification si l'application existe
    if clever applications --json | grep -q "\"alias\": \"$CLEVER_ALIAS\""; then
        log "📋 Application existante trouvée: $CLEVER_ALIAS"
        clever link "$CLEVER_ALIAS"
    else
        log "✨ Création de la nouvelle application: $CLEVER_ALIAS"
        clever create --type docker "$CLEVER_ALIAS"
        clever link "$CLEVER_ALIAS"
    fi
    
    # Configuration des variables communes
    local common_vars=(
        "DOCKER_BUILDKIT=1"
        "COMPOSE_DOCKER_CLI_BUILD=1"
        "NODE_ENV=production"
        "PYTHON_ENV=production"
    )
    
    for var in "${common_vars[@]}"; do
        IFS='=' read -r key value <<< "$var"
        clever env set "$key" "$value" --alias "$CLEVER_ALIAS"
    done
    
    # Variables Bucket
    local bucket_vars=(
        "BUCKET_FTP_PASSWORD=Odny785DsL9LYBZc"
        "BUCKET_FTP_USERNAME=ua9e0425888f"
        "BUCKET_HOST=bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com"
    )
    
    for var in "${bucket_vars[@]}"; do
        IFS='=' read -r key value <<< "$var"
        clever env set "$key" "$value" --alias "$CLEVER_ALIAS"
    done
    
    # Variables PostgreSQL
    local postgres_vars=(
        "POSTGRESQL_ADDON_HOST=bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com"
        "POSTGRESQL_ADDON_DB=bjduvaldxkbwljy3uuel"
        "POSTGRESQL_ADDON_USER=uncer3i7fyqs2zeult6r"
        "POSTGRESQL_ADDON_PORT=50013"
        "POSTGRESQL_ADDON_PASSWORD=WuobPl6Nyk9X0Z4DKF7BlxE55z2buu"
        "POSTGRESQL_ADDON_URI=postgresql://uncer3i7fyqs2zeult6r:WuobPl6Nyk9X0Z4DKF7BlxE55z2buu@bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:5432/bjduvaldxkbwljy3uuel"
    )
    
    for var in "${postgres_vars[@]}"; do
        IFS='=' read -r key value <<< "$var"
        clever env set "$key" "$value" --alias "$CLEVER_ALIAS"
    done
    
    # Configuration spécifique par application
    case $app_name in
        "frontend-3d")
            clever env set "NODE_VERSION" "18" --alias "$CLEVER_ALIAS"
            clever env set "PORT" "$app_port" --alias "$CLEVER_ALIAS"
            ;;
        "ai-ml")
            clever env set "PYTHON_VERSION" "3.11" --alias "$CLEVER_ALIAS"
            clever env set "PORT" "$app_port" --alias "$CLEVER_ALIAS"
            clever env set "GUNICORN_WORKERS" "4" --alias "$CLEVER_ALIAS"
            ;;
        "gitlab-runner")
            clever env set "GITLAB_URL" "$GITLAB_URL" --alias "$CLEVER_ALIAS"
            clever env set "GITLAB_TOKEN" "${GITLAB_TOKEN:-}" --alias "$CLEVER_ALIAS"
            clever env set "RUNNER_NAME" "virida-gitlab-runner" --alias "$CLEVER_ALIAS"
            clever env set "RUNNER_LABELS" "ubuntu-latest,docker,clever-cloud" --alias "$CLEVER_ALIAS"
            clever env set "RUNNER_WORK_DIR" "/workspace" --alias "$CLEVER_ALIAS"
            ;;
    esac
    
    # Déploiement
    log "🚀 Déploiement de $app_name..."
    
    # Sélection du Dockerfile approprié
    case $app_name in
        "frontend-3d")
            DOCKERFILE="Dockerfile"
            CONFIG_FILE="clevercloud.json"
            ;;
        "ai-ml")
            DOCKERFILE="Dockerfile"
            CONFIG_FILE="clevercloud.json"
            ;;
        "gitlab-runner")
            DOCKERFILE="Dockerfile.gitlab-runner"
            CONFIG_FILE="clevercloud-gitlab-runner.json"
            ;;
    esac
    
    # Copie des fichiers nécessaires
    if [ -f "$DOCKERFILE" ]; then
        cp "$DOCKERFILE" Dockerfile.tmp
    else
        error "Dockerfile non trouvé: $DOCKERFILE"
        return 1
    fi
    
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" clevercloud.json.tmp
    else
        error "Fichier de configuration non trouvé: $CONFIG_FILE"
        return 1
    fi
    
    # Déploiement
    clever deploy --alias "$CLEVER_ALIAS" --same-commit-policy rebuild
    
    if [ $? -eq 0 ]; then
        success "Déploiement de $app_name réussi"
    else
        error "Échec du déploiement de $app_name"
        return 1
    fi
    
    # Nettoyage
    rm -f Dockerfile.tmp clevercloud.json.tmp
}

# Fonction pour vérifier les déploiements
verify_deployments() {
    log "🔍 Vérification des déploiements..."
    
    # Attente du démarrage
    log "⏳ Attente du démarrage des services (120s)..."
    sleep 120
    
    local success_count=0
    local total_count=${#APPS[@]}
    
    for app_config in "${APPS[@]}"; do
        IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
        local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
        
        log "🔍 Vérification de $app_name..."
        
        # Vérification du statut
        if clever status --alias "$CLEVER_ALIAS" &> /dev/null; then
            success "✅ $app_name: Opérationnel"
            ((success_count++))
        else
            error "❌ $app_name: Non opérationnel"
        fi
    done
    
    echo ""
    log "📊 Résumé des déploiements:"
    echo -e "${CYAN}  - Applications déployées: $success_count/$total_count${NC}"
    echo -e "${CYAN}  - Taux de succès: $((success_count * 100 / total_count))%${NC}"
    
    if [ $success_count -eq $total_count ]; then
        success "🎉 Tous les déploiements ont réussi!"
    else
        warning "⚠️ Certains déploiements ont échoué"
    fi
}

# Fonction pour afficher les URLs
show_urls() {
    log "🌐 URLs des applications:"
    echo ""
    
    for app_config in "${APPS[@]}"; do
        IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
        local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
        echo -e "${app_icon} ${CYAN}$app_name${NC}: https://$CLEVER_ALIAS.cleverapps.io"
    done
    
    echo ""
    log "📋 GitLab: $GITLAB_URL"
    log "📋 Organisation: $ORGANIZATION_ID"
}

# Fonction pour afficher les commandes utiles
show_commands() {
    log "🔧 Commandes utiles:"
    echo ""
    echo -e "${CYAN}  - Statut: clever status${NC}"
    echo -e "${CYAN}  - Logs: clever logs --alias <app>${NC}"
    echo -e "${CYAN}  - Redéployer: clever deploy --alias <app>${NC}"
    echo -e "${CYAN}  - Variables: clever env --alias <app>${NC}"
    echo -e "${CYAN}  - Dashboard: ./scripts/devops-dashboard.sh${NC}"
    echo ""
}

# Fonction principale
main() {
    show_header
    
    # Vérification des prérequis
    check_prerequisites
    echo ""
    
    # Connexion à Clever Cloud
    connect_clever_cloud
    echo ""
    
    # Déploiement des applications
    log "🚀 Déploiement des applications..."
    echo ""
    
    for app_config in "${APPS[@]}"; do
        IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
        deploy_app "$app_name" "$app_type" "$app_port" "$app_icon"
        echo ""
    done
    
    # Vérification des déploiements
    verify_deployments
    echo ""
    
    # Affichage des URLs
    show_urls
    echo ""
    
    # Affichage des commandes utiles
    show_commands
    
    # Résumé final
    success "🎉 DCP - Déploiement VIRIDA terminé avec succès!"
    echo ""
    log "📝 Prochaines étapes:"
    echo -e "${CYAN}  1. Vérifiez les applications: clever status${NC}"
    echo -e "${CYAN}  2. Consultez les logs: clever logs --alias <app>${NC}"
    echo -e "${CYAN}  3. Lancez le dashboard: ./scripts/devops-dashboard.sh${NC}"
    echo -e "${CYAN}  4. Configurez GitLab CI/CD${NC}"
    echo -e "${CYAN}  5. Testez les pipelines${NC}"
    echo ""
    success "🚀 Infrastructure VIRIDA opérationnelle!"
}

# Lancement du script
main "$@"



