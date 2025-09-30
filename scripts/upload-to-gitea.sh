#!/bin/bash

# Script d'upload vers Gitea VIRIDA
# Usage: ./upload-to-gitea.sh

set -e

# Variables
GITEA_URL="https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io"
REPO_URL="$GITEA_URL/crk_test/virida"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

echo "🚀 Upload VIRIDA vers Gitea"
echo "==========================="

echo ""
log_info "Méthodes d'upload disponibles :"
echo ""

echo "1. 📤 Upload Manuel (Recommandé)"
echo "   - Allez sur: $REPO_URL"
echo "   - Cliquez sur 'Upload Files'"
echo "   - Glissez-déposez tous les fichiers"
echo "   - Commitez: 'Initial commit: VIRIDA CI/CD'"
echo ""

echo "2. 🔑 Upload Git (avec token)"
echo "   git config --global credential.helper store"
echo "   git push gitea-virida-test staging:main"
echo ""

echo "3. 📦 Upload via Archive"
echo "   - Utilisez le fichier: virida-ci-cd.tar.gz"
echo "   - Décompressez dans Gitea"
echo ""

log_info "Fichiers critiques à uploader :"
echo "  ✅ .gitea/workflows/ (3 workflows)"
echo "  ✅ apps/ (3 applications)"
echo "  ✅ scripts/ (15+ scripts)"
echo "  ✅ Dockerfile.gitea-runner"
echo "  ✅ *.md (documentation)"
echo ""

log_info "Prochaines étapes après upload :"
echo "  1. Configurer le runner Gitea"
echo "  2. Ajouter les secrets"
echo "  3. Tester le pipeline"
echo ""

echo "🔗 Liens :"
echo "  Repository: $REPO_URL"
echo "  Actions: $REPO_URL/actions"
echo "  Settings: $REPO_URL/settings"
echo ""
