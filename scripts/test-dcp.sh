#!/bin/bash

# 🧪 Test DCP - Vérification rapide de l'infrastructure VIRIDA

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
CLEVER_ALIAS_PREFIX="virida"
APPS=("frontend-3d" "ai-ml" "gitlab-runner")

echo -e "${CYAN}🧪 TEST DCP - VIRIDA INFRASTRUCTURE${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""

# Test 1: Vérification des credentials
log "Test 1: Vérification des credentials..."
if [ -n "$CLEVER_TOKEN" ] && [ -n "$CLEVER_SECRET" ]; then
    success "Credentials Clever Cloud configurés"
else
    error "Credentials Clever Cloud manquants"
    exit 1
fi

# Test 2: Vérification de Clever Tools
log "Test 2: Vérification de Clever Tools..."
if command -v clever &> /dev/null; then
    success "Clever Tools installé"
else
    error "Clever Tools non installé"
    exit 1
fi

# Test 3: Connexion Clever Cloud
log "Test 3: Connexion Clever Cloud..."
if clever status &> /dev/null; then
    success "Connexion Clever Cloud OK"
else
    error "Connexion Clever Cloud échouée"
    exit 1
fi

# Test 4: Vérification des applications
log "Test 4: Vérification des applications..."
for app in "${APPS[@]}"; do
    CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app}"
    if clever applications --json | grep -q "\"alias\": \"$CLEVER_ALIAS\""; then
        success "Application $app trouvée"
    else
        warning "Application $app non trouvée"
    fi
done

# Test 5: Vérification des fichiers
log "Test 5: Vérification des fichiers..."
files=(
    "scripts/dcp.sh"
    "scripts/devops-dashboard.sh"
    "scripts/deploy-devops-complete.sh"
    ".gitlab-ci.yml"
    "Dockerfile.gitlab-runner"
    "clevercloud-gitlab-runner.json"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        success "Fichier $file trouvé"
    else
        error "Fichier $file manquant"
    fi
done

# Test 6: Vérification des permissions
log "Test 6: Vérification des permissions..."
scripts=(
    "scripts/dcp.sh"
    "scripts/devops-dashboard.sh"
    "scripts/deploy-devops-complete.sh"
)

for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        success "Script $script exécutable"
    else
        error "Script $script non exécutable"
    fi
done

echo ""
log "📊 Résumé des tests:"
echo -e "${CYAN}  - Credentials: ${CLEVER_TOKEN:+✅}${CLEVER_TOKEN:-❌}${NC}"
echo -e "${CYAN}  - Clever Tools: $(command -v clever >/dev/null && echo '✅' || echo '❌')${NC}"
echo -e "${CYAN}  - Connexion: $(clever status >/dev/null 2>&1 && echo '✅' || echo '❌')${NC}"
echo -e "${CYAN}  - Fichiers: $(ls scripts/dcp.sh >/dev/null 2>&1 && echo '✅' || echo '❌')${NC}"
echo ""

if [ -n "$CLEVER_TOKEN" ] && [ -n "$CLEVER_SECRET" ] && command -v clever &> /dev/null; then
    success "🎉 Tests DCP réussis - Prêt pour le déploiement!"
    echo ""
    log "Pour déployer l'infrastructure VIRIDA:"
    echo -e "${CYAN}  ./scripts/dcp.sh${NC}"
    echo ""
    log "Pour lancer le dashboard:"
    echo -e "${CYAN}  ./scripts/devops-dashboard.sh${NC}"
else
    error "❌ Tests DCP échoués - Vérifiez la configuration"
fi



