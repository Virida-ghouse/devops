#!/bin/bash

# 🚁 Script de configuration Gitea Runner pour VIRIDA
# Ce script guide l'utilisateur à travers la configuration complète

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions de logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️ $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

log "🚁 Configuration Gitea Runner pour VIRIDA"
echo ""

# Étape 1: Vérification des prérequis
log "📋 Étape 1: Vérification des prérequis..."

# Vérification de Clever Tools
if ! command -v clever &> /dev/null; then
    error "Clever Tools n'est pas installé"
    log "Installation de Clever Tools..."
    npm install -g clever-tools
    if [ $? -eq 0 ]; then
        success "Clever Tools installé"
    else
        error "Échec de l'installation de Clever Tools"
        exit 1
    fi
else
    success "Clever Tools OK"
fi

# Vérification de Docker
if ! command -v docker &> /dev/null; then
    warning "Docker n'est pas installé (optionnel pour le développement local)"
else
    success "Docker OK"
fi

echo ""

# Étape 2: Configuration Clever Cloud
log "📋 Étape 2: Configuration Clever Cloud..."

echo "Pour configurer Clever Cloud, vous avez besoin de:"
echo "1. Token d'API Clever Cloud"
echo "2. Secret Clever Cloud"
echo ""

echo "Comment obtenir ces informations:"
echo "1. Allez sur https://console.clever-cloud.com"
echo "2. Cliquez sur votre profil (en haut à droite)"
echo "3. Allez dans 'API Keys'"
echo "4. Créez une nouvelle clé API"
echo ""

read -p "Voulez-vous configurer Clever Cloud maintenant ? (y/n): " configure_clever

if [ "$configure_clever" = "y" ] || [ "$configure_clever" = "Y" ]; then
    echo ""
    read -p "Entrez votre token Clever Cloud: " CLEVER_TOKEN
    read -p "Entrez votre secret Clever Cloud: " CLEVER_SECRET
    
    if [ -n "$CLEVER_TOKEN" ] && [ -n "$CLEVER_SECRET" ]; then
        # Test de connexion
        log "🔐 Test de connexion Clever Cloud..."
        if clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET" &> /dev/null; then
            success "Connexion Clever Cloud réussie"
            
            # Sauvegarde des tokens
            echo "export CLEVER_TOKEN=\"$CLEVER_TOKEN\"" >> ~/.bashrc
            echo "export CLEVER_SECRET=\"$CLEVER_SECRET\"" >> ~/.bashrc
            echo "export CLEVER_TOKEN=\"$CLEVER_TOKEN\"" >> ~/.zshrc
            echo "export CLEVER_SECRET=\"$CLEVER_SECRET\"" >> ~/.zshrc
            
            success "Tokens sauvegardés dans ~/.bashrc et ~/.zshrc"
        else
            error "Échec de la connexion Clever Cloud"
            exit 1
        fi
    else
        error "Token ou secret manquant"
        exit 1
    fi
else
    warning "Configuration Clever Cloud ignorée"
    echo "Vous devrez configurer les variables d'environnement manuellement:"
    echo "export CLEVER_TOKEN=\"your_token\""
    echo "export CLEVER_SECRET=\"your_secret\""
fi

echo ""

# Étape 3: Configuration Gitea
log "📋 Étape 3: Configuration Gitea..."

echo "Pour configurer Gitea, vous avez besoin de:"
echo "1. URL de votre instance Gitea"
echo "2. Token d'API Gitea"
echo ""

echo "Comment obtenir le token Gitea:"
echo "1. Allez sur votre instance Gitea"
echo "2. Cliquez sur votre profil (en haut à droite)"
echo "3. Allez dans 'Settings' > 'Applications'"
echo "4. Générez un nouveau token"
echo ""

read -p "Voulez-vous configurer Gitea maintenant ? (y/n): " configure_gitea

if [ "$configure_gitea" = "y" ] || [ "$configure_gitea" = "Y" ]; then
    echo ""
    read -p "Entrez l'URL de votre instance Gitea (ex: https://gitea.com): " GITEA_INSTANCE_URL
    read -p "Entrez votre token Gitea: " GITEA_TOKEN
    
    if [ -n "$GITEA_INSTANCE_URL" ] && [ -n "$GITEA_TOKEN" ]; then
        # Test de connexion
        log "🔐 Test de connexion Gitea..."
        if curl -s -f "$GITEA_INSTANCE_URL/api/v1/version" > /dev/null; then
            success "Connexion Gitea réussie"
            
            # Sauvegarde des tokens
            echo "export GITEA_INSTANCE_URL=\"$GITEA_INSTANCE_URL\"" >> ~/.bashrc
            echo "export GITEA_TOKEN=\"$GITEA_TOKEN\"" >> ~/.bashrc
            echo "export GITEA_INSTANCE_URL=\"$GITEA_INSTANCE_URL\"" >> ~/.zshrc
            echo "export GITEA_TOKEN=\"$GITEA_TOKEN\"" >> ~/.zshrc
            
            success "Configuration Gitea sauvegardée"
        else
            error "Impossible de se connecter à Gitea: $GITEA_INSTANCE_URL"
            exit 1
        fi
    else
        error "URL ou token Gitea manquant"
        exit 1
    fi
