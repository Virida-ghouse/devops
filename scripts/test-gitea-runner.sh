#!/bin/bash

# 🧪 Script de test Gitea Runner pour VIRIDA
# Ce script teste la configuration et les workflows

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

log "🧪 Test de la configuration Gitea Runner pour VIRIDA"
echo ""

# Test 1: Vérification des prérequis
log "🔍 Test 1: Vérification des prérequis..."

# Clever Tools
if command -v clever &> /dev/null; then
    success "Clever Tools installé"
    clever --version
else
    error "Clever Tools non installé"
    exit 1
fi

# Docker
if command -v docker &> /dev/null; then
    success "Docker installé"
    docker --version
else
    warning "Docker non installé (optionnel pour le développement local)"
fi

# Node.js
if command -v node &> /dev/null; then
    success "Node.js installé: $(node --version)"
else
    warning "Node.js non installé"
fi

# Python
if command -v python3 &> /dev/null; then
    success "Python installé: $(python3 --version)"
else
    warning "Python non installé"
fi

echo ""

# Test 2: Vérification des variables d'environnement
log "🔍 Test 2: Vérification des variables d'environnement..."

# Charger les variables d'environnement
source ~/.bashrc 2>/dev/null || true
source ~/.zshrc 2>/dev/null || true

# Clever Cloud
if [ -n "$CLEVER_TOKEN" ] && [ -n "$CLEVER_SECRET" ]; then
    success "Variables Clever Cloud configurées"
    
    # Test de connexion
    log "🔐 Test de connexion Clever Cloud..."
    if clever status &> /dev/null; then
        success "Connexion Clever Cloud OK"
    else
        warning "Connexion Clever Cloud échouée"
    fi
else
    warning "Variables Clever Cloud non configurées"
    echo "Configurez avec: export CLEVER_TOKEN=\"your_token\" && export CLEVER_SECRET=\"your_secret\""
fi

# Gitea
if [ -n "$GITEA_INSTANCE_URL" ] && [ -n "$GITEA_TOKEN" ]; then
    success "Variables Gitea configurées"
    
    # Test de connexion
    log "🔐 Test de connexion Gitea..."
    if curl -s -f "$GITEA_INSTANCE_URL/api/v1/version" > /dev/null; then
        success "Connexion Gitea OK"
    else
        warning "Connexion Gitea échouée"
    fi
else
    warning "Variables Gitea non configurées"
    echo "Configurez avec: export GITEA_INSTANCE_URL=\"https://gitea.com\" && export GITEA_TOKEN=\"your_token\""
fi

echo ""

# Test 3: Vérification des fichiers
log "🔍 Test 3: Vérification des fichiers..."

# Workflows Gitea Actions
if [ -f ".gitea/workflows/ci-cd.yml" ]; then
    success "Workflow CI/CD trouvé"
else
    error "Workflow CI/CD manquant"
fi

if [ -f ".gitea/workflows/pr-validation.yml" ]; then
    success "Workflow PR validation trouvé"
else
    error "Workflow PR validation manquant"
fi

if [ -f ".gitea/workflows/release.yml" ]; then
    success "Workflow release trouvé"
else
    error "Workflow release manquant"
fi

# Dockerfile
if [ -f "Dockerfile.gitea-runner" ]; then
    success "Dockerfile Gitea Runner trouvé"
else
    error "Dockerfile Gitea Runner manquant"
fi

# Scripts
if [ -f "scripts/deploy-gitea-runner.sh" ]; then
    success "Script de déploiement trouvé"
else
    error "Script de déploiement manquant"
fi

if [ -f "scripts/start-gitea-runner.sh" ]; then
    success "Script de démarrage trouvé"
else
    error "Script de démarrage manquant"
fi

echo ""

# Test 4: Vérification de la syntaxe YAML
log "🔍 Test 4: Vérification de la syntaxe YAML..."

