#!/bin/bash

# Script de déploiement du Gitea Runner sur Clever Cloud
# Usage: ./deploy-gitea-runner.sh

set -e

echo "🚀 Déploiement du Gitea Runner sur Clever Cloud"
echo "==============================================="

# Variables
APP_NAME="virida-gitea-runner"
CLEVER_ORG="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Vérifier les prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Clever CLI
    if ! command -v clever &> /dev/null; then
        log_error "Clever CLI n'est pas installé. Installez-le d'abord :"
        echo "curl -fsSL https://clever-tools.clever-cloud.com/releases/2.7.0/clever-tools-linux.tar.gz | tar -xz"
        echo "sudo mv clever /usr/local/bin/"
        exit 1
    fi
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé."
        exit 1
    fi
    
    log_info "Prérequis OK ✓"
}

# Se connecter à Clever Cloud
login_clever() {
    log_info "Connexion à Clever Cloud..."
    
    # Vérifier si déjà connecté
    if clever status &> /dev/null; then
        log_info "Déjà connecté à Clever Cloud ✓"
        return
    fi
    
    # Demander les credentials
    echo ""
    echo "Veuillez entrer vos credentials Clever Cloud :"
    read -p "Token: " CLEVER_TOKEN
    read -p "Secret: " CLEVER_SECRET
    
    if [ -z "$CLEVER_TOKEN" ] || [ -z "$CLEVER_SECRET" ]; then
        log_error "Token et Secret requis"
        exit 1
    fi
    
    # Se connecter
    clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET"
    
    log_info "Connecté à Clever Cloud ✓"
}

# Créer l'application
create_app() {
    log_info "Création de l'application $APP_NAME..."
    
    # Vérifier si l'app existe déjà
    if clever apps | grep -q "$APP_NAME"; then
        log_warn "L'application $APP_NAME existe déjà"
        return
    fi
    
    # Créer l'application
    clever create --type docker "$APP_NAME" --org "$CLEVER_ORG"
    
    log_info "Application $APP_NAME créée ✓"
}

# Configurer l'application
configure_app() {
    log_info "Configuration de l'application..."
    
    # Lier l'application
    clever link --alias "$APP_NAME"
    
    # Configurer les variables d'environnement
    log_info "Configuration des variables d'environnement..."
    
    # Variables Gitea
    clever env set GITEA_INSTANCE_URL "https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io"
    clever env set RUNNER_NAME "virida-runner-clever"
    clever env set RUNNER_LABELS "ubuntu-latest:docker://node:18,ubuntu-latest:docker://python:3.11,ubuntu-latest:docker://golang:1.21"
    
    # Variables de monitoring
    clever env set MONITORING_ENABLED "true"
    clever env set LOG_LEVEL "info"
    
    log_info "Variables d'environnement configurées ✓"
}

# Construire et déployer
build_and_deploy() {
    log_info "Construction et déploiement..."
    
    # Construire l'image Docker
    log_info "Construction de l'image Docker..."
    docker build -f Dockerfile.gitea-runner -t "$APP_NAME:latest" .
    
    # Déployer
    log_info "Déploiement sur Clever Cloud..."
    clever deploy
    
    log_info "Déploiement terminé ✓"
}

# Vérifier le déploiement
verify_deployment() {
    log_info "Vérification du déploiement..."
    
    # Attendre que l'app soit prête
    log_info "Attente du démarrage de l'application..."
    sleep 30
    
    # Vérifier le statut
    if clever status --alias "$APP_NAME" | grep -q "running"; then
        log_info "Application démarrée avec succès ✓"
    else
        log_error "L'application ne démarre pas correctement"
        clever logs --alias "$APP_NAME"
        exit 1
    fi
    
    # Afficher les logs
    log_info "Logs de l'application :"
    clever logs --alias "$APP_NAME" --lines=20
}

# Afficher les informations de connexion
show_connection_info() {
    echo ""
    log_info "Déploiement terminé avec succès ! 🎉"
    echo ""
    echo "Informations de connexion :"
    echo "  Application: $APP_NAME"
    echo "  Organisation: $CLEVER_ORG"
    echo "  URL: https://$APP_NAME.cleverapps.io"
    echo ""
    echo "Pour configurer le runner dans Gitea :"
    echo "1. Allez sur https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/admin/actions/runners"
    echo "2. Créez un nouveau runner"
    echo "3. Utilisez l'URL de l'application comme endpoint"
    echo ""
    echo "Commandes utiles :"
    echo "  clever logs --alias $APP_NAME    # Voir les logs"
    echo "  clever status --alias $APP_NAME  # Voir le statut"
    echo "  clever restart --alias $APP_NAME # Redémarrer"
    echo ""
}

# Fonction principale
main() {
    echo ""
    log_info "Début du déploiement du Gitea Runner"
    echo ""
    
    check_prerequisites
    login_clever
    create_app
    configure_app
    build_and_deploy
    verify_deployment
    show_connection_info
}

# Exécuter le script
main "$@"