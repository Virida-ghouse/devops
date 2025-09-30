#!/bin/bash

# Script de démarrage du Gitea Runner pour VIRIDA
# Usage: ./start-gitea-runner.sh

set -e

echo "🚀 Démarrage du Gitea Runner VIRIDA"
echo "===================================="

# Variables
GITEA_URL="https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io"
RUNNER_NAME="virida-runner-$(hostname)"
RUNNER_LABELS="ubuntu-latest:docker://node:18,ubuntu-latest:docker://python:3.11,ubuntu-latest:docker://golang:1.21"

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

# Vérifier si act_runner est installé
check_act_runner() {
    if ! command -v act_runner &> /dev/null; then
        log_error "act_runner n'est pas installé. Exécutez d'abord setup-gitea-runner.sh"
        exit 1
    fi
    
    log_info "act_runner trouvé ✓"
}

# Vérifier la configuration
check_config() {
    log_info "Vérification de la configuration..."
    
    # Vérifier si le runner est enregistré
    if [ ! -f "/opt/gitea-runner/.runner" ]; then
        log_error "Le runner n'est pas enregistré. Exécutez d'abord setup-gitea-runner.sh"
        exit 1
    fi
    
    log_info "Configuration OK ✓"
}

# Vérifier Docker
check_docker() {
    log_info "Vérification de Docker..."
    
    if ! docker info &> /dev/null; then
        log_error "Docker n'est pas accessible. Vérifiez que Docker est démarré."
        exit 1
    fi
    
    log_info "Docker OK ✓"
}

# Démarrer le runner en mode daemon
start_daemon() {
    log_info "Démarrage du runner en mode daemon..."
    
    # Créer le répertoire de travail
    mkdir -p /opt/gitea-runner
    cd /opt/gitea-runner
    
    # Démarrer act_runner
    log_info "Lancement d'act_runner daemon..."
    log_info "Runner: $RUNNER_NAME"
    log_info "Labels: $RUNNER_LABELS"
    log_info "Gitea URL: $GITEA_URL"
    echo ""
    
    # Démarrer le daemon
    act_runner daemon
}

# Démarrer le runner en mode interactif
start_interactive() {
    log_info "Démarrage du runner en mode interactif..."
    
    # Créer le répertoire de travail
    mkdir -p /opt/gitea-runner
    cd /opt/gitea-runner
    
    # Démarrer act_runner
    log_info "Lancement d'act_runner..."
    log_info "Runner: $RUNNER_NAME"
    log_info "Labels: $RUNNER_LABELS"
    log_info "Gitea URL: $GITEA_URL"
    echo ""
    
    # Démarrer en mode interactif
    act_runner daemon --config /opt/gitea-runner/config.yaml
}

# Afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --daemon     Démarrer en mode daemon (défaut)"
    echo "  -i, --interactive Démarrer en mode interactif"
    echo "  -h, --help       Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0                # Démarrer en mode daemon"
    echo "  $0 --daemon       # Démarrer en mode daemon"
    echo "  $0 --interactive  # Démarrer en mode interactif"
    echo ""
}

# Fonction principale
main() {
    local mode="daemon"
    
    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--daemon)
                mode="daemon"
                shift
                ;;
            -i|--interactive)
                mode="interactive"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo ""
    log_info "Démarrage du Gitea Runner VIRIDA"
    echo ""
    
    check_act_runner
    check_config
    check_docker
    
    echo ""
    log_info "Mode de démarrage: $mode"
    echo ""
    
    if [ "$mode" = "daemon" ]; then
        start_daemon
    else
        start_interactive
    fi
}

# Exécuter le script
main "$@"