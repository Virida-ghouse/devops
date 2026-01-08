#!/bin/bash

# Script pour tester les workflows en local avant de push
# Usage: ./scripts/test-local.sh

set -e

echo "Test Local des Workflows VIRIDA"
echo "================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Vérifier qu'on est dans le bon répertoire
if [ ! -d ".gitea/workflows" ]; then
    log_error "Tu n'es pas dans le repertoire VIRIDA"
    exit 1
fi

echo "1. Validation des fichiers YAML..."
echo "-----------------------------------"
ERROR_COUNT=0
for file in .gitea/workflows/*.yml; do
    if [ -f "$file" ]; then
        echo "Validating $file"
        if head -5 "$file" | grep -q "name:"; then
            echo "  [OK] $file is valid"
        else
            echo "  [ERROR] Invalid workflow: $file (missing 'name:' field)"
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    fi
done

if [ $ERROR_COUNT -gt 0 ]; then
    log_error "Found $ERROR_COUNT invalid workflow file(s)"
    exit 1
fi
echo "[OK] All workflow YAML files are valid"
echo ""

# Test 2: Validation JSON
echo "2. Validation des fichiers JSON..."
echo "-----------------------------------"
for file in *.json; do
    if [ -f "$file" ]; then
        echo "Validating $file"
        if python3 -m json.tool "$file" > /dev/null 2>&1; then
            echo "  [OK] $file is valid"
        else
            log_error "Invalid JSON: $file"
            exit 1
        fi
    fi
done
echo "[OK] All JSON files are valid"
echo ""

# Test 3: Vérifier les scripts shell
echo "3. Validation des scripts shell..."
echo "-----------------------------------"
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        echo "Checking $script"
        if bash -n "$script" 2>&1; then
            echo "  [OK] $script syntax is valid"
        else
            log_error "Invalid shell script: $script"
            exit 1
        fi
    fi
done
echo "[OK] All shell scripts are valid"
echo ""

# Test 4: Vérifier que les workflows n'ont pas d'emojis
echo "4. Verification des emojis dans les workflows..."
echo "------------------------------------------------"
EMOJI_COUNT=0
for file in .gitea/workflows/*.yml; do
    if [ -f "$file" ]; then
        EMOJIS=$(grep -o "🔧\|✅\|❌\|⚠️\|🎉\|📥\|🔍\|📦\|🧪\|🏗️\|🔒\|📊\|🚀\|📅\|🌿\|📝\|📋\|ℹ️\|📁\|📂" "$file" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$EMOJIS" -gt 0 ]; then
            log_warn "Found $EMOJIS emoji(s) in $file"
            EMOJI_COUNT=$((EMOJI_COUNT + EMOJIS))
        fi
    fi
done

if [ $EMOJI_COUNT -gt 0 ]; then
    log_warn "Found $EMOJI_COUNT emoji(s) total in workflows"
    echo "  Consider removing emojis from workflow files"
else
    echo "[OK] No emojis found in workflows"
fi
echo ""

# Test 5: Vérifier les dépendances Node.js
echo "5. Verification des projets Node.js..."
echo "--------------------------------------"
if [ -d "virida_app" ]; then
    echo "Checking virida_app..."
    if [ -f "virida_app/package.json" ]; then
        echo "  [OK] virida_app/package.json exists"
        cd virida_app
        if npm list --depth=0 > /dev/null 2>&1; then
            echo "  [OK] virida_app dependencies are valid"
        else
            log_warn "virida_app dependencies may have issues (run 'npm install')"
        fi
        cd ..
    else
        log_warn "virida_app/package.json not found"
    fi
fi

if [ -d "virida_api" ]; then
    echo "Checking virida_api..."
    if [ -f "virida_api/package.json" ]; then
        echo "  [OK] virida_api/package.json exists"
        cd virida_api
        if npm list --depth=0 > /dev/null 2>&1; then
            echo "  [OK] virida_api dependencies are valid"
        else
            log_warn "virida_api dependencies may have issues (run 'npm install')"
        fi
        cd ..
    else
        log_warn "virida_api/package.json not found"
    fi
fi
echo ""

# Test 6: Vérifier Git
echo "6. Verification Git..."
echo "----------------------"
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "  [OK] Git repository detected"
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "  Current branch: $CURRENT_BRANCH"
    
    if [ -n "$(git status --porcelain)" ]; then
        log_warn "Uncommitted changes detected"
        echo "  Run 'git status' to see changes"
    else
        echo "  [OK] No uncommitted changes"
    fi
else
    log_error "Not a Git repository"
    exit 1
fi
echo ""

# Test 7: Vérifier le runner (si disponible)
echo "7. Verification du runner..."
echo "-----------------------------"
if command -v act_runner &> /dev/null; then
    echo "  [OK] act_runner is installed"
    if [ -f ".runner" ]; then
        echo "  [OK] Runner configuration found"
        RUNNER_NAME=$(cat .runner 2>/dev/null | grep -o '"name": "[^"]*"' | cut -d'"' -f4 || echo "unknown")
        echo "  Runner name: $RUNNER_NAME"
    else
        log_warn "Runner not configured (.runner file not found)"
    fi
else
    log_warn "act_runner not installed (optional for local testing)"
fi
echo ""

# Résumé
echo "================================"
echo "Resume des tests locaux"
echo "================================"
echo "[OK] Tous les tests de base sont passes"
echo ""
echo "Prochaines etapes :"
echo "  1. Si tout est OK, tu peux commit et push"
echo "  2. Verifie les workflows dans Gitea apres le push"
echo "  3. Surveille les logs du runner : tail -f /tmp/act_runner.log"
echo ""


