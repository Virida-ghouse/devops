#!/bin/bash

# 🔍 Script de Vérification des Prérequis - VIRIDA Gitea
# Vérifie que tous les outils nécessaires sont installés

set -e

echo "🔍 Vérification des Prérequis VIRIDA Gitea"
echo "=========================================="

# Configuration des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
ALL_GOOD=true
DOCKER_AVAILABLE=false
PORTS_AVAILABLE=true

# Fonctions utilitaires
step() {
    echo -e "${BLUE}📋 $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ALL_GOOD=false
}

error() {
    echo -e "${RED}❌ $1${NC}"
    ALL_GOOD=false
}

# Vérification de Docker
check_docker() {
    step "🐳 Vérification de Docker..."
    
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version)
        success "Docker installé: $docker_version"
        
        if docker info > /dev/null 2>&1; then
            success "Docker est en cours d'exécution"
            DOCKER_AVAILABLE=true
        else
            error "Docker n'est pas en cours d'exécution"
        fi
    else
        error "Docker n'est pas installé"
        echo "  💡 Installez Docker Desktop depuis : https://www.docker.com/products/docker-desktop"
    fi
}

# Vérification de Docker Compose
check_docker_compose() {
    step "🐙 Vérification de Docker Compose..."
    
    if command -v docker-compose &> /dev/null; then
        local compose_version=$(docker-compose --version)
        success "Docker Compose installé: $compose_version"
    elif docker compose version > /dev/null 2>&1; then
        success "Docker Compose v2 disponible (plugin Docker)"
    else
        error "Docker Compose n'est pas installé"
        echo "  💡 Docker Compose est généralement inclus avec Docker Desktop"
    fi
}

# Vérification de Git
check_git() {
    step "📚 Vérification de Git..."
    
    if command -v git &> /dev/null; then
        local git_version=$(git --version)
        success "Git installé: $git_version"
    else
        error "Git n'est pas installé"
        echo "  💡 Installez Git avec: brew install git"
    fi
}

# Vérification de curl
check_curl() {
    step "🌐 Vérification de curl..."
    
    if command -v curl &> /dev/null; then
        local curl_version=$(curl --version | head -n1)
        success "curl installé: $curl_version"
    else
        error "curl n'est pas installé"
        echo "  💡 curl est généralement préinstallé sur macOS"
    fi
}

# Vérification des ports
check_ports() {
    step "🔌 Vérification des ports disponibles..."
    
    local ports=("3000" "8080" "9090" "3001" "80" "443")
    
    for port in "${ports[@]}"; do
        if lsof -i ":$port" > /dev/null 2>&1; then
            local process=$(lsof -i ":$port" | tail -n1 | awk '{print $1}')
            warning "Port $port est utilisé par: $process"
            PORTS_AVAILABLE=false
        else
            success "Port $port disponible"
        fi
    done
}

# Vérification de l'espace disque
check_disk_space() {
    step "💾 Vérification de l'espace disque..."
    
    local available_space=$(df -h . | tail -n1 | awk '{print $4}')
    local available_gb=$(df -g . | tail -n1 | awk '{print $4}')
    
    if [ "$available_gb" -gt 10 ]; then
        success "Espace disque suffisant: $available_space disponible"
    else
        warning "Espace disque faible: $available_space disponible (minimum 10GB recommandé)"
    fi
}

# Vérification de la mémoire
check_memory() {
    step "🧠 Vérification de la mémoire..."
    
    local total_mem=$(sysctl -n hw.memsize | awk '{print $0/1024/1024/1024}')
    local total_mem_gb=$(printf "%.1f" $total_mem)
    
    if (( $(echo "$total_mem_gb >= 8" | bc -l) )); then
        success "Mémoire suffisante: ${total_mem_gb}GB total"
    else
        warning "Mémoire faible: ${total_mem_gb}GB total (minimum 8GB recommandé)"
    fi
}

# Vérification des permissions
check_permissions() {
    step "🔐 Vérification des permissions..."
    
    if [ -w . ]; then
        success "Permissions d'écriture dans le répertoire courant"
    else
        error "Pas de permissions d'écriture dans le répertoire courant"
    fi
    
    if [ -r docker-compose.gitea.yml ]; then
        success "Fichier docker-compose.gitea.yml accessible"
    else
        error "Fichier docker-compose.gitea.yml non trouvé"
    fi
}