# Vérification avec Python (si disponible)
if command -v python3 &> /dev/null; then
    log "Vérification de la syntaxe des workflows..."
    
    for workflow in .gitea/workflows/*.yml; do
        if [ -f "$workflow" ]; then
            if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
                success "Syntaxe YAML OK: $(basename $workflow)"
            else
                error "Erreur de syntaxe YAML: $(basename $workflow)"
            fi
        fi
    done
else
    warning "Python non disponible pour la vérification YAML"
fi

echo ""

# Test 5: Test de déploiement (simulation)
log "🔍 Test 5: Test de déploiement (simulation)..."

if [ -n "$CLEVER_TOKEN" ] && [ -n "$CLEVER_SECRET" ]; then
    log "Simulation du déploiement..."
    
    # Vérification de la configuration Clever Cloud
    if clever applications --json &> /dev/null; then
        success "Configuration Clever Cloud OK"
        
        # Vérification des applications existantes
        log "Applications Clever Cloud existantes:"
        clever applications --json | jq -r '.[].name' 2>/dev/null || echo "Aucune application trouvée"
    else
        warning "Impossible de récupérer les applications Clever Cloud"
    fi
else
    warning "Variables Clever Cloud non configurées - test de déploiement ignoré"
fi

echo ""

# Test 6: Test des workflows (simulation)
log "🔍 Test 6: Test des workflows (simulation)..."

if [ -n "$GITEA_INSTANCE_URL" ] && [ -n "$GITEA_TOKEN" ]; then
    log "Test de l'API Gitea..."
    
    # Test de l'API Gitea
    if curl -s -H "Authorization: token $GITEA_TOKEN" "$GITEA_INSTANCE_URL/api/v1/user" > /dev/null; then
        success "API Gitea accessible"
        
        # Test de l'API Actions
        if curl -s -H "Authorization: token $GITEA_TOKEN" "$GITEA_INSTANCE_URL/api/v1/repos/Virida/devops/actions/runs" > /dev/null; then
            success "API Gitea Actions accessible"
        else
            warning "API Gitea Actions non accessible (normal si le repository n'existe pas encore)"
        fi
    else
        warning "API Gitea non accessible"
    fi
else
    warning "Variables Gitea non configurées - test des workflows ignoré"
fi

echo ""

# Résumé des tests
log "📊 Résumé des tests:"
echo ""

# Compter les succès et échecs
total_tests=0
passed_tests=0

# Test des prérequis
total_tests=$((total_tests + 4))
if command -v clever &> /dev/null; then passed_tests=$((passed_tests + 1)); fi
if command -v docker &> /dev/null; then passed_tests=$((passed_tests + 1)); fi
if command -v node &> /dev/null; then passed_tests=$((passed_tests + 1)); fi
if command -v python3 &> /dev/null; then passed_tests=$((passed_tests + 1)); fi

# Test des variables d'environnement
total_tests=$((total_tests + 2))
if [ -n "$CLEVER_TOKEN" ] && [ -n "$CLEVER_SECRET" ]; then passed_tests=$((passed_tests + 1)); fi
if [ -n "$GITEA_INSTANCE_URL" ] && [ -n "$GITEA_TOKEN" ]; then passed_tests=$((passed_tests + 1)); fi

# Test des fichiers
total_tests=$((total_tests + 6))
if [ -f ".gitea/workflows/ci-cd.yml" ]; then passed_tests=$((passed_tests + 1)); fi
if [ -f ".gitea/workflows/pr-validation.yml" ]; then passed_tests=$((passed_tests + 1)); fi
if [ -f ".gitea/workflows/release.yml" ]; then passed_tests=$((passed_tests + 1)); fi
if [ -f "Dockerfile.gitea-runner" ]; then passed_tests=$((passed_tests + 1)); fi
if [ -f "scripts/deploy-gitea-runner.sh" ]; then passed_tests=$((passed_tests + 1)); fi
if [ -f "scripts/start-gitea-runner.sh" ]; then passed_tests=$((passed_tests + 1)); fi

# Affichage du résumé
echo "Tests passés: $passed_tests/$total_tests"

if [ $passed_tests -eq $total_tests ]; then
    success "🎉 Tous les tests sont passés! Configuration prête pour le déploiement."
    echo ""
    echo "Prochaines étapes:"
    echo "1. Configurez les secrets dans Gitea"
    echo "2. Déployez Gitea Runner: ./scripts/deploy-gitea-runner.sh"
    echo "3. Testez les workflows"
elif [ $passed_tests -gt $((total_tests / 2)) ]; then
    warning "⚠️ La plupart des tests sont passés. Configuration partiellement prête."
    echo ""
    echo "Actions recommandées:"
    echo "1. Configurez les variables d'environnement manquantes"
    echo "2. Vérifiez les fichiers manquants"
    echo "3. Relancez le test: ./scripts/test-gitea-runner.sh"
else
    error "❌ Plusieurs tests ont échoué. Configuration incomplète."
    echo ""
    echo "Actions requises:"
    echo "1. Installez les prérequis manquants"
    echo "2. Configurez les variables d'environnement"
    echo "3. Vérifiez l'intégrité des fichiers"
    echo "4. Relancez le test: ./scripts/test-gitea-runner.sh"
fi

echo ""
success "🧪 Test Gitea Runner terminé!"