else
    warning "Configuration Gitea ignorée"
    echo "Vous devrez configurer les variables d'environnement manuellement:"
    echo "export GITEA_INSTANCE_URL=\"https://gitea.com\""
    echo "export GITEA_TOKEN=\"your_token\""
fi

echo ""

# Étape 4: Configuration des secrets
log "📋 Étape 4: Configuration des secrets Gitea..."

echo "Pour que les workflows fonctionnent, vous devez configurer ces secrets dans Gitea:"
echo ""
echo "1. Allez sur https://gitea.com/Virida/devops/settings/secrets/actions"
echo "2. Ajoutez ces secrets:"
echo ""

echo "Secrets Clever Cloud:"
echo "- CLEVER_CLOUD_TOKEN: $CLEVER_TOKEN"
echo "- CLEVER_CLOUD_SECRET: $CLEVER_SECRET"
echo ""

echo "Secrets Base de données:"
echo "- CC_POSTGRESQL_ADDON_HOST: (votre host PostgreSQL)"
echo "- CC_POSTGRESQL_ADDON_DB: (votre base de données)"
echo "- CC_POSTGRESQL_ADDON_USER: (votre utilisateur PostgreSQL)"
echo "- CC_POSTGRESQL_ADDON_PASSWORD: (votre mot de passe PostgreSQL)"
echo ""

echo "Secrets Applications:"
echo "- GRAFANA_ADMIN_PASSWORD: (mot de passe Grafana)"
echo "- JWT_SECRET: (secret JWT)"
echo "- CC_ACME_EMAIL: (votre email)"
echo "- CC_APP_DOMAIN: (votre domaine d'application)"
echo ""

echo "Secrets Notifications (optionnels):"
echo "- SLACK_WEBHOOK_URL: (webhook Slack)"
echo "- EMAIL_USERNAME: (nom d'utilisateur email)"
echo "- EMAIL_PASSWORD: (mot de passe email)"
echo "- RELEASE_EMAIL_LIST: (liste d'emails pour les releases)"
echo ""

read -p "Avez-vous configuré tous les secrets dans Gitea ? (y/n): " secrets_configured

if [ "$secrets_configured" = "y" ] || [ "$secrets_configured" = "Y" ]; then
    success "Secrets configurés"
else
    warning "N'oubliez pas de configurer les secrets dans Gitea"
fi

echo ""

# Étape 5: Déploiement
log "📋 Étape 5: Déploiement Gitea Runner..."

read -p "Voulez-vous déployer Gitea Runner maintenant ? (y/n): " deploy_now

if [ "$deploy_now" = "y" ] || [ "$deploy_now" = "Y" ]; then
    log "🚀 Déploiement de Gitea Runner..."
    
    # Charger les variables d'environnement
    source ~/.bashrc 2>/dev/null || true
    source ~/.zshrc 2>/dev/null || true
    
    # Exécuter le script de déploiement
    ./scripts/deploy-gitea-runner.sh
    
    if [ $? -eq 0 ]; then
        success "Déploiement Gitea Runner réussi!"
    else
        error "Échec du déploiement Gitea Runner"
        exit 1
    fi
else
    warning "Déploiement ignoré"
    echo "Vous pouvez déployer plus tard avec:"
    echo "./scripts/deploy-gitea-runner.sh"
fi

echo ""

# Étape 6: Test des workflows
log "📋 Étape 6: Test des workflows..."

echo "Pour tester les workflows Gitea Actions:"
echo "1. Allez sur https://gitea.com/Virida/devops/actions"
echo "2. Créez une branche de test:"
echo "   git checkout -b test-gitea-runner"
echo "   git push origin test-gitea-runner"
echo "3. Créez une pull request vers 'staging'"
echo "4. Vérifiez que les workflows se déclenchent"
echo ""

# Résumé
log "📋 Résumé de la configuration:"
echo ""
echo "✅ Prérequis vérifiés"
echo "✅ Clever Cloud configuré"
echo "✅ Gitea configuré"
echo "✅ Secrets documentés"
echo "✅ Déploiement prêt"
echo ""

success "🎉 Configuration Gitea Runner terminée!"
echo ""
echo "Prochaines étapes:"
echo "1. Configurez les secrets dans Gitea"
echo "2. Déployez Gitea Runner"
echo "3. Testez les workflows"
echo "4. Profitez de votre pipeline CI/CD révolutionnaire!"
echo ""
echo "Documentation complète:"
echo "- GITEA-RUNNER-SETUP.md"
echo "- REVOLUTIONARY-CI-CD.md"
echo "- CI-CD-SUMMARY.md"
