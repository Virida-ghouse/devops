#!/bin/bash

# 🚀 Déploiement VIRIDA avec Token GitLab Deploy
# Script adapté pour utiliser un deploy token GitLab

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Fonctions
log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✅ $1${NC}"; }
warning() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠️ $1${NC}"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] ❌ $1${NC}"; }

# Configuration
ORGANIZATION_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"
CLEVER_ALIAS_PREFIX="virida"
GITLAB_URL="https://gitlab.com"
GITLAB_TOKEN="gldt-s3GXEHLypuXmLaxEo4UM"
GITLAB_PROJECT="virida/virida"

# Applications
APPS=(
    "frontend-3d:Node.js:3000:🟢"
    "ai-ml:Python:8000:🔵"
    "gitlab-runner:Ubuntu:8080:🟡"
)

echo -e "${CYAN}🚀 DÉPLOIEMENT VIRIDA AVEC GITLAB TOKEN${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""

# Vérification des prérequis
log "🔍 Vérification des prérequis..."

if [ -z "$CLEVER_TOKEN" ] || [ -z "$CLEVER_SECRET" ]; then
    error "CLEVER_TOKEN et CLEVER_SECRET doivent être définis"
    echo "Définissez-les avec:"
    echo "export CLEVER_TOKEN='votre_token'"
    echo "export CLEVER_SECRET='votre_secret'"
    exit 1
fi

if ! command -v clever &> /dev/null; then
    error "Clever Tools n'est pas installé"
    exit 1
fi

success "Prérequis OK"

# Connexion Clever Cloud
log "🔐 Connexion à Clever Cloud..."
if clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET" &> /dev/null; then
    success "Connexion Clever Cloud réussie"
else
    error "Échec de la connexion Clever Cloud"
    exit 1
fi

# Configuration GitLab
log "🦊 Configuration GitLab..."
echo "  - URL: $GITLAB_URL"
echo "  - Project: $GITLAB_PROJECT"
echo "  - Token: ${GITLAB_TOKEN:0:10}..."
echo "  - Type: Deploy Token"

# Déploiement des applications
log "🚀 Déploiement des applications..."

for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
    CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
    
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
            clever env set "GITLAB_TOKEN" "$GITLAB_TOKEN" --alias "$CLEVER_ALIAS"
            clever env set "RUNNER_NAME" "virida-gitlab-runner" --alias "$CLEVER_ALIAS"
            clever env set "RUNNER_LABELS" "ubuntu-latest,docker,clever-cloud,virida" --alias "$CLEVER_ALIAS"
            clever env set "RUNNER_WORK_DIR" "/workspace" --alias "$CLEVER_ALIAS"
            clever env set "GITLAB_PROJECT" "$GITLAB_PROJECT" --alias "$CLEVER_ALIAS"
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
        continue
    fi
    
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" clevercloud.json.tmp
    else
        error "Fichier de configuration non trouvé: $CONFIG_FILE"
        continue
    fi
    
    # Déploiement
    clever deploy --alias "$CLEVER_ALIAS" --same-commit-policy rebuild
    
    if [ $? -eq 0 ]; then
        success "Déploiement de $app_name réussi"
    else
        error "Échec du déploiement de $app_name"
    fi
    
    # Nettoyage
    rm -f Dockerfile.tmp clevercloud.json.tmp
    echo ""
done

# Vérification des déploiements
log "🔍 Vérification des déploiements..."
sleep 60

for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
    CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
    
    log "🔍 Vérification de $app_name..."
    
    if clever status --alias "$CLEVER_ALIAS" &> /dev/null; then
        success "✅ $app_name: Opérationnel"
    else
        error "❌ $app_name: Non opérationnel"
    fi
done

# Affichage des URLs
echo ""
log "🌐 URLs des applications:"
for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
    CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
    echo -e "${app_icon} ${CYAN}$app_name${NC}: https://$CLEVER_ALIAS.cleverapps.io"
done

echo ""
log "📋 GitLab: $GITLAB_URL/$GITLAB_PROJECT"
log "📋 Organisation: $ORGANIZATION_ID"

echo ""
success "🎉 Déploiement VIRIDA avec GitLab terminé!"
echo ""
log "📝 Prochaines étapes:"
echo "  1. Vérifiez les applications: clever status"
echo "  2. Consultez les logs: clever logs --alias <app>"
echo "  3. Configurez GitLab CI/CD avec le token"
echo "  4. Testez les pipelines"
echo ""
success "🚀 Infrastructure VIRIDA opérationnelle!"



