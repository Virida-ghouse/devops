#!/bin/bash

# 🦊 Script de déploiement GitLab Runner pour VIRIDA
# Ce script déploie GitLab Runner sur Clever Cloud

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Configuration
APP_NAME="gitlab-runner"
CLEVER_ALIAS="virida-gitlab-runner"
DOCKERFILE="Dockerfile.gitlab-runner"
CONFIG_FILE="clevercloud-gitlab-runner.json"
ORGANIZATION_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"

log "🦊 Déploiement GitLab Runner pour VIRIDA"
log "Organisation: $ORGANIZATION_ID"
echo ""

# Étape 1: Vérification des prérequis
log "📋 Étape 1: Vérification des prérequis..."

# Vérification de Clever Tools
if ! command -v clever &> /dev/null; then
    error "Clever Tools n'est pas installé"
    exit 1
else
    success "Clever Tools OK"
fi

# Vérification des fichiers
if [ ! -f "$DOCKERFILE" ]; then
    error "Dockerfile non trouvé: $DOCKERFILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    error "Fichier de configuration non trouvé: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "scripts/start-gitlab-runner.sh" ]; then
    error "Script de démarrage non trouvé: scripts/start-gitlab-runner.sh"
    exit 1
fi

success "Fichiers OK"
echo ""

# Étape 2: Configuration des credentials
log "📋 Étape 2: Configuration des credentials..."

# Vérification des variables d'environnement
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

# Étape 3: Configuration GitLab
log "📋 Étape 3: Configuration GitLab..."

# Configuration GitLab
GITLAB_URL="https://gitlab.com"
RUNNER_NAME="virida-gitlab-runner"
RUNNER_LABELS="ubuntu-latest,docker,clever-cloud"
RUNNER_WORK_DIR="/workspace"

# Token GitLab (à obtenir manuellement)
if [ -z "$GITLAB_TOKEN" ]; then
    error "GITLAB_TOKEN doit être défini"
    log "Définissez-le avec:"
    echo "export GITLAB_TOKEN='votre_token_gitlab'"
    echo ""
    log "Obtenez votre token sur: $GITLAB_URL > Profil > Access Tokens"
    exit 1
fi

log "Configuration GitLab:"
echo "  - URL: $GITLAB_URL"
echo "  - Token: ${GITLAB_TOKEN:0:10}..."
echo ""

# Étape 4: Configuration des variables
log "📋 Étape 4: Configuration des variables..."

log "Variables configurées:"
echo "  - RUNNER_NAME: $RUNNER_NAME"
echo "  - RUNNER_LABELS: $RUNNER_LABELS"
echo ""

# Étape 5: Création de l'application
log "📋 Étape 5: Création de l'application Clever Cloud..."

# Vérification si l'application existe
if clever applications --json | grep -q "\"alias\": \"$CLEVER_ALIAS\""; then
    log "📋 Application existante trouvée: $CLEVER_ALIAS"
    clever link "$CLEVER_ALIAS"
else
    log "✨ Création de la nouvelle application: $CLEVER_ALIAS"
    clever create --type docker "$CLEVER_ALIAS"
    clever link "$CLEVER_ALIAS"
fi

# Configuration des variables d'environnement
log "🔧 Configuration des variables d'environnement..."

# Variables principales
clever env set GITLAB_URL "$GITLAB_URL" --alias "$CLEVER_ALIAS"
clever env set GITLAB_TOKEN "$GITLAB_TOKEN" --alias "$CLEVER_ALIAS"
clever env set RUNNER_NAME "$RUNNER_NAME" --alias "$CLEVER_ALIAS"
clever env set RUNNER_LABELS "$RUNNER_LABELS" --alias "$CLEVER_ALIAS"
clever env set RUNNER_WORK_DIR "$RUNNER_WORK_DIR" --alias "$CLEVER_ALIAS"
clever env set DOCKER_BUILDKIT "1" --alias "$CLEVER_ALIAS"
clever env set COMPOSE_DOCKER_CLI_BUILD "1" --alias "$CLEVER_ALIAS"

# Variables Bucket (Clever Cloud)
clever env set BUCKET_FTP_PASSWORD "Odny785DsL9LYBZc" --alias "$CLEVER_ALIAS"
clever env set BUCKET_FTP_USERNAME "ua9e0425888f" --alias "$CLEVER_ALIAS"
clever env set BUCKET_HOST "bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com" --alias "$CLEVER_ALIAS"

# Variables PostgreSQL (Clever Cloud)
clever env set POSTGRESQL_ADDON_HOST "bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com" --alias "$CLEVER_ALIAS"
clever env set POSTGRESQL_ADDON_DB "bjduvaldxkbwljy3uuel" --alias "$CLEVER_ALIAS"
clever env set POSTGRESQL_ADDON_USER "uncer3i7fyqs2zeult6r" --alias "$CLEVER_ALIAS"
clever env set POSTGRESQL_ADDON_PORT "50013" --alias "$CLEVER_ALIAS"
clever env set POSTGRESQL_ADDON_PASSWORD "WuobPl6Nyk9X0Z4DKF7BlxE55z2buu" --alias "$CLEVER_ALIAS"
clever env set POSTGRESQL_ADDON_URI "postgresql://uncer3i7fyqs2zeult6r:WuobPl6Nyk9X0Z4DKF7BlxE55z2buu@bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:5432/bjduvaldxkbwljy3uuel" --alias "$CLEVER_ALIAS"

success "Variables d'environnement configurées"
echo ""

# Étape 6: Déploiement
log "📋 Étape 6: Déploiement de GitLab Runner..."

# Copie des fichiers nécessaires
cp "$DOCKERFILE" Dockerfile
cp "$CONFIG_FILE" clevercloud.json

# Déploiement
log "🚀 Déploiement en cours..."
clever deploy --alias "$CLEVER_ALIAS" --same-commit-policy rebuild

if [ $? -eq 0 ]; then
    success "Déploiement réussi!"
else
    error "Échec du déploiement"
    exit 1
fi

echo ""

# Étape 7: Vérification
log "📋 Étape 7: Vérification du déploiement..."

# Attente du démarrage
log "⏳ Attente du démarrage (60s)..."
sleep 60

# Vérification des logs
log "📋 Vérification des logs..."
clever logs --alias "$CLEVER_ALIAS" --lines 50

# Vérification du statut
log "📊 Vérification du statut..."
clever status --alias "$CLEVER_ALIAS"

# Affichage des informations
log "📋 Informations de déploiement:"
echo "  - Application: $CLEVER_ALIAS"
echo "  - URL: https://$CLEVER_ALIAS.cleverapps.io"
echo "  - Type: Docker"
echo "  - Runner: $RUNNER_NAME"
echo "  - Labels: $RUNNER_LABELS"
echo "  - Organisation: $ORGANIZATION_ID"

success "🎉 GitLab Runner déployé avec succès!"

# Instructions finales
log "📝 Prochaines étapes:"
echo "  1. Vérifiez les logs: clever logs --alias $CLEVER_ALIAS"
echo "  2. Configurez les variables dans GitLab"
echo "  3. Testez les pipelines GitLab CI"
echo "  4. Configurez les notifications Slack/Email"

# Nettoyage
rm -f Dockerfile clevercloud.json

success "🦊 Déploiement GitLab Runner terminé!"



