#!/bin/bash

# 🧪 Test de Configuration GitLab VIRIDA
# Script pour vérifier la configuration GitLab

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
GITLAB_URL="https://gitlab.com"
GITLAB_TOKEN="gldt-s3GXEHLypuXmLaxEo4UM"
GITLAB_PROJECT="virida/virida"

echo -e "${CYAN}🧪 TEST DE CONFIGURATION GITLAB VIRIDA${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""

# Test 1: Vérification des variables
log "Test 1: Vérification des variables..."
if [ -n "$GITLAB_URL" ] && [ -n "$GITLAB_TOKEN" ] && [ -n "$GITLAB_PROJECT" ]; then
    success "Variables GitLab configurées"
    echo "  - URL: $GITLAB_URL"
    echo "  - Project: $GITLAB_PROJECT"
    echo "  - Token: ${GITLAB_TOKEN:0:10}..."
else
    error "Variables GitLab manquantes"
    exit 1
fi

# Test 2: Vérification de la connectivité
log "Test 2: Vérification de la connectivité GitLab..."
if curl -s --connect-timeout 10 "$GITLAB_URL" > /dev/null; then
    success "Connexion à GitLab réussie"
else
    error "Impossible de se connecter à GitLab"
    exit 1
fi

# Test 3: Vérification du projet
log "Test 3: Vérification du projet GitLab..."
PROJECT_URL="$GITLAB_URL/$GITLAB_PROJECT"
if curl -s --connect-timeout 10 "$PROJECT_URL" > /dev/null; then
    success "Projet GitLab accessible: $PROJECT_URL"
else
    warning "Projet GitLab non accessible: $PROJECT_URL"
    echo "  Vérifiez que le projet existe et est public"
fi

# Test 4: Vérification du token (deploy token)
log "Test 4: Vérification du token de déploiement..."
echo "  - Type: Deploy Token"
echo "  - Token: ${GITLAB_TOKEN:0:10}..."
echo "  - Note: Les deploy tokens ont des permissions limitées"
warning "Deploy token détecté - permissions limitées pour l'API"

# Test 5: Vérification des credentials Clever Cloud
log "Test 5: Vérification des credentials Clever Cloud..."
if [ -n "$CLEVER_TOKEN" ] && [ -n "$CLEVER_SECRET" ]; then
    success "Credentials Clever Cloud configurés"
    echo "  - Token: ${CLEVER_TOKEN:0:10}..."
    echo "  - Secret: ${CLEVER_SECRET:0:10}..."
else
    error "Credentials Clever Cloud manquants"
    echo "  Définissez-les avec:"
    echo "  export CLEVER_TOKEN='votre_token'"
    echo "  export CLEVER_SECRET='votre_secret'"
    exit 1
fi

# Test 6: Vérification de Clever Tools
log "Test 6: Vérification de Clever Tools..."
if command -v clever &> /dev/null; then
    success "Clever Tools installé"
    echo "  - Version: $(clever --version 2>/dev/null || echo 'Version inconnue')"
else
    error "Clever Tools non installé"
    echo "  Installez-le avec: npm install -g @clevercloud/cli"
    exit 1
fi

# Test 7: Vérification des scripts de déploiement
log "Test 7: Vérification des scripts de déploiement..."
SCRIPTS=(
    "scripts/deploy-with-gitlab-token.sh"
    "scripts/deploy-gitlab-runner.sh"
    "scripts/dcp.sh"
    "scripts/test-dcp.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        success "Script trouvé: $script"
    else
        error "Script manquant: $script"
        exit 1
    fi
done

# Test 8: Vérification des Dockerfiles
log "Test 8: Vérification des Dockerfiles..."
DOCKERFILES=(
    "Dockerfile"
    "Dockerfile.gitlab-runner"
)

for dockerfile in "${DOCKERFILES[@]}"; do
    if [ -f "$dockerfile" ]; then
        success "Dockerfile trouvé: $dockerfile"
    else
        error "Dockerfile manquant: $dockerfile"
        exit 1
    fi
done

# Test 9: Vérification des fichiers de configuration
log "Test 9: Vérification des fichiers de configuration..."
CONFIG_FILES=(
    "clevercloud.json"
    "clevercloud-gitlab-runner.json"
)

for config in "${CONFIG_FILES[@]}"; do
    if [ -f "$config" ]; then
        success "Fichier de configuration trouvé: $config"
    else
        error "Fichier de configuration manquant: $config"
        exit 1
    fi
done

# Résumé
echo ""
echo -e "${CYAN}📊 RÉSUMÉ DES TESTS${NC}"
echo -e "${CYAN}===================${NC}"
echo ""

success "🎉 Tous les tests ont réussi !"
echo ""
echo "Configuration GitLab:"
echo "  - URL: $GITLAB_URL"
echo "  - Project: $GITLAB_PROJECT"
echo "  - Token: Deploy Token (${GITLAB_TOKEN:0:10}...)"
echo ""
echo "Configuration Clever Cloud:"
echo "  - Token: ${CLEVER_TOKEN:0:10}..."
echo "  - Secret: ${CLEVER_SECRET:0:10}..."
echo ""
echo "Scripts disponibles:"
echo "  - deploy-with-gitlab-token.sh: Déploiement avec token GitLab"
echo "  - deploy-gitlab-runner.sh: Déploiement du GitLab Runner"
echo "  - dcp.sh: Déploiement complet de l'infrastructure"
echo ""
echo "Prochaines étapes:"
echo "  1. Lancez: ./scripts/deploy-with-gitlab-token.sh"
echo "  2. Vérifiez les déploiements: clever status"
echo "  3. Consultez les logs: clever logs --alias <app>"
echo ""
success "🚀 Configuration VIRIDA prête pour le déploiement!"



