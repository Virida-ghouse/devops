#!/bin/bash

# 🚁 Script de déploiement Gitea Runner pour VIRIDA
# Ce script déploie Gitea Runner sur Clever Cloud

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
APP_NAME="gitea-runner"
CLEVER_ALIAS="virida-gitea-runner"
DOCKERFILE="Dockerfile.gitea-runner"
CONFIG_FILE="clevercloud-gitea-runner.json"

log "🚁 Déploiement de Gitea Runner pour VIRIDA"

# Vérification des prérequis
log "🔍 Vérification des prérequis..."

# Vérification de Clever Tools
if ! command -v clever &> /dev/null; then
    error "Clever Tools n'est pas installé"
    log "Installation de Clever Tools..."
    npm install -g clever-tools
fi

# Vérification de la connexion Clever Cloud
if ! clever status &> /dev/null; then
    warning "Non connecté à Clever Cloud"
    log "Connexion à Clever Cloud..."
    if [ -z "$CLEVER_TOKEN" ] || [ -z "$CLEVER_SECRET" ]; then
        error "CLEVER_TOKEN et CLEVER_SECRET doivent être définis"
        exit 1
    fi
    clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET"
fi

success "Prérequis OK"

# Vérification des fichiers
log "📁 Vérification des fichiers..."

if [ ! -f "$DOCKERFILE" ]; then
    error "Dockerfile non trouvé: $DOCKERFILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    error "Fichier de configuration non trouvé: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "scripts/start-gitea-runner.sh" ]; then
    error "Script de démarrage non trouvé: scripts/start-gitea-runner.sh"
    exit 1
fi

success "Fichiers OK"

# Création de l'application Clever Cloud
log "🏗️ Création de l'application Clever Cloud..."

# Vérification si l'application existe déjà
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

# Variables obligatoires
REQUIRED_VARS=(
    "GITEA_INSTANCE_URL"
    "GITEA_TOKEN"
    "RUNNER_NAME"
    "RUNNER_LABELS"
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        error "Variable d'environnement manquante: $var"
        log "Veuillez définir $var avant de continuer"
        exit 1
    fi
done

# Configuration des variables dans Clever Cloud
clever env set GITEA_INSTANCE_URL "$GITEA_INSTANCE_URL" --alias "$CLEVER_ALIAS"
clever env set GITEA_TOKEN "$GITEA_TOKEN" --alias "$CLEVER_ALIAS"
clever env set RUNNER_NAME "$RUNNER_NAME" --alias "$CLEVER_ALIAS"
clever env set RUNNER_LABELS "$RUNNER_LABELS" --alias "$CLEVER_ALIAS"
clever env set RUNNER_WORK_DIR "/workspace" --alias "$CLEVER_ALIAS"
clever env set DOCKER_BUILDKIT "1" --alias "$CLEVER_ALIAS"
clever env set COMPOSE_DOCKER_CLI_BUILD "1" --alias "$CLEVER_ALIAS"

success "Variables d'environnement configurées"

# Déploiement
log "🚀 Déploiement de Gitea Runner..."

# Copie des fichiers nécessaires
cp "$DOCKERFILE" Dockerfile
cp "$CONFIG_FILE" clevercloud.json

# Déploiement
clever deploy --alias "$CLEVER_ALIAS" --same-commit-policy rebuild

if [ $? -eq 0 ]; then
    success "Déploiement réussi!"
else
    error "Échec du déploiement"
    exit 1
fi

# Vérification du déploiement
log "🧪 Vérification du déploiement..."

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

success "🎉 Gitea Runner déployé avec succès!"

# Instructions finales
log "📝 Prochaines étapes:"
echo "  1. Vérifiez les logs: clever logs --alias $CLEVER_ALIAS"
echo "  2. Configurez les secrets dans Gitea"
echo "  3. Testez les workflows Gitea Actions"
echo "  4. Configurez les notifications Slack/Email"

# Nettoyage
rm -f Dockerfile clevercloud.json

success "🚁 Déploiement Gitea Runner terminé!"
