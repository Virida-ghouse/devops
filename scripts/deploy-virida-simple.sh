#!/bin/bash

# 🚀 Déploiement VIRIDA Simple
# Script qui se reconnecte à chaque commande

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
CLEVER_TOKEN="jc/hmJwXA1Lyv727qXylA6/+aKWvRapBn2ZSYGYy9F7cxg+0goPc4wS41DLCKt+vpC4="
CLEVER_SECRET="virida.ghouse@gmail.com"

echo -e "${CYAN}🚀 DÉPLOIEMENT VIRIDA SIMPLE${NC}"
echo -e "${CYAN}=============================${NC}"
echo ""

# Fonction de connexion
connect_clever() {
    log "🔐 Connexion à Clever Cloud..."
    clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET" &> /dev/null
    if [ $? -eq 0 ]; then
        success "Connexion réussie"
        return 0
    else
        error "Échec de la connexion"
        return 1
    fi
}

# Vérification des applications
log "📋 Vérification des applications VIRIDA..."
connect_clever
clever applications

echo ""
log "🔧 Configuration et redéploiement des applications..."

# Configuration de Gitea
log "🦊 Configuration de Gitea..."
connect_clever
clever link virida-gitea

# Variables Gitea
connect_clever
clever env set GITEA__database__DB_TYPE "postgres" --alias virida-gitea
clever env set GITEA__database__HOST "bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:50013" --alias virida-gitea
clever env set GITEA__database__NAME "gitea" --alias virida-gitea
clever env set GITEA__database__PASSWD "WuobPl6Nyk9X0Z4DKF7BlxE55z2buu" --alias virida-gitea
clever env set GITEA__database__USER "uncer3i7fyqs2zeult6r" --alias virida-gitea
clever env set GITEA__server__DOMAIN "gitea.cleverapps.io" --alias virida-gitea
clever env set GITEA__server__HTTP_PORT "3000" --alias virida-gitea
clever env set GITEA__server__ROOT_URL "https://gitea.cleverapps.io" --alias virida-gitea

# Variables communes pour Gitea
connect_clever
clever env set BUCKET_FTP_PASSWORD "Odny785DsL9LYBZc" --alias virida-gitea
clever env set BUCKET_FTP_USERNAME "ua9e0425888f" --alias virida-gitea
clever env set BUCKET_HOST "bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com" --alias virida-gitea
clever env set POSTGRESQL_ADDON_HOST "bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com" --alias virida-gitea
clever env set POSTGRESQL_ADDON_DB "bjduvaldxkbwljy3uuel" --alias virida-gitea
clever env set POSTGRESQL_ADDON_USER "uncer3i7fyqs2zeult6r" --alias virida-gitea
clever env set POSTGRESQL_ADDON_PORT "50013" --alias virida-gitea
clever env set POSTGRESQL_ADDON_PASSWORD "WuobPl6Nyk9X0Z4DKF7BlxE55z2buu" --alias virida-gitea

# Redéploiement de Gitea
log "🚀 Redéploiement de Gitea..."
connect_clever
clever deploy --alias virida-gitea
success "Gitea redéployé"

# Configuration du Frontend 3D
log "🟢 Configuration du Frontend 3D..."
connect_clever
clever link virida-frontend-3d
clever env set NODE_VERSION "18" --alias virida-frontend-3d
clever env set PORT "3000" --alias virida-frontend-3d
clever env set NODE_ENV "production" --alias virida-frontend-3d

# Variables communes pour Frontend 3D
connect_clever
clever env set BUCKET_FTP_PASSWORD "Odny785DsL9LYBZc" --alias virida-frontend-3d
clever env set BUCKET_FTP_USERNAME "ua9e0425888f" --alias virida-frontend-3d
clever env set BUCKET_HOST "bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com" --alias virida-frontend-3d

# Redéploiement du Frontend 3D
log "🚀 Redéploiement du Frontend 3D..."
connect_clever
clever deploy --alias virida-frontend-3d
success "Frontend 3D redéployé"

# Configuration du Gitea Runner
log "🟡 Configuration du Gitea Runner..."
connect_clever
clever link virida-gitea-runner
clever env set GITEA_URL "https://gitea.cleverapps.io" --alias virida-gitea-runner
clever env set GITEA_TOKEN "3bM8aXd0YAwAnZJlUsad9Jn7H8TnzPrnzTrCSIJrLK8=" --alias virida-gitea-runner
clever env set RUNNER_NAME "virida-gitea-runner" --alias virida-gitea-runner
clever env set RUNNER_LABELS "ubuntu-latest,docker,clever-cloud" --alias virida-gitea-runner

# Variables communes pour Gitea Runner
connect_clever
clever env set BUCKET_FTP_PASSWORD "Odny785DsL9LYBZc" --alias virida-gitea-runner
clever env set BUCKET_FTP_USERNAME "ua9e0425888f" --alias virida-gitea-runner
clever env set BUCKET_HOST "bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com" --alias virida-gitea-runner

# Redéploiement du Gitea Runner
log "🚀 Redéploiement du Gitea Runner..."
connect_clever
clever deploy --alias virida-gitea-runner
success "Gitea Runner redéployé"

# Vérification finale
log "🔍 Vérification finale..."
sleep 30

echo ""
log "📊 STATUT FINAL DES APPLICATIONS:"
echo "================================"

for app in virida-gitea virida-frontend-3d virida-gitea-runner; do
    echo ""
    log "🔍 $app:"
    connect_clever
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



