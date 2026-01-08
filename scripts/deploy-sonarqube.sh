#!/bin/bash

# Script de déploiement SonarQube sur Clever Cloud
# Usage: ./deploy-sonarqube.sh

set -e

echo "🚀 Déploiement SonarQube sur Clever Cloud"
echo "=========================================="

# Variables
APP_NAME="virida-sonarqube"
CLEVER_JSON="clevercloud-sonarqube.json"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Vérifier que Clever Tools est installé
if ! command -v clever &> /dev/null; then
    log_error "Clever Tools n'est pas installé"
    echo "Installez-le avec: curl -fsSL https://clever-tools.clever-cloud.com/releases/2.7.0/clever-tools-linux.tar.gz | tar -xz"
    exit 1
fi

# Vérifier la connexion Clever Cloud
log_info "Vérification de la connexion Clever Cloud..."
if ! clever status &> /dev/null; then
    log_warn "Non connecté à Clever Cloud. Connexion requise..."
    clever login
fi

# Créer l'application si elle n'existe pas
log_info "Création de l'application SonarQube..."
if ! clever apps | grep -q "$APP_NAME"; then
    clever create --type docker "$APP_NAME" --region par
    log_info "Application $APP_NAME créée"
else
    log_info "Application $APP_NAME existe déjà"
fi

# Lier l'application
log_info "Liaison de l'application..."
clever link --alias "$APP_NAME"

# Déployer la configuration
log_info "Déploiement de la configuration..."
clever env import "$CLEVER_JSON"

# Créer l'addon PostgreSQL
log_info "Création de l'addon PostgreSQL..."
if ! clever addons | grep -q "postgresql-addon"; then
    clever addon create postgresql-addon --plan dev
    log_info "Addon PostgreSQL créé"
else
    log_info "Addon PostgreSQL existe déjà"
fi

# Déployer l'application
log_info "Déploiement de SonarQube..."
clever deploy

# Attendre que l'application soit prête
log_info "Attente du démarrage de SonarQube..."
sleep 60

# Vérifier le statut
log_info "Vérification du statut..."
clever status

# Afficher l'URL
APP_URL=$(clever domain | head -1)
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
