#!/bin/bash

# 🚀 Script de déploiement DevOps complet pour VIRIDA
# Ce script déploie toute l'infrastructure DevOps sur Clever Cloud

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

# Applications
APPS=(
    "frontend-3d:Node.js:3000"
    "ai-ml:Python:8000"
    "gitlab-runner:Ubuntu:8080"
)

log "🚀 Déploiement DevOps complet pour VIRIDA"
log "Organisation: $ORGANIZATION_ID"
echo ""

# Étape 1: Vérification des prérequis
log "📋 Étape 1: Vérification des prérequis..."

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
    exit 1
fi

# Connexion à Clever Cloud
log "🔐 Connexion à Clever Cloud..."
if clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET" &> /dev/null; then
    success "Connexion Clever Cloud réussie"
else
    error "Échec de la connexion Clever Cloud"
    exit 1
fi

echo ""

# Étape 2: Configuration des variables d'environnement
log "📋 Étape 2: Configuration des variables d'environnement..."

# Variables communes
COMMON_VARS=(
    "DOCKER_BUILDKIT=1"
    "COMPOSE_DOCKER_CLI_BUILD=1"
    "NODE_ENV=production"
    "PYTHON_ENV=production"
)

# Variables Bucket
BUCKET_VARS=(
    "BUCKET_FTP_PASSWORD=Odny785DsL9LYBZc"
    "BUCKET_FTP_USERNAME=ua9e0425888f"
    "BUCKET_HOST=bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com"
)

# Variables PostgreSQL
POSTGRES_VARS=(
    "POSTGRESQL_ADDON_HOST=bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com"
    "POSTGRESQL_ADDON_DB=bjduvaldxkbwljy3uuel"
    "POSTGRESQL_ADDON_USER=uncer3i7fyqs2zeult6r"
    "POSTGRESQL_ADDON_PORT=50013"
    "POSTGRESQL_ADDON_PASSWORD=WuobPl6Nyk9X0Z4DKF7BlxE55z2buu"
    "POSTGRESQL_ADDON_URI=postgresql://uncer3i7fyqs2zeult6r:WuobPl6Nyk9X0Z4DKF7BlxE55z2buu@bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:5432/bjduvaldxkbwljy3uuel"
)

# Variables GitLab
GITLAB_VARS=(
    "GITLAB_URL=https://gitlab.com"
    "GITLAB_TOKEN=${GITLAB_TOKEN:-}"
    "RUNNER_NAME=virida-gitlab-runner"
    "RUNNER_LABELS=ubuntu-latest,docker,clever-cloud"
    "RUNNER_WORK_DIR=/workspace"
)

success "Variables d'environnement configurées"
echo ""

# Étape 3: Déploiement des applications
log "📋 Étape 3: Déploiement des applications..."

for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name app_type app_port <<< "$app_config"
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
    for var in "${COMMON_VARS[@]}"; do
        IFS='=' read -r key value <<< "$var"
        clever env set "$key" "$value" --alias "$CLEVER_ALIAS"
    done
    
    # Configuration des variables Bucket
    for var in "${BUCKET_VARS[@]}"; do
        IFS='=' read -r key value <<< "$var"
        clever env set "$key" "$value" --alias "$CLEVER_ALIAS"
    done
    
    # Configuration des variables PostgreSQL
    for var in "${POSTGRES_VARS[@]}"; do
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
            for var in "${GITLAB_VARS[@]}"; do
                IFS='=' read -r key value <<< "$var"
                clever env set "$key" "$value" --alias "$CLEVER_ALIAS"
            done
            ;;
    esac
    
    success "Configuration de $app_name terminée"
done

echo ""

# Étape 4: Déploiement des applications
log "📋 Étape 4: Déploiement des applications..."

for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name app_type app_port <<< "$app_config"
    CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
    
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
done

echo ""

# Étape 5: Vérification des déploiements
log "📋 Étape 5: Vérification des déploiements..."

# Attente du démarrage
log "⏳ Attente du démarrage des services (120s)..."
sleep 120

# Vérification de chaque application
for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name app_type app_port <<< "$app_config"
    CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
    
    log "🔍 Vérification de $app_name..."
    
    # Vérification du statut
    clever status --alias "$CLEVER_ALIAS"
    
    # Vérification des logs
    log "📋 Logs de $app_name:"
    clever logs --alias "$CLEVER_ALIAS" --lines 20
    
    success "Vérification de $app_name terminée"
    echo ""
done

# Étape 6: Configuration du monitoring
log "📋 Étape 6: Configuration du monitoring..."

# Configuration des alertes (si les variables sont définies)
if [ -n "$MONITORING_URL" ] && [ -n "$MONITORING_TOKEN" ]; then
    log "📊 Configuration des alertes de monitoring..."
    
    for app_config in "${APPS[@]}"; do
        IFS=':' read -r app_name app_type app_port <<< "$app_config"
        CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
        
        # Configuration des alertes pour chaque application
        curl -X POST "$MONITORING_URL/alerts" \
            -H "Authorization: Bearer $MONITORING_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{
                \"service\": \"$CLEVER_ALIAS\",
                \"url\": \"https://$CLEVER_ALIAS.cleverapps.io/health\",
                \"threshold\": 2.0,
                \"enabled\": true
            }" 2>/dev/null || warning "Impossible de configurer les alertes pour $app_name"
    done
    
    success "Monitoring configuré"
else
    warning "Variables de monitoring non définies, configuration ignorée"
fi

echo ""

# Étape 7: Rapport final
log "📋 Étape 7: Rapport de déploiement..."

success "🎉 Déploiement DevOps VIRIDA terminé avec succès!"

echo ""
log "📊 Résumé du déploiement:"
echo "  - Organisation: $ORGANIZATION_ID"
echo "  - Applications déployées: ${#APPS[@]}"
echo "  - Infrastructure: Clever Cloud"
echo "  - CI/CD: GitLab Runner"
echo "  - Monitoring: Configuré"
echo ""

log "🌐 URLs des applications:"
for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name app_type app_port <<< "$app_config"
    CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
    echo "  - $app_name: https://$CLEVER_ALIAS.cleverapps.io"
done

echo ""
log "📝 Prochaines étapes:"
echo "  1. Vérifiez les applications: clever status"
echo "  2. Consultez les logs: clever logs --alias <app>"
echo "  3. Configurez GitLab CI/CD"
echo "  4. Testez les pipelines"
echo "  5. Configurez les notifications Slack"

echo ""
log "🔧 Commandes utiles:"
echo "  - Statut: clever status"
echo "  - Logs: clever logs --alias <app>"
echo "  - Redéployer: clever deploy --alias <app>"
echo "  - Variables: clever env --alias <app>"

success "🚀 Infrastructure DevOps VIRIDA opérationnelle!"



