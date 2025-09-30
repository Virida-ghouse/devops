#!/bin/bash

# 🚁 Script de déploiement simplifié Gitea Runner pour VIRIDA
# Ce script déploie le Gitea runner sans vérification de connectivité

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
ORGANIZATION_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"

log "🚁 Déploiement simplifié Gitea Runner pour VIRIDA"
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

# Étape 3: Configuration Gitea
log "📋 Étape 3: Configuration Gitea..."

# Configuration Gitea avec les valeurs fournies
GITEA_INSTANCE_URL="https://gitea.cleverapps.io"
GITEA_DOMAIN="gitea.cleverapps.io"
GITEA_HTTP_PORT="3000"
GITEA_ROOT_URL="https://gitea.cleverapps.io"

# Variables de base de données Gitea
GITEA_DB_TYPE="postgres"
GITEA_DB_HOST="bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:50013"
GITEA_DB_NAME="gitea"
GITEA_DB_PASSWD="WuobPl6Nyk9X0Z4DKF7BlxE55z2buu"
GITEA_DB_USER="uncer3i7fyqs2zeult6r"

# Token Gitea
GITEA_TOKEN="3bM8aXd0YAwAnZJlUsad9Jn7H8TnzPrnzTrCSIJrLK8="

log "Configuration Gitea:"
echo "  - URL: $GITEA_INSTANCE_URL"
echo "  - Token: ${GITEA_TOKEN:0:10}..."
echo ""

# Étape 4: Configuration des variables
log "📋 Étape 4: Configuration des variables..."

# Variables par défaut
RUNNER_NAME="virida-runner"
RUNNER_LABELS="ubuntu-latest:docker://node:18,ubuntu-20.04:docker://node:18,ubuntu-22.04:docker://node:22"
RUNNER_WORK_DIR="/workspace"

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
clever env set GITEA_INSTANCE_URL "$GITEA_INSTANCE_URL" --alias "$CLEVER_ALIAS"
clever env set GITEA_TOKEN "$GITEA_TOKEN" --alias "$CLEVER_ALIAS"
clever env set RUNNER_NAME "$RUNNER_NAME" --alias "$CLEVER_ALIAS"
clever env set RUNNER_LABELS "$RUNNER_LABELS" --alias "$CLEVER_ALIAS"
clever env set RUNNER_WORK_DIR "$RUNNER_WORK_DIR" --alias "$CLEVER_ALIAS"
clever env set DOCKER_BUILDKIT "1" --alias "$CLEVER_ALIAS"
clever env set COMPOSE_DOCKER_CLI_BUILD "1" --alias "$CLEVER_ALIAS"

# Variables Gitea
clever env set GITEA__database__DB_TYPE "$GITEA_DB_TYPE" --alias "$CLEVER_ALIAS"
clever env set GITEA__database__HOST "$GITEA_DB_HOST" --alias "$CLEVER_ALIAS"
clever env set GITEA__database__NAME "$GITEA_DB_NAME" --alias "$CLEVER_ALIAS"
clever env set GITEA__database__PASSWD "$GITEA_DB_PASSWD" --alias "$CLEVER_ALIAS"
clever env set GITEA__database__USER "$GITEA_DB_USER" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__DOMAIN "$GITEA_DOMAIN" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__HTTP_PORT "$GITEA_HTTP_PORT" --alias "$CLEVER_ALIAS"
clever env set GITEA__server__ROOT_URL "$GITEA_ROOT_URL" --alias "$CLEVER_ALIAS"

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
log "📋 Étape 6: Déploiement de Gitea Runner..."

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



