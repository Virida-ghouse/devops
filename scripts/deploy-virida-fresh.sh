#!/bin/bash

# 🚀 Déploiement VIRIDA - Version Fraîche
# Script pour redéployer toutes les applications VIRIDA

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

echo -e "${CYAN}🚀 DÉPLOIEMENT VIRIDA - VERSION FRAÎCHE${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

# Vérification des credentials
log "🔍 Vérification des credentials Clever Cloud..."
if [ -z "$CLEVER_TOKEN" ] || [ -z "$CLEVER_SECRET" ]; then
    error "Credentials Clever Cloud manquants"
    echo ""
    echo "Pour obtenir vos credentials :"
    echo "1. Allez sur https://console.clever-cloud.com"
    echo "2. Connectez-vous avec votre compte"
    echo "3. Cliquez sur votre profil > API Keys"
    echo "4. Créez une nouvelle clé API"
    echo "5. Configurez les variables :"
    echo "   export CLEVER_TOKEN=\"votre_token\""
    echo "   export CLEVER_SECRET=\"votre_secret\""
    echo ""
    exit 1
fi

success "Credentials Clever Cloud configurés"

# Connexion à Clever Cloud
log "🔐 Connexion à Clever Cloud..."
if clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET" &> /dev/null; then
    success "Connexion Clever Cloud réussie"
else
    error "Échec de la connexion Clever Cloud"
    echo "Vérifiez vos credentials et réessayez"
    exit 1
fi

# Vérification des applications existantes
log "📋 Vérification des applications existantes..."
clever applications

echo ""
log "🔧 Configuration des applications VIRIDA..."

# Configuration de Gitea
log "🦊 Configuration de Gitea..."
clever link virida-gitea
clever env set GITEA__database__DB_TYPE "postgres" --alias virida-gitea
clever env set GITEA__database__HOST "bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:50013" --alias virida-gitea
clever env set GITEA__database__NAME "gitea" --alias virida-gitea
clever env set GITEA__database__PASSWD "WuobPl6Nyk9X0Z4DKF7BlxE55z2buu" --alias virida-gitea
clever env set GITEA__database__USER "uncer3i7fyqs2zeult6r" --alias virida-gitea
clever env set GITEA__server__DOMAIN "gitea.cleverapps.io" --alias virida-gitea
clever env set GITEA__server__HTTP_PORT "3000" --alias virida-gitea
clever env set GITEA__server__ROOT_URL "https://gitea.cleverapps.io" --alias virida-gitea

# Configuration du Frontend 3D
log "🟢 Configuration du Frontend 3D..."
clever link virida-frontend-3d
clever env set NODE_VERSION "18" --alias virida-frontend-3d
clever env set PORT "3000" --alias virida-frontend-3d
clever env set NODE_ENV "production" --alias virida-frontend-3d

# Configuration du Gitea Runner
log "🟡 Configuration du Gitea Runner..."
clever link virida-gitea-runner
clever env set GITEA_URL "https://gitea.cleverapps.io" --alias virida-gitea-runner
clever env set GITEA_TOKEN "3bM8aXd0YAwAnZJlUsad9Jn7H8TnzPrnzTrCSIJrLK8=" --alias virida-gitea-runner
clever env set RUNNER_NAME "virida-gitea-runner" --alias virida-gitea-runner
clever env set RUNNER_LABELS "ubuntu-latest,docker,clever-cloud" --alias virida-gitea-runner

# Variables communes (Bucket et PostgreSQL)
log "📦 Configuration des variables communes..."
for app in virida-gitea virida-frontend-3d virida-gitea-runner; do
    log "Configuration de $app..."
    clever env set BUCKET_FTP_PASSWORD "Odny785DsL9LYBZc" --alias "$app"
    clever env set BUCKET_FTP_USERNAME "ua9e0425888f" --alias "$app"
    clever env set BUCKET_HOST "bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com" --alias "$app"
    clever env set POSTGRESQL_ADDON_HOST "bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com" --alias "$app"
    clever env set POSTGRESQL_ADDON_DB "bjduvaldxkbwljy3uuel" --alias "$app"
    clever env set POSTGRESQL_ADDON_USER "uncer3i7fyqs2zeult6r" --alias "$app"
    clever env set POSTGRESQL_ADDON_PORT "50013" --alias "$app"
    clever env set POSTGRESQL_ADDON_PASSWORD "WuobPl6Nyk9X0Z4DKF7BlxE55z2buu" --alias "$app"
    clever env set POSTGRESQL_ADDON_URI "postgresql://uncer3i7fyqs2zeult6r:WuobPl6Nyk9X0Z4DKF7BlxE55z2buu@bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:5432/bjduvaldxkbwljy3uuel" --alias "$app"
done

# Redéploiement des applications
log "🚀 Redéploiement des applications..."

for app in virida-gitea virida-frontend-3d virida-gitea-runner; do
    log "Redéploiement de $app..."
    clever deploy --alias "$app"
    if [ $? -eq 0 ]; then
        success "Redéploiement de $app réussi"
    else
        error "Échec du redéploiement de $app"
    fi
    echo ""
done

# Vérification finale
log "🔍 Vérification finale des applications..."
sleep 30

echo ""
log "📊 STATUT FINAL DES APPLICATIONS:"
echo "================================"

for app in virida-gitea virida-frontend-3d virida-gitea-runner; do
    echo ""
    log "🔍 $app:"
    clever status --alias "$app" || echo "❌ Erreur de statut"
done

echo ""
log "🌐 URLs des applications:"
echo "Frontend 3D: https://virida-frontend-3d.cleverapps.io"
echo "Gitea: https://virida-gitea.cleverapps.io"
echo "Gitea Runner: https://virida-gitea-runner.cleverapps.io"

echo ""
success "🎉 Déploiement VIRIDA terminé !"
echo ""
log "📝 Prochaines étapes:"
echo "1. Vérifiez les URLs des applications"
echo "2. Consultez les logs si nécessaire: clever logs --alias <app>"
echo "3. Configurez GitLab CI/CD si souhaité"
echo ""
success "🚀 Infrastructure VIRIDA opérationnelle !"



