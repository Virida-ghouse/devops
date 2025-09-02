#!/bin/bash

# 🚀 VIRIDA Environment Setup Script
# Script pour configurer les variables d'environnement à partir de Clever Cloud

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérification de l'existence du fichier .env.clever-cloud
if [ ! -f "../../.env.clever-cloud" ]; then
    log_error "Fichier .env.clever-cloud non trouvé dans le répertoire racine"
    log_info "Veuillez créer ce fichier avec vos variables Clever Cloud"
    exit 1
fi

log_info "Configuration des variables d'environnement à partir de .env.clever-cloud"

# Chargement des variables Clever Cloud
source ../../.env.clever-cloud

# Vérification des variables requises
required_vars=("CC_POSTGRESQL_ADDON_HOST" "CC_POSTGRESQL_ADDON_DB" "CC_POSTGRESQL_ADDON_USER" "CC_POSTGRESQL_ADDON_PASSWORD")

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log_error "Variable $var manquante dans .env.clever-cloud"
        exit 1
    fi
done

log_success "Variables Clever Cloud chargées avec succès"

# Création des fichiers d'environnement
environments=("dev" "staging" "prod")

for env in "${environments[@]}"; do
    log_info "Configuration de l'environnement $env"
    
    # Copie du fichier d'exemple
    cp "env.${env}.example" ".env.${env}"
    
    # Remplacement des variables
    sed -i.bak "s/your-postgres-host.clever-cloud.com/${CC_POSTGRESQL_ADDON_HOST}/g" ".env.${env}"
    sed -i.bak "s/your-database-name/${CC_POSTGRESQL_ADDON_DB}/g" ".env.${env}"
    sed -i.bak "s/your-database-user/${CC_POSTGRESQL_ADDON_USER}/g" ".env.${env}"
    sed -i.bak "s/your-database-password/${CC_POSTGRESQL_ADDON_PASSWORD}/g" ".env.${env}"
    
    # Suppression des fichiers de sauvegarde
    rm -f ".env.${env}.bak"
    
    log_success "Fichier .env.${env} configuré"
done

log_success "Configuration des environnements terminée"
log_info "Vous pouvez maintenant utiliser: make dev, make staging, make prod"