# Vérification des scripts
check_scripts() {
    step "📜 Vérification des scripts..."
    
    if [ -f "scripts/setup-gitea-virida.sh" ]; then
        if [ -x "scripts/setup-gitea-virida.sh" ]; then
            success "Script setup-gitea-virida.sh exécutable"
        else
            warning "Script setup-gitea-virida.sh non exécutable"
            echo "  💡 Rendez-le exécutable avec: chmod +x scripts/setup-gitea-virida.sh"
        fi
    else
        error "Script setup-gitea-virida.sh non trouvé"
    fi
}

# Vérification de la connectivité réseau
check_network() {
    step "🌍 Vérification de la connectivité réseau..."
    
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        success "Connectivité Internet disponible"
    else
        warning "Problème de connectivité Internet"
    fi
    
    if ping -c 1 localhost > /dev/null 2>&1; then
        success "Réseau local fonctionnel"
    else
        error "Problème avec le réseau local"
    fi
}

# Vérification des entrées DNS locales
check_dns() {
    step "🔍 Vérification des entrées DNS locales..."
    
    local hosts_file="/etc/hosts"
    local required_hosts=("gitea.virida.local" "drone.virida.local" "prometheus.virida.local" "grafana.virida.local")
    local missing_hosts=()
    
    for host in "${required_hosts[@]}"; do
        if grep -q "$host" "$hosts_file" 2>/dev/null; then
            success "Entrée DNS pour $host trouvée"
        else
            missing_hosts+=("$host")
        fi
    done
    
    if [ ${#missing_hosts[@]} -gt 0 ]; then
        warning "Entrées DNS manquantes: ${missing_hosts[*]}"
        echo "  💡 Ajoutez ces lignes dans /etc/hosts:"
        for host in "${missing_hosts[@]}"; do
            echo "     127.0.0.1 $host"
        done
    fi
}

# Recommandations
show_recommendations() {
    echo ""
    echo "📋 Recommandations et Actions"
    echo "============================="
    
    if [ "$ALL_GOOD" = true ]; then
        echo "🎉 Tous les prérequis sont satisfaits !"
        echo ""
        echo "🚀 Vous pouvez maintenant démarrer l'infrastructure VIRIDA :"
        echo "   docker-compose -f docker-compose.gitea.yml up -d"
        echo ""
        echo "🔧 Puis configurer Gitea automatiquement :"
        echo "   ./scripts/setup-gitea-virida.sh"
    else
        echo "⚠️  Certains prérequis ne sont pas satisfaits."
        echo ""
        echo "🔧 Actions recommandées :"
        
        if [ "$DOCKER_AVAILABLE" = false ]; then
            echo "   1. Installer et démarrer Docker Desktop"
            echo "   2. Vérifier que Docker est en cours d'exécution"
        fi
        
        if [ "$PORTS_AVAILABLE" = false ]; then
            echo "   3. Libérer les ports utilisés ou modifier la configuration"
        fi
        
        echo ""
        echo "📚 Consultez le guide d'installation : PREREQUIS_INSTALLATION.md"
    fi
}

# Configuration des environnements
setup_environment() {
    if [ "$ALL_GOOD" = true ]; then
        echo ""
        echo "🔧 Configuration de l'environnement..."
        echo "===================================="
        
        # Créer les dossiers nécessaires
        mkdir -p gitea monitoring/prometheus monitoring/grafana traefik
        
        # Rendre le script exécutable
        chmod +x scripts/setup-gitea-virida.sh
        
        success "Environnement configuré"
        echo ""
        echo "🚀 Prêt à démarrer l'infrastructure VIRIDA Gitea !"
    fi
}

# Fonction principale
main() {
    echo "🔍 Démarrage de la vérification des prérequis..."
    echo "================================================"
    
    # Vérifications
    check_docker
    check_docker_compose
    check_git
    check_curl
    check_ports
    check_disk_space
    check_memory
    check_permissions
    check_scripts
    check_network
    check_dns
    
    # Résumé et recommandations
    show_recommendations
    
    # Configuration de l'environnement si tout est OK
    setup_environment
    
    echo ""
    if [ "$ALL_GOOD" = true ]; then
        echo "🎉 Vérification terminée avec succès !"
        exit 0
    else
        echo "⚠️  Vérification terminée avec des avertissements."
        exit 1
    fi
}

# Exécution du script
main "$@"

