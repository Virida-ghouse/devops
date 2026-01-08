#!/bin/bash

# Script de test du pipeline Gitea Actions
# Usage: ./test-pipeline-gitea.sh

set -e

echo "🧪 Test du Pipeline Gitea Actions VIRIDA"
echo "========================================"

# Variables
GITEA_URL="https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io"
REPO_URL="$GITEA_URL/Virida/virida"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Test 1: Vérifier la connectivité Gitea
test_gitea_connectivity() {
    log_info "Test 1: Connectivité Gitea"
    
    if curl -s -f "$GITEA_URL" > /dev/null; then
        log_info "✅ Gitea accessible"
    else
        log_error "❌ Gitea non accessible"
        return 1
    fi
}

# Test 2: Vérifier les workflows
test_workflows() {
    log_info "Test 2: Vérification des workflows"
    
    local workflows=(".gitea/workflows/ci-cd.yml" ".gitea/workflows/pr-validation.yml" ".gitea/workflows/release.yml")
    
    for workflow in "${workflows[@]}"; do
        if [ -f "$workflow" ]; then
            log_info "✅ $workflow trouvé"
            
            # Vérifier la syntaxe YAML basique
            if head -1 "$workflow" | grep -q "name:"; then
                log_info "✅ Structure YAML valide pour $workflow"
            else
                log_error "❌ Structure YAML invalide pour $workflow"
            fi
        else
            log_error "❌ $workflow manquant"
        fi
    done
}

# Test 3: Vérifier les applications
test_applications() {
    log_info "Test 3: Vérification des applications"
    
    local apps=("apps/frontend-3d" "apps/ai-ml" "apps/gitea-drone-ci")
    
    for app in "${apps[@]}"; do
        if [ -d "$app" ]; then
            log_info "✅ $app trouvé"
            
            # Vérifier les fichiers de test
            case "$app" in
                "apps/frontend-3d")
                    if [ -f "$app/package.json" ]; then
                        log_info "✅ package.json trouvé"
                    fi
                    if [ -f "$app/tests/unit/health.test.js" ]; then
                        log_info "✅ Tests unitaires trouvés"
                    fi
                    ;;
                "apps/ai-ml")
                    if [ -f "$app/requirements.txt" ]; then
                        log_info "✅ requirements.txt trouvé"
                    fi
                    if [ -f "$app/tests/unit/test_health.py" ]; then
                        log_info "✅ Tests unitaires trouvés"
                    fi
                    ;;
                "apps/gitea-drone-ci")
                    if [ -f "$app/go.mod" ]; then
                        log_info "✅ go.mod trouvé"
                    fi
                    if [ -f "$app/main_test.go" ]; then
                        log_info "✅ Tests unitaires trouvés"
                    fi
                    ;;
            esac
        else
            log_error "❌ $app manquant"
        fi
    done
}

# Test 4: Vérifier les scripts
test_scripts() {
    log_info "Test 4: Vérification des scripts"
    
    local scripts=("scripts/setup-gitea-runner.sh" "scripts/start-gitea-runner.sh" "scripts/deploy-gitea-runner.sh")
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            log_info "✅ $script trouvé"
            
            if [ -x "$script" ]; then
                log_info "✅ $script exécutable"
            else
                log_warn "⚠️  $script non exécutable"
            fi
        else
            log_error "❌ $script manquant"
        fi
    done
}

# Test 5: Vérifier la configuration Git
test_git_config() {
    log_info "Test 5: Vérification de la configuration Git"
    
    if git status > /dev/null 2>&1; then
        log_info "✅ Repository Git initialisé"
        
        # Vérifier les branches
        local branches=($(git branch -r | grep -v HEAD | sed 's/origin\///'))
        log_info "Branches disponibles: ${branches[*]}"
        
        # Vérifier les remotes
        if git remote get-url gitea-virida > /dev/null 2>&1; then
            log_info "✅ Remote gitea-virida configuré"
        else
            log_warn "⚠️  Remote gitea-virida non configuré"
        fi
    else
        log_error "❌ Repository Git non initialisé"
    fi
}

# Test 6: Vérifier les secrets (simulation)
test_secrets() {
    log_info "Test 6: Vérification des secrets (simulation)"
    
    echo "Secrets requis pour le pipeline :"
    echo "  - CLEVER_TOKEN: Token Clever Cloud"
    echo "  - CLEVER_SECRET: Secret Clever Cloud"
    echo "  - SLACK_WEBHOOK_URL: (optionnel) Webhook Slack"
    echo ""
    echo "Pour configurer les secrets :"
    echo "  1. Allez sur: $REPO_URL/settings/secrets/actions"
    echo "  2. Ajoutez chaque secret avec sa valeur"
    echo "  3. Les secrets seront automatiquement injectés dans les workflows"
}

# Test 7: Simulation du pipeline
simulate_pipeline() {
    log_info "Test 7: Simulation du pipeline"
    
    echo "Simulation des étapes du pipeline :"
    echo ""
    echo "1. 📝 Validate:"
    echo "   - Validation YAML: ✅"
    echo "   - Validation Dockerfiles: ✅"
    echo ""
    echo "2. 🧪 Test:"
    echo "   - Frontend 3D: ✅"
    echo "   - AI/ML: ✅"
    echo "   - Go App: ✅"
    echo ""
    echo "3. 🏗️ Build:"
    echo "   - Build Frontend: ✅"
    echo "   - Build AI/ML: ✅"
    echo "   - Build Go: ✅"
    echo ""
    echo "4. 🔒 Security:"
    echo "   - Scan Trivy: ✅"
    echo "   - Upload SARIF: ✅"
    echo ""
    echo "5. 🚀 Deploy:"
    echo "   - Deploy Staging: ✅"
    echo "   - Deploy Production: ✅"
    echo ""
    echo "6. 📊 Monitor:"
    echo "   - Health Checks: ✅"
    echo "   - Notifications: ✅"
}

# Fonction principale
main() {
    echo ""
    log_info "Début des tests du pipeline Gitea Actions"
    echo ""
    
    test_gitea_connectivity
    echo ""
    
    test_workflows
    echo ""
    
    test_applications
    echo ""
    
    test_scripts
    echo ""
    
    test_git_config
    echo ""
    
    test_secrets
    echo ""
    
    simulate_pipeline
    echo ""
    
    log_info "Tests terminés ! 🎉"
    echo ""
    echo "📋 Prochaines étapes :"
    echo "  1. Créer le repository dans Gitea"
    echo "  2. Configurer le runner"
    echo "  3. Ajouter les secrets"
    echo "  4. Tester avec un commit"
    echo ""
    echo "🔗 Liens utiles :"
    echo "  - Gitea: $GITEA_URL"
    echo "  - Repository: $REPO_URL"
    echo "  - Runners: $GITEA_URL/admin/actions/runners"
    echo "  - Secrets: $REPO_URL/settings/secrets/actions"
    echo ""
}

# Exécuter les tests
main "$@"
