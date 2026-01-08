#!/bin/bash

# Script de déploiement manuel SonarQube sur Clever Cloud
# Usage: ./deploy-sonarqube-manual.sh

set -e

echo "🚀 Déploiement Manuel SonarQube sur Clever Cloud"
echo "================================================"

# Variables
ORG_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"
APP_NAME="virida-sonarqube"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
log_info "Instructions de déploiement manuel SonarQube"
echo ""

echo "🔧 Étapes à suivre :"
echo ""
echo "1. 🌐 Accédez à la console Clever Cloud :"
echo "   https://console.clever-cloud.com/organisations/$ORG_ID"
echo ""

echo "2. 📦 Créez une nouvelle application :"
echo "   - Cliquez sur 'Create an application'"
echo "   - Type: Docker"
echo "   - Nom: $APP_NAME"
echo "   - Région: Paris"
echo ""

echo "3. 🐳 Configurez le Dockerfile :"
echo "   - Allez dans 'Settings' > 'Build'"
echo "   - Dockerfile path: Dockerfile.sonarqube"
echo "   - Port: 9000"
echo ""

echo "4. 🗄️ Ajoutez l'addon PostgreSQL :"
echo "   - Allez dans 'Add-ons'"
echo "   - Ajoutez 'PostgreSQL' (plan dev)"
echo ""

echo "5. ⚙️ Configurez les variables d'environnement :"
echo "   - SONAR_WEB_PORT=9000"
echo "   - SONAR_WEB_CONTEXT=/"
echo "   - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true"
echo ""

echo "6. 🚀 Déployez l'application :"
echo "   - Cliquez sur 'Deploy'"
echo "   - Attendez que l'application soit prête"
echo ""

echo "7. 🔗 Récupérez l'URL de l'application :"
echo "   - Notez l'URL générée (ex: https://$APP_NAME.cleverapps.io)"
echo ""

log_info "Fichiers nécessaires dans le repository :"
echo "  ✅ Dockerfile.sonarqube"
echo "  ✅ clever-entrypoint.sh"
echo "  ✅ .clever.json"
echo ""

log_info "Prochaines étapes après déploiement :"
echo "  1. Configurer les secrets dans Gitea :"
echo "     - SONAR_TOKEN (généré dans SonarQube)"
echo "     - SONAR_HOST_URL (URL de votre instance)"
echo "  2. Tester le pipeline CI/CD"
echo ""

echo "🔗 Liens utiles :"
echo "  - Console Clever Cloud: https://console.clever-cloud.com/organisations/$ORG_ID"
echo "  - Documentation SonarQube: https://docs.sonarqube.org/"
echo "  - Gitea Actions: https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/actions"
echo ""
