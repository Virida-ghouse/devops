#!/bin/bash

# 📊 Dashboard DevOps VIRIDA
# Ce script affiche un dashboard de monitoring de l'infrastructure

set -e

# Couleurs pour le dashboard
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
ORGANIZATION_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"
CLEVER_ALIAS_PREFIX="virida"

# Applications
APPS=(
    "frontend-3d:Node.js:3000:🟢"
    "ai-ml:Python:8000:🔵"
    "gitlab-runner:Ubuntu:8080:🟡"
)

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

info() {
    echo -e "${PURPLE}[$(date +'%Y-%m-%d %H:%M:%S')] ℹ️ $1${NC}"
}

# Fonction pour afficher le header
show_header() {
    clear
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                          📊 DEVOPS DASHBOARD VIRIDA                          ║${NC}"
    echo -e "${WHITE}║                    Infrastructure & CI/CD Monitoring                         ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Fonction pour afficher le statut d'une application
show_app_status() {
    local app_name=$1
    local app_type=$2
    local app_port=$3
    local app_icon=$4
    local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
    
    echo -e "${CYAN}┌─ ${app_icon} $app_name ($app_type)${NC}"
    
    # Vérification du statut
    if clever status --alias "$CLEVER_ALIAS" &> /dev/null; then
        echo -e "${GREEN}│   Status: ✅ Running${NC}"
        echo -e "${GREEN}│   URL: https://$CLEVER_ALIAS.cleverapps.io${NC}"
        
        # Test de connectivité
        if curl -s -f "https://$CLEVER_ALIAS.cleverapps.io/health" &> /dev/null; then
            echo -e "${GREEN}│   Health: ✅ Healthy${NC}"
        else
            echo -e "${YELLOW}│   Health: ⚠️ Unhealthy${NC}"
        fi
        
        # Informations sur l'application
        local app_info=$(clever applications --json | jq -r ".[] | select(.alias == \"$CLEVER_ALIAS\") | .name")
        if [ -n "$app_info" ]; then
            echo -e "${BLUE}│   App: $app_info${NC}"
        fi
        
    else
        echo -e "${RED}│   Status: ❌ Not Running${NC}"
        echo -e "${RED}│   Error: Application not found or not accessible${NC}"
    fi
    
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

# Fonction pour afficher les métriques système
show_system_metrics() {
    echo -e "${PURPLE}📊 MÉTRIQUES SYSTÈME${NC}"
    echo -e "${PURPLE}─────────────────────────────────────────────────────────────────────────────${NC}"
    
    # CPU
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    if [ -n "$cpu_usage" ]; then
        if (( $(echo "$cpu_usage < 70" | bc -l) )); then
            echo -e "${GREEN}│ CPU Usage: $cpu_usage% ✅${NC}"
        elif (( $(echo "$cpu_usage < 90" | bc -l) )); then
            echo -e "${YELLOW}│ CPU Usage: $cpu_usage% ⚠️${NC}"
        else
            echo -e "${RED}│ CPU Usage: $cpu_usage% ❌${NC}"
        fi
    fi
    
    # Mémoire
    local mem_usage=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    if [ -n "$mem_usage" ]; then
        echo -e "${BLUE}│ Memory: $mem_usage pages active${NC}"
    fi
    
    # Disque
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ -n "$disk_usage" ]; then
        if [ "$disk_usage" -lt 80 ]; then
            echo -e "${GREEN}│ Disk Usage: $disk_usage% ✅${NC}"
        elif [ "$disk_usage" -lt 95 ]; then
            echo -e "${YELLOW}│ Disk Usage: $disk_usage% ⚠️${NC}"
        else
            echo -e "${RED}│ Disk Usage: $disk_usage% ❌${NC}"
        fi
    fi
    
    echo -e "${PURPLE}─────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

# Fonction pour afficher les logs récents
show_recent_logs() {
    echo -e "${YELLOW}📋 LOGS RÉCENTS${NC}"
    echo -e "${YELLOW}─────────────────────────────────────────────────────────────────────────────${NC}"
    
    for app_config in "${APPS[@]}"; do
        IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
        local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
        
        echo -e "${CYAN}┌─ $app_icon $app_name${NC}"
        
        # Récupération des logs récents
        local logs=$(clever logs --alias "$CLEVER_ALIAS" --lines 3 2>/dev/null | tail -3)
        if [ -n "$logs" ]; then
            echo "$logs" | while read -r line; do
                echo -e "${BLUE}│ $line${NC}"
            done
        else
            echo -e "${RED}│ No logs available${NC}"
        fi
        
        echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────${NC}"
    done
    
    echo ""
}

# Fonction pour afficher les alertes
show_alerts() {
    echo -e "${RED}🚨 ALERTES${NC}"
    echo -e "${RED}─────────────────────────────────────────────────────────────────────────────${NC}"
    
    local alert_count=0
    
    # Vérification des applications
    for app_config in "${APPS[@]}"; do
        IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
        local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
        
        if ! clever status --alias "$CLEVER_ALIAS" &> /dev/null; then
            echo -e "${RED}│ ❌ $app_name: Application not running${NC}"
            ((alert_count++))
        fi
    done
    
    if [ $alert_count -eq 0 ]; then
        echo -e "${GREEN}│ ✅ Aucune alerte active${NC}"
    else
        echo -e "${RED}│ ⚠️ $alert_count alerte(s) active(s)${NC}"
    fi
    
    echo -e "${RED}─────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

# Fonction pour afficher les informations de déploiement
show_deployment_info() {
    echo -e "${GREEN}🚀 INFORMATIONS DE DÉPLOIEMENT${NC}"
    echo -e "${GREEN}─────────────────────────────────────────────────────────────────────────────${NC}"
    
    echo -e "${BLUE}│ Organisation: $ORGANIZATION_ID${NC}"
    echo -e "${BLUE}│ Applications: ${#APPS[@]}${NC}"
    echo -e "${BLUE}│ Infrastructure: Clever Cloud${NC}"
    echo -e "${BLUE}│ CI/CD: GitLab Runner${NC}"
    echo -e "${BLUE}│ Monitoring: Actif${NC}"
    
    echo -e "${GREEN}─────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

# Fonction pour afficher le menu
show_menu() {
    echo -e "${WHITE}🔧 MENU DE CONTRÔLE${NC}"
    echo -e "${WHITE}─────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}│ 1. Rafraîchir le dashboard${NC}"
    echo -e "${CYAN}│ 2. Voir les logs détaillés${NC}"
    echo -e "${CYAN}│ 3. Redéployer une application${NC}"
    echo -e "${CYAN}│ 4. Voir les variables d'environnement${NC}"
    echo -e "${CYAN}│ 5. Tester la connectivité${NC}"
    echo -e "${CYAN}│ 6. Quitter${NC}"
    echo -e "${WHITE}─────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

# Fonction principale du dashboard
run_dashboard() {
    while true; do
        show_header
        show_deployment_info
        
        # Affichage du statut des applications
        for app_config in "${APPS[@]}"; do
            IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
            show_app_status "$app_name" "$app_type" "$app_port" "$app_icon"
        done
        
        show_system_metrics
        show_recent_logs
        show_alerts
        show_menu
        
        read -p "Choisissez une option (1-6): " choice
        
        case $choice in
            1)
                log "Rafraîchissement du dashboard..."
                sleep 2
                ;;
            2)
                log "Affichage des logs détaillés..."
                for app_config in "${APPS[@]}"; do
                    IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
                    local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
                    echo -e "${CYAN}=== Logs de $app_name ===${NC}"
                    clever logs --alias "$CLEVER_ALIAS" --lines 20
                    echo ""
                done
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            3)
                log "Redéploiement d'une application..."
                echo "Applications disponibles:"
                for i in "${!APPS[@]}"; do
                    IFS=':' read -r app_name app_type app_port app_icon <<< "${APPS[$i]}"
                    echo "$((i+1)). $app_name ($app_type)"
                done
                read -p "Choisissez une application (1-${#APPS[@]}): " app_choice
                
                if [ "$app_choice" -ge 1 ] && [ "$app_choice" -le "${#APPS[@]}" ]; then
                    IFS=':' read -r app_name app_type app_port app_icon <<< "${APPS[$((app_choice-1))]}"
                    local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
                    log "Redéploiement de $app_name..."
                    clever deploy --alias "$CLEVER_ALIAS"
                    success "Redéploiement de $app_name terminé"
                else
                    error "Choix invalide"
                fi
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            4)
                log "Variables d'environnement..."
                for app_config in "${APPS[@]}"; do
                    IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
                    local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
                    echo -e "${CYAN}=== Variables de $app_name ===${NC}"
                    clever env --alias "$CLEVER_ALIAS"
                    echo ""
                done
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            5)
                log "Test de connectivité..."
                for app_config in "${APPS[@]}"; do
                    IFS=':' read -r app_name app_type app_port app_icon <<< "$app_config"
                    local CLEVER_ALIAS="${CLEVER_ALIAS_PREFIX}-${app_name}"
                    local url="https://$CLEVER_ALIAS.cleverapps.io"
                    echo -e "${CYAN}Test de $app_name ($url)...${NC}"
                    
                    if curl -s -f "$url/health" &> /dev/null; then
                        echo -e "${GREEN}✅ $app_name: Connecté${NC}"
                    else
                        echo -e "${RED}❌ $app_name: Non connecté${NC}"
                    fi
                done
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            6)
                log "Arrêt du dashboard..."
                success "Dashboard fermé"
                exit 0
                ;;
            *)
                warning "Option invalide"
                sleep 1
                ;;
        esac
    done
}

# Vérification des prérequis
if ! command -v clever &> /dev/null; then
    error "Clever Tools n'est pas installé"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    warning "jq n'est pas installé, certaines fonctionnalités peuvent être limitées"
fi

# Lancement du dashboard
run_dashboard



