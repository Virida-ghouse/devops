#!/bin/bash

# 🦊 Script de démarrage GitLab Runner pour VIRIDA
# Ce script configure et démarre GitLab Runner avec les paramètres optimaux

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

# Configuration par défaut
GITLAB_URL=${GITLAB_URL:-"https://gitlab.com"}
GITLAB_TOKEN=${GITLAB_TOKEN:-""}
RUNNER_NAME=${RUNNER_NAME:-"virida-gitlab-runner"}
RUNNER_LABELS=${RUNNER_LABELS:-"ubuntu-latest,docker,clever-cloud"}
RUNNER_WORK_DIR=${RUNNER_WORK_DIR:-"/workspace"}

# Variables d'environnement Bucket (Clever Cloud)
BUCKET_FTP_PASSWORD=${BUCKET_FTP_PASSWORD:-"Odny785DsL9LYBZc"}
BUCKET_FTP_USERNAME=${BUCKET_FTP_USERNAME:-"ua9e0425888f"}
BUCKET_HOST=${BUCKET_HOST:-"bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com"}

# Variables d'environnement PostgreSQL (Clever Cloud)
POSTGRESQL_ADDON_HOST=${POSTGRESQL_ADDON_HOST:-"bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com"}
POSTGRESQL_ADDON_DB=${POSTGRESQL_ADDON_DB:-"bjduvaldxkbwljy3uuel"}
POSTGRESQL_ADDON_USER=${POSTGRESQL_ADDON_USER:-"uncer3i7fyqs2zeult6r"}
POSTGRESQL_ADDON_PORT=${POSTGRESQL_ADDON_PORT:-"50013"}
POSTGRESQL_ADDON_PASSWORD=${POSTGRESQL_ADDON_PASSWORD:-"WuobPl6Nyk9X0Z4DKF7BlxE55z2buu"}
POSTGRESQL_ADDON_URI=${POSTGRESQL_ADDON_URI:-"postgresql://uncer3i7fyqs2zeult6r:WuobPl6Nyk9X0Z4DKF7BlxE55z2buu@bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:5432/bjduvaldxkbwljy3uuel"}

log "🦊 Démarrage de GitLab Runner pour VIRIDA"
log "Instance GitLab: $GITLAB_URL"
log "Nom du runner: $RUNNER_NAME"
log "Labels: $RUNNER_LABELS"

# Vérification des variables d'environnement
if [ -z "$GITLAB_TOKEN" ]; then
    error "GITLAB_TOKEN n'est pas défini"
    exit 1
fi

# Vérification de la connectivité GitLab
log "🔍 Vérification de la connectivité GitLab..."
if ! curl -s -f "$GITLAB_URL/api/v4/version" > /dev/null; then
    error "Impossible de se connecter à GitLab: $GITLAB_URL"
    exit 1
fi
success "Connectivité GitLab OK"

# Vérification de Docker
log "🐳 Vérification de Docker..."
if ! docker --version > /dev/null 2>&1; then
    error "Docker n'est pas disponible"
    exit 1
fi
success "Docker OK"

# Vérification des outils de développement
log "🔧 Vérification des outils de développement..."

# Node.js
if ! node --version > /dev/null 2>&1; then
    warning "Node.js non disponible"
else
    success "Node.js $(node --version) OK"
fi

# Python
if ! python3 --version > /dev/null 2>&1; then
    warning "Python non disponible"
else
    success "Python $(python3 --version) OK"
fi

# Go
if ! go version > /dev/null 2>&1; then
    warning "Go non disponible"
else
    success "Go $(go version | cut -d' ' -f3) OK"
fi

# Clever Tools
if ! clever --version > /dev/null 2>&1; then
    warning "Clever Tools non disponible"
else
    success "Clever Tools OK"
fi

# Vérification des variables Bucket
log "🪣 Vérification des variables Bucket..."
if [ -n "$BUCKET_HOST" ] && [ -n "$BUCKET_FTP_USERNAME" ] && [ -n "$BUCKET_FTP_PASSWORD" ]; then
    success "Variables Bucket configurées"
else
    warning "Variables Bucket manquantes"
fi

# Vérification des variables PostgreSQL
log "🐘 Vérification des variables PostgreSQL..."
if [ -n "$POSTGRESQL_ADDON_HOST" ] && [ -n "$POSTGRESQL_ADDON_DB" ] && [ -n "$POSTGRESQL_ADDON_USER" ]; then
    success "Variables PostgreSQL configurées"
else
    warning "Variables PostgreSQL manquantes"
fi

# Configuration du runner si nécessaire
if [ ! -f "$RUNNER_WORK_DIR/.gitlab-runner/config.toml" ]; then
    log "🔧 Configuration du runner..."
    
    # Création du répertoire de travail
    mkdir -p "$RUNNER_WORK_DIR"
    
    # Enregistrement du runner
    gitlab-runner register \
        --url "$GITLAB_URL" \
        --registration-token "$GITLAB_TOKEN" \
        --name "$RUNNER_NAME" \
        --tag-list "$RUNNER_LABELS" \
        --executor "docker" \
        --docker-image "ubuntu:22.04" \
        --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
        --docker-volumes "/workspace:/workspace" \
        --non-interactive
    
    if [ $? -eq 0 ]; then
        success "Runner enregistré avec succès"
    else
        error "Échec de l'enregistrement du runner"
        exit 1
    fi
else
    log "📋 Configuration du runner existante trouvée"
fi

# Démarrage du runner
log "🚀 Démarrage du runner GitLab..."
success "GitLab Runner démarré avec succès"

# Fonction de nettoyage
cleanup() {
    log "🧹 Arrêt du runner..."
    success "Runner arrêté proprement"
    exit 0
}

# Gestion des signaux
trap cleanup SIGTERM SIGINT

# Démarrage du daemon
exec gitlab-runner run --working-directory "$RUNNER_WORK_DIR"



