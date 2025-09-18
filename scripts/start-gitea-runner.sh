#!/bin/bash

# 🚁 Script de démarrage Gitea Runner pour VIRIDA
# Ce script configure et démarre Gitea Runner avec les paramètres optimaux

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
GITEA_INSTANCE_URL=${GITEA_INSTANCE_URL:-"https://gitea.com"}
GITEA_TOKEN=${GITEA_TOKEN:-""}
RUNNER_NAME=${RUNNER_NAME:-"virida-runner"}
RUNNER_LABELS=${RUNNER_LABELS:-"ubuntu-latest:docker://node:18"}
RUNNER_WORK_DIR=${RUNNER_WORK_DIR:-"/workspace"}

log "🚁 Démarrage de Gitea Runner pour VIRIDA"
log "Instance Gitea: $GITEA_INSTANCE_URL"
log "Nom du runner: $RUNNER_NAME"
log "Labels: $RUNNER_LABELS"

# Vérification des variables d'environnement
if [ -z "$GITEA_TOKEN" ]; then
    error "GITEA_TOKEN n'est pas défini"
    exit 1
fi

# Vérification de la connectivité Gitea
log "🔍 Vérification de la connectivité Gitea..."
if ! curl -s -f "$GITEA_INSTANCE_URL/api/v1/version" > /dev/null; then
    error "Impossible de se connecter à Gitea: $GITEA_INSTANCE_URL"
    exit 1
fi
success "Connectivité Gitea OK"

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

# Configuration du runner si nécessaire
if [ ! -f "$RUNNER_WORK_DIR/.runner" ]; then
    log "🔧 Configuration du runner..."
    
    # Création du répertoire de travail
    mkdir -p "$RUNNER_WORK_DIR"
    
    # Enregistrement du runner
    act_runner register \
        --instance "$GITEA_INSTANCE_URL" \
        --token "$GITEA_TOKEN" \
        --name "$RUNNER_NAME" \
        --labels "$RUNNER_LABELS" \
        --workdir "$RUNNER_WORK_DIR" \
        --no-interactive
    
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
log "🚀 Démarrage du runner Gitea..."
success "Gitea Runner démarré avec succès"

# Fonction de nettoyage
cleanup() {
    log "🧹 Arrêt du runner..."
    success "Runner arrêté proprement"
    exit 0
}

# Gestion des signaux
trap cleanup SIGTERM SIGINT

# Démarrage du daemon
exec act_runner daemon --workdir "$RUNNER_WORK_DIR"
