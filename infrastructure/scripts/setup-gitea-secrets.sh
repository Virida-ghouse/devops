#!/bin/bash

# Script pour configurer les secrets Gitea Actions
# Usage: ./setup-gitea-secrets.sh

set -e

# Couleurs pour la sortie
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

# Vérifier si .env.clever-cloud existe
if [ ! -f ".env.clever-cloud" ]; then
    log_error ".env.clever-cloud not found. Please create it from env.clever-cloud.example."
    exit 1
fi

# Charger les variables d'environnement
source .env.clever-cloud

log_info "Configuration des secrets Gitea Actions..."

# Vérifier si clever est installé
if ! command -v clever &> /dev/null; then
    log_error "Clever Tools not found. Please install it first."
    exit 1
fi

# Vérifier si l'utilisateur est connecté à Clever Cloud
if ! clever status &> /dev/null; then
    log_error "Not connected to Clever Cloud. Please run 'clever login' first."
    exit 1
fi

# Créer le fichier de secrets
SECRETS_FILE="gitea-secrets.txt"

log_info "Génération des secrets..."

# Générer les secrets
cat > "$SECRETS_FILE" << EOF
# Secrets Gitea Actions pour VIRIDA
# Généré le $(date)

# Clever Cloud
CLEVER_CLOUD_TOKEN=$(clever token)
CC_APP_DOMAIN=${CC_APP_DOMAIN}
CC_POSTGRESQL_ADDON_HOST=${CC_POSTGRESQL_ADDON_HOST}
CC_POSTGRESQL_ADDON_DB=${CC_POSTGRESQL_ADDON_DB}
CC_POSTGRESQL_ADDON_USER=${CC_POSTGRESQL_ADDON_USER}
CC_POSTGRESQL_ADDON_PASSWORD=${CC_POSTGRESQL_ADDON_PASSWORD}

# Gitea
GITEA_SECRET_KEY=${GITEA_SECRET_KEY}
GITEA_INTERNAL_TOKEN=${GITEA_INTERNAL_TOKEN}
GITEA_RUNNER_TOKEN=${GITEA_RUNNER_TOKEN}

# JWT
JWT_SECRET=${JWT_SECRET}

# Grafana
GRAFANA_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}

# Email
CC_ACME_EMAIL=${CC_ACME_EMAIL}

# Traefik
TRAEFIK_AUTH_USERS_PASSWORD_HASH=${TRAEFIK_AUTH_USERS_PASSWORD_HASH}
EOF

log_success "Secrets générés dans $SECRETS_FILE"

# Afficher les instructions
log_info "Instructions pour configurer les secrets dans Gitea:"
echo ""
echo "1. Connectez-vous à votre instance Gitea"
echo "2. Allez dans Settings > Secrets"
echo "3. Ajoutez chaque secret avec la valeur correspondante:"
echo ""

# Afficher les secrets (sans les valeurs sensibles)
while IFS='=' read -r key value; do
    if [[ ! "$key" =~ ^# ]] && [[ -n "$key" ]]; then
        echo "   $key: [VALUE]"
    fi
done < "$SECRETS_FILE"

echo ""
log_warning "⚠️  IMPORTANT: Ne partagez jamais ce fichier de secrets!"
log_warning "⚠️  Supprimez-le après avoir configuré les secrets dans Gitea."

# Proposer de supprimer le fichier
read -p "Voulez-vous supprimer le fichier de secrets maintenant? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm "$SECRETS_FILE"
    log_success "Fichier de secrets supprimé."
else
    log_warning "Fichier de secrets conservé. N'oubliez pas de le supprimer après configuration."
fi

log_success "Configuration des secrets terminée!"
log_info "Vous pouvez maintenant utiliser les workflows Gitea Actions."
