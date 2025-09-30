#!/bin/bash

# Script de configuration du Gitea Runner pour VIRIDA
# Usage: ./setup-gitea-runner.sh

set -e

echo "🚀 Configuration du Gitea Runner pour VIRIDA"
echo "============================================="

# Variables
GITEA_URL="https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io"
RUNNER_NAME="virida-runner-$(hostname)"
RUNNER_LABELS="ubuntu-latest:docker://node:18,ubuntu-latest:docker://python:3.11,ubuntu-latest:docker://golang:1.21"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Vérifier les prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    
    # Vérifier wget
    if ! command -v wget &> /dev/null; then
        log_error "wget n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    
    log_info "Prérequis OK ✓"
}

# Télécharger et installer act_runner
install_act_runner() {
    log_info "Installation d'act_runner..."
    
    # Créer le répertoire
    mkdir -p /opt/gitea-runner
    cd /opt/gitea-runner
    
    # Télécharger act_runner
    ACT_RUNNER_VERSION="0.3.0"
    ACT_RUNNER_URL="https://gitea.com/gitea/act_runner/releases/download/v${ACT_RUNNER_VERSION}/act_runner-${ACT_RUNNER_VERSION}-linux-amd64.tar.gz"
    
    log_info "Téléchargement d'act_runner v${ACT_RUNNER_VERSION}..."
    wget -O act_runner.tar.gz "$ACT_RUNNER_URL"
    
    # Extraire
    tar -xzf act_runner.tar.gz
    chmod +x act_runner
    
    # Créer un lien symbolique
    ln -sf /opt/gitea-runner/act_runner /usr/local/bin/act_runner
    
    log_info "act_runner installé ✓"
}

# Configurer le runner
configure_runner() {
    log_info "Configuration du runner..."
    
    echo ""
    echo "Pour configurer le runner, vous avez besoin :"
    echo "1. D'un token d'enregistrement depuis Gitea"
    echo "2. D'accéder à votre instance Gitea : $GITEA_URL"
    echo ""
    echo "Pour obtenir le token :"
    echo "1. Allez sur $GITEA_URL/admin/actions/runners"
    echo "2. Cliquez sur 'Create new Runner'"
    echo "3. Copiez le token d'enregistrement"
    echo ""
    
    read -p "Entrez le token d'enregistrement : " REGISTRATION_TOKEN
    
    if [ -z "$REGISTRATION_TOKEN" ]; then
        log_error "Token d'enregistrement requis"
        exit 1
    fi
    
    # Enregistrer le runner
    log_info "Enregistrement du runner..."
    act_runner register \
        --instance "$GITEA_URL" \
        --token "$REGISTRATION_TOKEN" \
        --name "$RUNNER_NAME" \
        --labels "$RUNNER_LABELS" \
        --no-interactive
    
    log_info "Runner enregistré ✓"
}

# Créer le service systemd
create_systemd_service() {
    log_info "Création du service systemd..."
    
    cat > /etc/systemd/system/gitea-runner.service << EOF
[Unit]
Description=Gitea Runner for VIRIDA
After=network.target docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/gitea-runner
ExecStart=/usr/local/bin/act_runner daemon
Restart=always
RestartSec=5
Environment=PATH=/usr/local/bin:/usr/bin:/bin

[Install]
WantedBy=multi-user.target
EOF

    # Recharger systemd et démarrer le service
    systemctl daemon-reload
    systemctl enable gitea-runner
    systemctl start gitea-runner
    
    log_info "Service systemd créé et démarré ✓"
}

# Vérifier le statut
check_status() {
    log_info "Vérification du statut..."
    
    # Vérifier le service
    if systemctl is-active --quiet gitea-runner; then
        log_info "Service gitea-runner actif ✓"
    else
        log_error "Service gitea-runner inactif"
        systemctl status gitea-runner
        exit 1
    fi
    
    # Vérifier les logs
    log_info "Logs récents :"
    journalctl -u gitea-runner --lines=10 --no-pager
}

# Fonction principale
main() {
    echo ""
    log_info "Début de la configuration du Gitea Runner"
    echo ""
    
    check_prerequisites
    install_act_runner
    configure_runner
    create_systemd_service
    check_status
    
    echo ""
    log_info "Configuration terminée avec succès ! 🎉"
    echo ""
    echo "Le runner est maintenant configuré et actif."
    echo "Vous pouvez vérifier son statut avec :"
    echo "  systemctl status gitea-runner"
    echo ""
    echo "Pour voir les logs :"
    echo "  journalctl -u gitea-runner -f"
    echo ""
    echo "Le runner apparaîtra dans Gitea sous le nom : $RUNNER_NAME"
    echo "URL Gitea : $GITEA_URL"
    echo ""
}

# Exécuter le script
main "$@"