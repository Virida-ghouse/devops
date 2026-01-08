#!/bin/bash

# Script de configuration manuelle du Gitea Runner
# Usage: ./configure-gitea-runner-manual.sh

set -e

echo "🚀 Configuration Manuelle du Gitea Runner VIRIDA"
echo "==============================================="

# Variables
GITEA_URL="https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io"
RUNNER_NAME="virida-runner-$(hostname)"
RUNNER_LABELS="ubuntu-latest:docker://node:18,ubuntu-latest:docker://python:3.11,ubuntu-latest:docker://golang:1.21"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

echo ""
log_info "Configuration du Gitea Runner pour VIRIDA"
echo ""

echo "📋 Informations de configuration :"
echo "  Gitea URL: $GITEA_URL"
echo "  Runner Name: $RUNNER_NAME"
echo "  Labels: $RUNNER_LABELS"
echo ""

echo "🔧 Étapes de configuration :"
echo ""
echo "1. 📝 Créer le repository dans Gitea :"
echo "   - Allez sur: $GITEA_URL/Virida"
echo "   - Cliquez sur 'New Repository'"
echo "   - Nom: virida"
echo "   - Description: Plateforme IoT/IA avec infrastructure DevOps"
echo "   - Créez le repository"
echo ""

echo "2. 🔑 Obtenir le token d'enregistrement :"
echo "   - Allez sur: $GITEA_URL/admin/actions/runners"
echo "   - Cliquez sur 'Create new Runner'"
echo "   - Copiez le token d'enregistrement"
echo ""

echo "3. 🚀 Enregistrer le runner :"
echo "   - Exécutez cette commande avec votre token :"
echo ""
echo "   act_runner register \\"
echo "     --instance $GITEA_URL \\"
echo "     --token VOTRE_TOKEN_ICI \\"
echo "     --name $RUNNER_NAME \\"
echo "     --labels \"$RUNNER_LABELS\" \\"
echo "     --no-interactive"
echo ""

echo "4. ▶️  Démarrer le runner :"
echo "   - Exécutez cette commande :"
echo ""
echo "   act_runner daemon"
echo ""

echo "5. 🔐 Configurer les secrets dans Gitea :"
echo "   - Allez sur: $GITEA_URL/Virida/virida/settings/secrets/actions"
echo "   - Ajoutez ces secrets :"
echo "     - CLEVER_TOKEN: Votre token Clever Cloud"
echo "     - CLEVER_SECRET: Votre secret Clever Cloud"
echo "     - SLACK_WEBHOOK_URL: (optionnel) Pour les notifications"
echo ""

echo "6. 🧪 Tester le pipeline :"
echo "   - Faites un commit sur la branche staging"
echo "   - Vérifiez que le pipeline se déclenche"
echo "   - Consultez les logs dans Gitea Actions"
echo ""

log_info "Configuration terminée ! 🎉"
echo ""
echo "📚 Documentation :"
echo "  - Workflows: .gitea/workflows/"
echo "  - Scripts: scripts/"
echo "  - Analyse: ANALYSE-COMPARATIVE-CI-CD-VIRIDA.md"
echo ""
echo "🆘 Support :"
echo "  - Logs runner: journalctl -u gitea-runner -f"
echo "  - Status runner: systemctl status gitea-runner"
echo "  - Restart runner: systemctl restart gitea-runner"
echo ""
