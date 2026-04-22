#!/bin/bash

# Script de déploiement manuel SonarQube sur l'Organisation VIRIDA
# Usage: ./deploy-sonarqube-virida-org.sh

set -e

echo "🚀 Déploiement Manuel SonarQube - Organisation VIRIDA"
echo "====================================================="

# Variables
ORG_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"
APP_NAME="virida-sonarqube"
CONSOLE_URL="https://console.clever-cloud.com/organisations/$ORG_ID"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[ÉTAPE]${NC} $1"; }

echo ""
log_info "Déploiement SonarQube sur l'Organisation VIRIDA"
echo ""

echo "🎯 Cible: Organisation VIRIDA"
echo "   ID: $ORG_ID"
echo "   Console: $CONSOLE_URL"
echo ""

log_step "1. 🌐 Accédez à la console Clever Cloud"
echo "   Ouvrez: $CONSOLE_URL"
echo "   (Si la page ne se charge pas, rafraîchissez ou contactez le support)"
echo ""

log_step "2. 📦 Créez une nouvelle application"
echo "   - Cliquez sur 'Create an application' ou '+'"
echo "   - Type: Docker"
echo "   - Nom: $APP_NAME"
echo "   - Région: Paris (par)"
echo "   - Organisation: VIRIDA (sélectionnée automatiquement)"
echo ""

log_step "3. 🐳 Configurez le Dockerfile"
echo "   - Allez dans 'Settings' > 'Build'"
echo "   - Dockerfile path: Dockerfile.sonarqube"
echo "   - Port: 9000"
echo "   - Health check path: /api/system/status"
echo ""

log_step "4. 🗄️ Ajoutez l'addon PostgreSQL"
echo "   - Allez dans l'onglet 'Add-ons'"
echo "   - Cliquez sur 'Add an add-on'"
echo "   - Sélectionnez 'PostgreSQL'"
echo "   - Plan: dev (gratuit)"
echo "   - Confirmez l'ajout"
echo ""

log_step "5. ⚙️ Configurez les variables d'environnement"
echo "   - Allez dans 'Settings' > 'Environment variables'"
echo "   - Ajoutez les variables suivantes :"
echo "     • SONAR_WEB_PORT = 9000"
echo "     • SONAR_WEB_CONTEXT = /"
echo "     • SONAR_ES_BOOTSTRAP_CHECKS_DISABLE = true"
echo ""

log_step "6. 🚀 Déployez l'application"
echo "   - Allez dans l'onglet 'Deploy'"
echo "   - Cliquez sur 'Deploy'"
echo "   - Attendez que l'application soit prête (2-3 minutes)"
echo "   - Vérifiez les logs de déploiement"
echo ""

log_step "7. 🔗 Récupérez l'URL de l'application"
echo "   - Une fois déployée, notez l'URL générée"
echo "   - Format: https://$APP_NAME.cleverapps.io"
echo "   - Testez l'accès à l'URL"
echo ""

log_info "📋 Fichiers nécessaires dans le repository :"
echo "  ✅ Dockerfile.sonarqube"
echo "  ✅ clever-entrypoint.sh"
echo "  ✅ .clever.json"
echo ""

log_info "🔧 Configuration SonarQube après déploiement :"
echo "  1. Accédez à l'URL de votre application"
echo "  2. Première connexion : admin/admin"
echo "  3. Changez le mot de passe admin"
echo "  4. Allez dans Administration > Security > Users"
echo "  5. Générez un token pour l'intégration CI/CD"
echo ""

log_info "🔐 Configuration des secrets dans Gitea :"
echo "  1. Allez sur: https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/settings/secrets"
echo "  2. Ajoutez les secrets suivants :"
echo "     • SONAR_TOKEN = [token généré dans SonarQube]"
echo "     • SONAR_HOST_URL = [URL de votre instance SonarQube]"
echo "     • CLEVER_TOKEN = [token Clever Cloud]"
echo "     • CLEVER_SECRET = [secret Clever Cloud]"
echo "  3. Si des valeurs sensibles ont déjà été exposées, faites une rotation immédiate."
echo ""

log_info "🧪 Test du pipeline CI/CD :"
echo "  1. Faites un commit sur la branche devops_crk"
echo "  2. Le pipeline se déclenchera automatiquement"
echo "  3. Vérifiez les logs dans Gitea Actions"
echo ""

echo "🔗 Liens utiles :"
echo "  - Console VIRIDA: $CONSOLE_URL"
echo "  - Gitea Actions: https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/actions"
echo "  - Documentation SonarQube: https://docs.sonarqube.org/"
echo ""

log_warn "⚠️  Note: Si la console ne se charge pas, contactez le support Clever Cloud"
echo "   Email: support@clever-cloud.com"
echo ""
