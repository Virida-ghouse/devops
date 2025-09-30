#!/bin/bash

# 🔑 Aide pour les Credentials Clever Cloud
# Script d'aide pour trouver et configurer les credentials

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Fonctions
log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✅ $1${NC}"; }
warning() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠️ $1${NC}"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] ❌ $1${NC}"; }

echo -e "${CYAN}🔑 AIDE POUR LES CREDENTIALS CLEVER CLOUD${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""

# Vérification de la connexion internet
log "🔍 Vérification de la connexion internet..."
if curl -s --connect-timeout 5 https://console.clever-cloud.com > /dev/null; then
    success "Connexion à Clever Cloud OK"
else
    error "Impossible de se connecter à Clever Cloud"
    echo "Vérifiez votre connexion internet"
    exit 1
fi

echo ""
log "📋 ÉTAPES POUR OBTENIR VOS CREDENTIALS :"
echo ""

echo "1️⃣ OUVREZ VOTRE NAVIGATEUR"
echo "   👉 https://console.clever-cloud.com"
echo ""

echo "2️⃣ CONNECTEZ-VOUS"
echo "   👉 Utilisez votre email et mot de passe Clever Cloud"
echo ""

echo "3️⃣ ACCÉDEZ AUX API KEYS"
echo "   👉 Cliquez sur votre profil (en haut à droite)"
echo "   👉 Sélectionnez 'API Keys' dans le menu"
echo ""

echo "4️⃣ CRÉEZ UNE NOUVELLE CLÉ"
echo "   👉 Cliquez sur 'Create API Key'"
echo "   👉 Donnez un nom (ex: 'VIRIDA-DevOps')"
echo "   👉 Sélectionnez les permissions nécessaires :"
echo "      - Read/Write access to applications"
echo "      - Read/Write access to addons"
echo "      - Read/Write access to organizations"
echo ""

echo "5️⃣ COPIEZ VOS CREDENTIALS"
echo "   👉 Copiez le TOKEN (commence par 'cc_')"
echo "   👉 Copiez le SECRET (longue chaîne de caractères)"
echo "   ⚠️  IMPORTANT : Gardez-les précieusement !"
echo ""

echo "6️⃣ CONFIGUREZ VOS VARIABLES"
echo "   👉 Ouvrez un terminal"
echo "   👉 Exécutez les commandes suivantes :"
echo ""

echo -e "${YELLOW}export CLEVER_TOKEN=\"votre_token_ici\"${NC}"
echo -e "${YELLOW}export CLEVER_SECRET=\"votre_secret_ici\"${NC}"
echo ""

echo "7️⃣ TESTEZ VOS CREDENTIALS"
echo "   👉 Exécutez : clever login --token \$CLEVER_TOKEN --secret \$CLEVER_SECRET"
echo "   👉 Vérifiez : clever status"
echo ""

# Vérification des credentials actuels
log "🔍 Vérification des credentials actuels..."
if [ -n "$CLEVER_TOKEN" ] && [ -n "$CLEVER_SECRET" ]; then
    success "Credentials déjà configurés !"
    echo "  - Token: ${CLEVER_TOKEN:0:10}..."
    echo "  - Secret: ${CLEVER_SECRET:0:10}..."
    echo ""
    echo "Voulez-vous tester la connexion ? (y/n)"
    read -r response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        log "🧪 Test de connexion..."
        if clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET" &> /dev/null; then
            success "Connexion Clever Cloud réussie !"
            clever status
        else
            error "Échec de la connexion. Vérifiez vos credentials."
        fi
    fi
else
    warning "Aucun credential configuré"
    echo ""
    echo "📝 RÉCAPITULATIF :"
    echo "   - Allez sur https://console.clever-cloud.com"
    echo "   - Créez une API Key"
    echo "   - Configurez les variables d'environnement"
    echo "   - Testez avec : ./scripts/test-gitlab-config.sh"
fi

echo ""
echo -e "${CYAN}📞 BESOIN D'AIDE ?${NC}"
echo "   - Documentation : https://www.clever-cloud.com/doc/"
echo "   - Support : https://www.clever-cloud.com/support/"
echo "   - Projet VIRIDA : https://gitlab.com/virida/virida"
echo ""
success "🚀 Une fois configuré, lancez : ./scripts/deploy-with-gitlab-token.sh"



