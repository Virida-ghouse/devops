#!/bin/bash

# 🌐 Script de Configuration DNS Local - VIRIDA Gitea
# Configure automatiquement les entrées DNS dans /etc/hosts

set -e

echo "🌐 Configuration DNS Local VIRIDA"
echo "================================="

# Configuration des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
HOSTS_FILE="/etc/hosts"
VIRIDA_HOSTS=(
    "127.0.0.1 gitea.virida.local"
    "127.0.0.1 drone.virida.local"
    "127.0.0.1 prometheus.virida.local"
    "127.0.0.1 grafana.virida.local"
    "127.0.0.1 app.virida.local"
    "127.0.0.1 api.virida.local"
    "127.0.0.1 traefik.virida.local"
)

# Fonctions utilitaires
step() {
    echo -e "${BLUE}📋 $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier les permissions sudo
check_sudo() {
    step "🔐 Vérification des permissions sudo..."
    
    if sudo -n true 2>/dev/null; then
        success "Permissions sudo disponibles"
    else
        error "Permissions sudo requises pour modifier /etc/hosts"
        echo "  💡 Ce script nécessite des permissions sudo pour modifier le fichier hosts"
        echo "  💡 Exécutez avec: sudo ./setup-local-dns.sh"
        exit 1
    fi
}

# Sauvegarder le fichier hosts
backup_hosts() {
    step "💾 Sauvegarde du fichier hosts..."
    
    local backup_file="/etc/hosts.backup.$(date +%Y%m%d_%H%M%S)"
    
    if sudo cp "$HOSTS_FILE" "$backup_file"; then
        success "Fichier hosts sauvegardé: $backup_file"
    else
        error "Échec de la sauvegarde du fichier hosts"
        exit 1
    fi
}

# Ajouter les entrées VIRIDA
add_virida_hosts() {
    step "🏗️  Ajout des entrées DNS VIRIDA..."
    
    local added_count=0
    
    for host_entry in "${VIRIDA_HOSTS[@]}"; do
        if grep -q "$(echo "$host_entry" | awk '{print $2}')" "$HOSTS_FILE"; then
            warning "Entrée DNS déjà présente: $host_entry"
        else
            if echo "$host_entry" | sudo tee -a "$HOSTS_FILE" > /dev/null; then
                success "Entrée DNS ajoutée: $host_entry"
                added_count=$((added_count + 1))
            else
                error "Échec de l'ajout de l'entrée DNS: $host_entry"
            fi
        fi
    done
    
    if [ $added_count -gt 0 ]; then
        success "$added_count entrées DNS ajoutées"
    else
        warning "Aucune nouvelle entrée DNS ajoutée"
    fi
}

# Vérifier la configuration
verify_configuration() {
    step "🔍 Vérification de la configuration DNS..."
    
    local all_configured=true
    
    for host_entry in "${VIRIDA_HOSTS[@]}"; do
        local hostname=$(echo "$host_entry" | awk '{print $2}')
        if grep -q "$hostname" "$HOSTS_FILE"; then
            success "✓ $hostname configuré"
        else
            error "✗ $hostname non configuré"
            all_configured=false
        fi
    done
    
    if [ "$all_configured" = true ]; then
        success "Toutes les entrées DNS VIRIDA sont configurées"
    else
        error "Certaines entrées DNS ne sont pas configurées"
    fi
    
    return $([ "$all_configured" = true ] && echo 0 || echo 1)
}

# Test de résolution DNS
test_dns_resolution() {
    step "🧪 Test de résolution DNS..."
    
    local test_success=true
    
    for host_entry in "${VIRIDA_HOSTS[@]}"; do
        local hostname=$(echo "$host_entry" | awk '{print $2}')
        local expected_ip=$(echo "$host_entry" | awk '{print $1}')
        
        if ping -c 1 "$hostname" > /dev/null 2>&1; then
            success "✓ $hostname résout vers $expected_ip"
        else
            error "✗ $hostname ne résout pas correctement"
            test_success=false
        fi
    done
    
    if [ "$test_success" = true ]; then
        success "Tous les tests DNS sont réussis"
    else
        warning "Certains tests DNS ont échoué"
    fi
    
    return $([ "$test_success" = true ] && echo 0 || echo 1)
}

# Afficher le résumé
show_summary() {
    echo ""
    echo "📋 Résumé de la Configuration DNS"
    echo "================================="
    echo ""
    echo "🏗️  Entrées DNS configurées :"
    for host_entry in "${VIRIDA_HOSTS[@]}"; do
        echo "  • $host_entry"
    done
    echo ""
    echo "🔗 Accès aux services VIRIDA :"
    echo "  🌐 Gitea: http://gitea.virida.local:3000"
    echo "  🚀 Drone CI: http://drone.virida.local:8080"
    echo "  📊 Prometheus: http://prometheus.virida.local:9090"
    echo "  📈 Grafana: http://grafana.virida.local:3001"
    echo "  🌍 App: http://app.virida.local"
    echo "  ⚙️  API: http://api.virida.local"
    echo ""
    echo "💡 Prochaines étapes :"
    echo "  1. Installer Docker Desktop"
    echo "  2. Démarrer l'infrastructure: docker-compose -f docker-compose.gitea.yml up -d"
    echo "  3. Configurer Gitea: ./scripts/setup-gitea-virida.sh"
}

# Fonction principale
main() {
    echo "🌐 Démarrage de la configuration DNS locale..."
    echo "============================================="
    
    # Vérifications
    check_sudo
    backup_hosts
    
    # Configuration
    add_virida_hosts
    verify_configuration
    
    # Tests
    test_dns_resolution
    
    # Résumé
    show_summary
    
    echo ""
    echo "🎉 Configuration DNS locale terminée !"
    echo "====================================="
}

# Exécution du script
main "$@"

