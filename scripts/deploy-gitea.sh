#!/bin/bash

# 🐙 Script de déploiement Gitea pour VIRIDA
# Ce script déploie Gitea sur Clever Cloud avec PostgreSQL

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

log "🐙 Déploiement de Gitea pour VIRIDA"
echo ""

# Configuration
APP_NAME="gitea"
CLEVER_ALIAS="virida-gitea"
DOCKERFILE="Dockerfile.gitea"
CONFIG_FILE="clevercloud-gitea.json"

# Vérification des prérequis
log "🔍 Vérification des prérequis..."

# Vérification de Clever Tools
if ! command -v clever &> /dev/null; then
    error "Clever Tools n'est pas installé"
    exit 1
fi

# Vérification de la connexion Clever Cloud
if ! clever status &> /dev/null; then
    warning "Non connecté à Clever Cloud"
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

# Variables PostgreSQL
clever env set GITEA__database__DB_TYPE "postgres" --alias "$CLEVER_ALIAS"
clever env set GITEA__database__HOST "bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:50013" --alias "$CLEVER_ALIAS"
clever env set GITEA__database__NAME "gitea" --alias "$CLEVER_ALIAS"
clever env set GITEA__database__USER "uncer3i7fyqs2zeult6r" --alias "$CLEVER_ALIAS"
clever env set GITEA__database__PASSWD "WuobPl6Nyk9X0Z4DKF7BlxE55z2buu" --alias "$CLEVER_ALIAS"

# Configuration Gitea
clever env set GITEA__server__DOMAIN "gitea.cleverapps.io" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__ROOT_URL "https://gitea.cleverapps.io" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__SSH_DOMAIN "gitea.cleverapps.io" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__SSH_PORT "22" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__HTTP_PORT "3000" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__PROTOCOL "https" --alias "$CLEVER_ALIAS"

# Sécurité
clever env set GITEA__security__INSTALL_LOCK "true" --alias "$CLEVER_ALIAS"
clever env set GITEA__security__SECRET_KEY "gitea-secret-key-2024" --alias "$CLEVER_ALIAS"
clever env set GITEA__security__INTERNAL_TOKEN "gitea-internal-token-2024" --alias "$CLEVER_ALIAS"
clever env set GITEA__security__JWT_SECRET "gitea-jwt-secret-2024" --alias "$CLEVER_ALIAS"

# Service
clever env set GITEA__service__DISABLE_REGISTRATION "false" --alias "$CLEVER_ALIAS"
clever env set GITEA__service__REQUIRE_SIGNIN_VIEW "false" --alias "$CLEVER_ALIAS"

# Logs
clever env set GITEA__log__LEVEL "Info" --alias "$CLEVER_ALIAS"
clever env set GITEA__log__ROOT_PATH "/data/gitea/log" --alias "$CLEVER_ALIAS"

# Repository
clever env set GITEA__repository__ROOT "/data/git/repositories" --alias "$CLEVER_ALIAS"
clever env set GITEA__repository__LOCAL_LOCAL_COPY_PATH "/data/gitea/tmp/local-repo" --alias "$CLEVER_ALIAS"
clever env set GITEA__repository__LOCAL_WIKI_PATH "/data/gitea/tmp/local-wiki" --alias "$CLEVER_ALIAS"
clever env set GITEA__repository__UPLOAD_PATH "/data/gitea/tmp/uploads" --alias "$CLEVER_ALIAS"

# LFS
clever env set GITEA__server__LFS_START_SERVER "true" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__LFS_CONTENT_PATH "/data/git/lfs" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__LFS_JWT_SECRET "gitea-lfs-jwt-secret-key-2024" --alias "$CLEVER_ALIAS"

# Cron
clever env set GITEA__cron__ENABLED "true" --alias "$CLEVER_ALIAS"
clever env set GITEA__cron__RUN_AT_START "true" --alias "$CLEVER_ALIAS"

# Actions
clever env set GITEA__actions__ENABLED "true" --alias "$CLEVER_ALIAS"
clever env set GITEA__actions__DEFAULT_ACTIONS_URL "https://gitea.com" --alias "$CLEVER_ALIAS"
clever env set GITEA__actions__ENABLE_ACTIONS "true" --alias "$CLEVER_ALIAS"

success "Variables d'environnement configurées"

# Déploiement
log "🚀 Déploiement de Gitea..."

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
log "⏳ Attente du démarrage (120s)..."
sleep 120

# Vérification des logs
log "📋 Vérification des logs..."
clever logs --alias "$CLEVER_ALIAS" --after "5m" || echo "Logs non disponibles"

# Vérification du statut
log "📊 Vérification du statut..."
clever status --alias "$CLEVER_ALIAS"

# Affichage des informations
log "📋 Informations de déploiement:"
echo "  - Application: $CLEVER_ALIAS"
echo "  - URL: https://gitea.cleverapps.io"
echo "  - Type: Docker (Gitea)"
echo "  - Base de données: PostgreSQL"

success "🎉 Gitea déployé avec succès!"

# Instructions finales
log "📝 Prochaines étapes:"
echo "1. Accédez à https://gitea.cleverapps.io"
echo "2. Configurez l'installation initiale"
echo "3. Créez un utilisateur administrateur"
echo "4. Configurez les repositories"
echo "5. Déployez Gitea Runner"

# Nettoyage
rm -f Dockerfile clevercloud.json

success "🐙 Déploiement Gitea terminé!"
