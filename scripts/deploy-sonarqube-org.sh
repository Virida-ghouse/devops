#!/bin/bash

# Script de déploiement SonarQube sur l'organisation VIRIDA
# Usage: ./deploy-sonarqube-org.sh

set -e

echo "🚀 Déploiement SonarQube sur l'Organisation VIRIDA"
echo "================================================="

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
log_info "Déploiement SonarQube sur l'organisation VIRIDA"
echo ""

# Vérifier la connexion
log_info "Vérification de la connexion Clever Cloud..."
if ! clever status &> /dev/null; then
    log_warn "Connexion requise..."
    clever login
fi

# Créer l'application sur l'organisation VIRIDA
log_info "Création de l'application SonarQube sur l'organisation VIRIDA..."
clever create --type docker "$APP_NAME" --region par --org "$ORG_ID"

# Lier l'application
log_info "Liaison de l'application..."
clever link --alias "$APP_NAME"

# Créer l'addon PostgreSQL
log_info "Création de l'addon PostgreSQL..."
clever addon create postgresql-addon postgresql-addon --plan dev --link "$APP_NAME"

# Configurer les variables d'environnement
log_info "Configuration des variables d'environnement..."
clever env set SONAR_WEB_PORT 9000 --alias "$APP_NAME"
clever env set SONAR_WEB_CONTEXT / --alias "$APP_NAME"
clever env set SONAR_ES_BOOTSTRAP_CHECKS_DISABLE true --alias "$APP_NAME"

# Déployer l'application
log_info "Déploiement de SonarQube..."
clever deploy --alias "$APP_NAME"

# Attendre que l'application soit prête
log_info "Attente du démarrage de SonarQube..."
sleep 60

# Vérifier le statut
log_info "Vérification du statut..."
clever status --alias "$APP_NAME"

# Afficher l'URL
APP_URL=$(clever domain --alias "$APP_NAME" | head -1)
log_info "SonarQube déployé avec succès !"
echo ""
echo "🌐 URL: https://$APP_URL"
echo "📊 Admin: admin/admin (première connexion)"
echo "🔧 Configuration: Variables d'environnement configurées automatiquement"
echo ""

log_info "Prochaines étapes:"
echo "1. Accédez à https://$APP_URL"
echo "2. Connectez-vous avec admin/admin"
echo "3. Changez le mot de passe admin"
echo "4. Configurez un token pour l'intégration CI/CD"
echo "5. Ajoutez les secrets SONAR_TOKEN et SONAR_HOST_URL dans Gitea"
echo ""

log_info "Organisation VIRIDA: https://console.clever-cloud.com/organisations/$ORG_ID"
