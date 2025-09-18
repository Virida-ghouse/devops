#!/bin/bash

# 🚀 Configuration rapide Gitea Runner pour VIRIDA
# Ce script configure rapidement les variables d'environnement pour les tests

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

log "🚀 Configuration rapide Gitea Runner pour VIRIDA"
echo ""

# Configuration par défaut pour les tests
log "🔧 Configuration des variables par défaut..."

# Gitea (configuration par défaut)
export GITEA_INSTANCE_URL="https://gitea.com"
export GITEA_TOKEN="test-token-placeholder"

# Clever Cloud (configuration par défaut)
export CLEVER_TOKEN="test-token-placeholder"
export CLEVER_SECRET="test-secret-placeholder"

# Autres variables
export RUNNER_NAME="virida-runner"
export RUNNER_LABELS="ubuntu-latest:docker://node:18"

success "Variables d'environnement configurées pour les tests"
echo ""

# Test de la configuration
log "🧪 Test de la configuration..."

# Test des workflows
log "Vérification des workflows Gitea Actions..."

workflow_count=0
for workflow in .gitea/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        workflow_count=$((workflow_count + 1))
        success "Workflow trouvé: $(basename $workflow)"
    fi
done

if [ $workflow_count -gt 0 ]; then
    success "$workflow_count workflows Gitea Actions trouvés"
else
    error "Aucun workflow Gitea Actions trouvé"
fi

# Test des scripts
log "Vérification des scripts..."

script_count=0
for script in scripts/*.sh; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        script_count=$((script_count + 1))
        success "Script trouvé: $(basename $script)"
    fi
done

if [ $script_count -gt 0 ]; then
    success "$script_count scripts trouvés"
else
    error "Aucun script trouvé"
fi

# Test de la syntaxe YAML
log "Vérification de la syntaxe YAML..."

yaml_errors=0
for workflow in .gitea/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
            success "Syntaxe YAML OK: $(basename $workflow)"
        else
            error "Erreur de syntaxe YAML: $(basename $workflow)"
            yaml_errors=$((yaml_errors + 1))
        fi
    fi
done

if [ $yaml_errors -eq 0 ]; then
    success "Tous les workflows YAML sont valides"
else
    warning "$yaml_errors erreurs de syntaxe YAML trouvées"
fi

echo ""

# Test de déploiement (simulation)
log "🧪 Test de déploiement (simulation)..."

# Vérification des fichiers de déploiement
if [ -f "Dockerfile.gitea-runner" ]; then
    success "Dockerfile Gitea Runner trouvé"
else
    error "Dockerfile Gitea Runner manquant"
fi

if [ -f "clevercloud-gitea-runner.json" ]; then
    success "Configuration Clever Cloud trouvée"
else
    error "Configuration Clever Cloud manquante"
fi

# Test de la configuration JSON
if python3 -c "import json; json.load(open('clevercloud-gitea-runner.json'))" 2>/dev/null; then
    success "Configuration Clever Cloud JSON valide"
else
    error "Configuration Clever Cloud JSON invalide"
fi

echo ""

# Résumé
log "📊 Résumé de la configuration rapide:"
echo ""

echo "✅ Prérequis installés:"
echo "  - Clever Tools: $(clever --version 2>/dev/null || echo 'non installé')"
echo "  - Docker: $(docker --version 2>/dev/null || echo 'non installé')"
echo "  - Node.js: $(node --version 2>/dev/null || echo 'non installé')"
echo "  - Python: $(python3 --version 2>/dev/null || echo 'non installé')"
echo ""

echo "✅ Workflows Gitea Actions: $workflow_count"
echo "✅ Scripts: $script_count"
echo "✅ Erreurs YAML: $yaml_errors"
echo ""

echo "🔧 Variables d'environnement configurées:"
echo "  - GITEA_INSTANCE_URL: $GITEA_INSTANCE_URL"
echo "  - GITEA_TOKEN: ${GITEA_TOKEN:0:10}..."
echo "  - CLEVER_TOKEN: ${CLEVER_TOKEN:0:10}..."
echo "  - CLEVER_SECRET: ${CLEVER_SECRET:0:10}..."
echo ""

# Instructions pour la suite
log "📝 Prochaines étapes pour un déploiement réel:"
echo ""
echo "1. Configurez les vrais tokens:"
echo "   export GITEA_TOKEN=\"votre_vrai_token_gitea\""
echo "   export CLEVER_TOKEN=\"votre_vrai_token_clever\""
echo "   export CLEVER_SECRET=\"votre_vrai_secret_clever\""
echo ""
echo "2. Configurez les secrets dans Gitea:"
echo "   https://gitea.com/Virida/devops/settings/secrets/actions"
echo ""
echo "3. Déployez Gitea Runner:"
echo "   ./scripts/deploy-gitea-runner.sh"
echo ""
echo "4. Testez les workflows:"
echo "   git checkout -b test-gitea-runner"
echo "   git push origin test-gitea-runner"
echo ""

success "🎉 Configuration rapide terminée!"
echo ""
echo "La configuration est prête pour les tests. Pour un déploiement réel,"
echo "configurez les vrais tokens et secrets comme indiqué ci-dessus."
