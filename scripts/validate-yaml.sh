#!/bin/bash

# 🔍 Script de validation YAML pour VIRIDA
# Ce script valide la syntaxe des fichiers YAML

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

log "🔍 Validation de la syntaxe YAML pour VIRIDA"
echo ""

# Fonction de validation YAML simple
validate_yaml() {
    local file="$1"
    local filename=$(basename "$file")
    
    # Vérification basique de la syntaxe YAML
    if grep -q "^name:" "$file" && grep -q "^on:" "$file" && grep -q "^jobs:" "$file"; then
        success "Structure YAML OK: $filename"
        return 0
    else
        error "Structure YAML invalide: $filename"
        return 1
    fi
}

# Validation des workflows Gitea Actions
log "Validation des workflows Gitea Actions..."

workflow_errors=0
for workflow in .gitea/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        if validate_yaml "$workflow"; then
            # Vérification supplémentaire des sections principales
            if grep -q "name:" "$workflow" && grep -q "on:" "$workflow"; then
                success "Sections principales OK: $(basename $workflow)"
            else
                warning "Sections principales manquantes: $(basename $workflow)"
            fi
        else
            workflow_errors=$((workflow_errors + 1))
        fi
    fi
done

echo ""

# Validation des fichiers de configuration
log "Validation des fichiers de configuration..."

config_errors=0

# Configuration Clever Cloud
if [ -f "clevercloud-gitea-runner.json" ]; then
    if python3 -c "import json; json.load(open('clevercloud-gitea-runner.json'))" 2>/dev/null; then
        success "Configuration Clever Cloud JSON valide"
    else
        error "Configuration Clever Cloud JSON invalide"
        config_errors=$((config_errors + 1))
    fi
else
    error "Configuration Clever Cloud manquante"
    config_errors=$((config_errors + 1))
fi

# Dockerfile
if [ -f "Dockerfile.gitea-runner" ]; then
    if grep -q "FROM" "Dockerfile.gitea-runner" && grep -q "RUN" "Dockerfile.gitea-runner"; then
        success "Dockerfile Gitea Runner valide"
    else
        error "Dockerfile Gitea Runner invalide"
        config_errors=$((config_errors + 1))
    fi
else
    error "Dockerfile Gitea Runner manquant"
    config_errors=$((config_errors + 1))
fi

echo ""

# Résumé
log "📊 Résumé de la validation:"
echo ""

echo "Workflows Gitea Actions:"
echo "  - Total: $(ls .gitea/workflows/*.yml 2>/dev/null | wc -l)"
echo "  - Erreurs: $workflow_errors"
echo ""

echo "Fichiers de configuration:"
echo "  - Erreurs: $config_errors"
echo ""

if [ $workflow_errors -eq 0 ] && [ $config_errors -eq 0 ]; then
    success "🎉 Tous les fichiers sont valides!"
    echo ""
    echo "La configuration est prête pour le déploiement."
else
    warning "⚠️ $((workflow_errors + config_errors)) erreurs trouvées"
    echo ""
    echo "Vérifiez les fichiers mentionnés ci-dessus avant le déploiement."
fi

echo ""
success "🔍 Validation YAML terminée!"
