#!/bin/bash

# Script de configuration complète Gitea Actions
# Usage: ./configure-gitea-complete.sh

set -e

echo "Configuration Complete Gitea Actions VIRIDA"
echo "=============================================="

# Variables
GITEA_URL="https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io"
REPO_URL="$GITEA_URL/crk_test/virida"
RUNNER_NAME="virida-runner-$(hostname)"
RUNNER_LABELS="ubuntu-latest:docker://node:18,python:docker://python:3.11,golang:docker://golang:1.21"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

echo ""
log_info "Configuration complète de Gitea Actions pour VIRIDA"
echo ""

echo "Etapes de configuration :"
echo ""

echo "1. Verifier que le code est uploade :"
echo "   - Allez sur: $REPO_URL"
echo "   - Vérifiez que les fichiers .gitea/workflows/ sont présents"
echo "   - Vérifiez que les applications apps/ sont présentes"
echo ""

echo "2. 🔑 Configurer le Runner Gitea :"
echo "   a) Obtenir le token d'enregistrement :"
echo "      - Allez sur: $GITEA_URL/admin/actions/runners"
echo "      - Cliquez sur 'Create new Runner'"
echo "      - Copiez le token d'enregistrement"
echo ""
echo "   b) Installer act_runner :"
echo "      wget https://gitea.com/gitea/act_runner/releases/download/v0.3.0/act_runner-0.3.0-linux-amd64.tar.gz"
echo "      tar -xzf act_runner-0.3.0-linux-amd64.tar.gz"
echo "      sudo mv act_runner /usr/local/bin/"
echo ""
echo "   c) Enregistrer le runner :"
echo "      act_runner register \\"
echo "        --instance $GITEA_URL \\"
echo "        --token VOTRE_TOKEN_ICI \\"
echo "        --name $RUNNER_NAME \\"
echo "        --labels \"$RUNNER_LABELS\" \\"
echo "        --no-interactive"
echo ""
echo "   d) Démarrer le runner :"
echo "      act_runner daemon"
echo ""

echo "3. 🔐 Configurer les Secrets :"
echo "   - Allez sur: $REPO_URL/settings/secrets/actions"
echo "   - Ajoutez ces secrets :"
echo "     - CLEVER_TOKEN: Votre token Clever Cloud"
echo "     - CLEVER_SECRET: Votre secret Clever Cloud"
echo "     - SLACK_WEBHOOK_URL: (optionnel) Webhook Slack"
echo ""

echo "4. Tester le Pipeline :"
echo "   a) Faire un commit de test :"
echo "      echo '# Test pipeline' >> README.md"
echo "      git add README.md"
echo "      git commit -m 'test: Test pipeline Gitea Actions'"
echo "      git push gitea-virida-test staging:main"
echo ""
echo "   b) Vérifier l'exécution :"
echo "      - Allez sur: $REPO_URL/actions"
echo "      - Vérifiez que le workflow se déclenche"
echo "      - Consultez les logs d'exécution"
echo ""

echo "5. Verifier les Deploiements :"
echo "   - Vérifiez que les applications Clever Cloud sont déployées"
echo "   - Testez les endpoints de santé"
echo "   - Consultez les logs de déploiement"
echo ""

log_info "Configuration terminée ! 🎉"
echo ""

echo "🔗 Liens utiles :"
echo "  - Repository: $REPO_URL"
echo "  - Actions: $REPO_URL/actions"
echo "  - Settings: $REPO_URL/settings"
echo "  - Secrets: $REPO_URL/settings/secrets/actions"
echo "  - Runners: $GITEA_URL/admin/actions/runners"
echo ""

echo "📚 Documentation :"
echo "  - Guide complet: GUIDE-DEPLOIEMENT-FINAL.md"
echo "  - Analyse comparative: ANALYSE-COMPARATIVE-CI-CD-VIRIDA.md"
echo "  - Résumé exécutif: RESUME-EXECUTIF-CI-CD-VIRIDA.md"
echo ""

echo "🆘 Support :"
echo "  - Test pipeline: ./scripts/test-pipeline-gitea.sh"
echo "  - Configuration manuelle: ./scripts/configure-gitea-runner-manual.sh"
echo "  - Upload code: ./scripts/upload-to-gitea.sh"
echo ""
