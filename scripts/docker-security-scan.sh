#!/bin/bash

# 🔒 VIRIDA Docker Security Scan Script
# Script de scan de vulnérabilités pour les images Docker

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCAN_RESULTS_DIR="$PROJECT_ROOT/security-scan-results"
TRIVY_CACHE_DIR="$PROJECT_ROOT/.trivy-cache"

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables d'environnement
SCAN_IMAGES="${SCAN_IMAGES:-all}"
SCAN_TYPE="${SCAN_TYPE:-vuln}"
FAIL_ON_CRITICAL="${FAIL_ON_CRITICAL:-true}"
GENERATE_REPORT="${GENERATE_REPORT:-true}"
REPORT_FORMAT="${REPORT_FORMAT:-json}"

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    if ! command -v trivy &> /dev/null; then
        log_info "Trivy n'est pas installé, installation en cours..."
        install_trivy
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker n'est pas démarré ou accessible"
        exit 1
    fi
    
    log_success "Prérequis vérifiés"
}

# Installation de Trivy
install_trivy() {
    log_info "Installation de Trivy..."
    
    if command -v brew &> /dev/null; then
        brew install trivy
    elif command -v curl &> /dev/null; then
        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
    else
        log_error "Impossible d'installer Trivy automatiquement"
        log_info "Veuillez installer Trivy manuellement: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
        exit 1
    fi
    
    log_success "Trivy installé"
}

# Création des répertoires de résultats
setup_directories() {
    log_info "Configuration des répertoires..."
    
    mkdir -p "$SCAN_RESULTS_DIR"
    mkdir -p "$TRIVY_CACHE_DIR"
    
    log_success "Répertoires configurés"
}

# Scan d'une image Docker
scan_image() {
    local image_name="$1"
    local image_tag="${2:-latest}"
    local full_image="$image_name:$image_tag"
    
    log_info "Scan de l'image: $full_image"
    
    # Vérifier que l'image existe
    if ! docker image inspect "$full_image" &> /dev/null; then
        log_warning "Image $full_image non trouvée, ignorée"
        return 0
    fi
    
    # Nom du fichier de résultat
    local result_file="$SCAN_RESULTS_DIR/$(echo "$image_name" | tr '/' '_')_${image_tag}_scan.${REPORT_FORMAT}"
    
    # Commande de scan Trivy
    local trivy_cmd="trivy image"
    trivy_cmd="$trivy_cmd --cache-dir $TRIVY_CACHE_DIR"
    trivy_cmd="$trivy_cmd --format $REPORT_FORMAT"
    trivy_cmd="$trivy_cmd --output $result_file"
    trivy_cmd="$trivy_cmd --severity CRITICAL,HIGH,MEDIUM,LOW"
    trivy_cmd="$trivy_cmd $full_image"
    
    log_info "Commande de scan: $trivy_cmd"
    
    # Exécuter le scan
    if eval "$trivy_cmd"; then
        log_success "Scan de $full_image terminé"
        
        # Analyser les résultats
        analyze_scan_results "$result_file" "$full_image"
    else
        log_error "Échec du scan de $full_image"
        return 1
    fi
}

# Analyse des résultats de scan
analyze_scan_results() {
    local result_file="$1"
    local image_name="$2"
    
    if [ "$REPORT_FORMAT" = "json" ]; then
        analyze_json_results "$result_file" "$image_name"
    elif [ "$REPORT_FORMAT" = "table" ]; then
        analyze_table_results "$result_file" "$image_name"
    fi
}

# Analyse des résultats JSON
analyze_json_results() {
    local result_file="$1"
    local image_name="$2"
    
    if [ ! -f "$result_file" ]; then
        log_warning "Fichier de résultat non trouvé: $result_file"
        return
    fi
    
    # Compter les vulnérabilités par niveau
    local critical_count=$(jq '.Results[].Vulnerabilities[]? | select(.Severity == "CRITICAL") | .VulnerabilityID' "$result_file" 2>/dev/null | wc -l || echo "0")
    local high_count=$(jq '.Results[].Vulnerabilities[]? | select(.Severity == "HIGH") | .VulnerabilityID' "$result_file" 2>/dev/null | wc -l || echo "0")
    local medium_count=$(jq '.Results[].Vulnerabilities[]? | select(.Severity == "MEDIUM") | .VulnerabilityID' "$result_file" 2>/dev/null | wc -l || echo "0")
    local low_count=$(jq '.Results[].Vulnerabilities[]? | select(.Severity == "LOW") | .VulnerabilityID' "$result_file" 2>/dev/null | wc -l || echo "0")
    
    log_info "Résultats pour $image_name:"
    log_info "  CRITICAL: $critical_count"
    log_info "  HIGH: $high_count"
    log_info "  MEDIUM: $medium_count"
    log_info "  LOW: $low_count"
    
    # Vérifier si on doit échouer sur les vulnérabilités critiques
    if [ "$FAIL_ON_CRITICAL" = "true" ] && [ "$critical_count" -gt 0 ]; then
        log_error "Vulnérabilités critiques détectées dans $image_name"
        return 1
    fi
}

# Analyse des résultats table
analyze_table_results() {
    local result_file="$1"
    local image_name="$2"
    
    if [ ! -f "$result_file" ]; then
        log_warning "Fichier de résultat non trouvé: $result_file"
        return
    fi
    
    # Compter les vulnérabilités par niveau
    local critical_count=$(grep -c "CRITICAL" "$result_file" || echo "0")
    local high_count=$(grep -c "HIGH" "$result_file" || echo "0")
    local medium_count=$(grep -c "MEDIUM" "$result_file" || echo "0")
    local low_count=$(grep -c "LOW" "$result_file" || echo "0")
    
    log_info "Résultats pour $image_name:"
    log_info "  CRITICAL: $critical_count"
    log_info "  HIGH: $high_count"
    log_info "  MEDIUM: $medium_count"
    log_info "  LOW: $low_count"
    
    # Vérifier si on doit échouer sur les vulnérabilités critiques
    if [ "$FAIL_ON_CRITICAL" = "true" ] && [ "$critical_count" -gt 0 ]; then
        log_error "Vulnérabilités critiques détectées dans $image_name"
        return 1
    fi
}

# Scan de toutes les images VIRIDA
scan_all_images() {
    log_info "Scan de toutes les images VIRIDA..."
    
    # Images frontend
    scan_image "virida-3d-visualizer" "latest"
    scan_image "virida-dashboard" "latest"
    
    # Images backend
    scan_image "virida-api-gateway" "latest"
    scan_image "virida-user-service" "latest"
    
    # Images AI/ML
    scan_image "virida-prediction-engine" "latest"
    
    # Images d'infrastructure
    scan_image "postgres" "15-alpine"
    scan_image "redis" "7-alpine"
    scan_image "prom/prometheus" "latest"
    scan_image "grafana/grafana" "latest"
    
    log_success "Scan de toutes les images terminé"
}

# Scan des images frontend
scan_frontend_images() {
    log_info "Scan des images frontend..."
    
    scan_image "virida-3d-visualizer" "latest"
    scan_image "virida-dashboard" "latest"
    
    log_success "Scan des images frontend terminé"
}

# Scan des images backend
scan_backend_images() {
    log_info "Scan des images backend..."
    
    scan_image "virida-api-gateway" "latest"
    scan_image "virida-user-service" "latest"
    
    log_success "Scan des images backend terminé"
}

# Scan des images AI/ML
scan_ai_ml_images() {
    log_info "Scan des images AI/ML..."
    
    scan_image "virida-prediction-engine" "latest"
    
    log_success "Scan des images AI/ML terminé"
}

# Scan des images d'infrastructure
scan_infrastructure_images() {
    log_info "Scan des images d'infrastructure..."
    
    scan_image "postgres" "15-alpine"
    scan_image "redis" "7-alpine"
    scan_image "prom/prometheus" "latest"
    scan_image "grafana/grafana" "latest"
    
    log_success "Scan des images d'infrastructure terminé"
}

# Génération du rapport de synthèse
generate_summary_report() {
    if [ "$GENERATE_REPORT" != "true" ]; then
        return
    fi
    
    log_info "Génération du rapport de synthèse..."
    
    local summary_file="$SCAN_RESULTS_DIR/security_scan_summary.md"
    
    cat > "$summary_file" << EOF
# 🔒 Rapport de Scan de Sécurité VIRIDA

**Date:** $(date)
**Généré par:** VIRIDA Docker Security Scan Script
**Format:** $REPORT_FORMAT

## 📊 Résumé des Vulnérabilités

### Images Scannées
EOF
    
    # Lister toutes les images scannées
    for result_file in "$SCAN_RESULTS_DIR"/*_scan."$REPORT_FORMAT"; do
        if [ -f "$result_file" ]; then
            local image_name=$(basename "$result_file" | sed 's/_scan\..*$//')
            echo "- $image_name" >> "$summary_file"
        fi
    done
    
    cat >> "$summary_file" << EOF

### Recommandations

1. **Vulnérabilités CRITICAL**: Mettre à jour immédiatement
2. **Vulnérabilités HIGH**: Planifier la mise à jour dans les 24h
3. **Vulnérabilités MEDIUM**: Planifier la mise à jour dans la semaine
4. **Vulnérabilités LOW**: Surveiller et mettre à jour lors des prochaines releases

### Actions Requises

- [ ] Analyser les vulnérabilités critiques
- [ ] Planifier les mises à jour de sécurité
- [ ] Mettre à jour les images de base
- [ ] Reconstruire les images avec les corrections
- [ ] Re-scanner pour validation

---

*Ce rapport a été généré automatiquement. Vérifiez toujours les résultats manuellement.*
EOF
    
    log_success "Rapport de synthèse généré: $summary_file"
}

# Nettoyage
cleanup() {
    log_info "Nettoyage..."
    
    # Supprimer le cache Trivy si demandé
    if [ "${CLEANUP_CACHE:-false}" = "true" ]; then
        rm -rf "$TRIVY_CACHE_DIR"
        log_info "Cache Trivy nettoyé"
    fi
    
    log_success "Nettoyage terminé"
}

# Affichage de l'aide
show_help() {
    echo "🔒 VIRIDA Docker Security Scan Script"
    echo ""
    echo "Usage: $0 [OPTIONS] [TARGET]"
    echo ""
    echo "TARGETS:"
    echo "  all              Scanner toutes les images (défaut)"
    echo "  frontend         Scanner les images frontend"
    echo "  backend          Scanner les images backend"
    echo "  ai-ml            Scanner les images AI/ML"
    echo "  infrastructure   Scanner les images d'infrastructure"
    echo ""
    echo "OPTIONS:"
    echo "  --type TYPE           Type de scan (vuln, config, secret)"
    echo "  --fail-on-critical    Échouer si vulnérabilités critiques détectées"
    echo "  --report              Générer un rapport de synthèse"
    echo "  --format FORMAT       Format du rapport (json, table, sarif)"
    echo "  --cleanup-cache       Nettoyer le cache Trivy après scan"
    echo "  -h, --help            Afficher cette aide"
    echo ""
    echo "EXEMPLES:"
    echo "  $0                                    # Scanner toutes les images"
    echo "  $0 frontend                           # Scanner les images frontend"
    echo "  $0 --type config --format json       # Scan de configuration en JSON"
    echo "  $0 --fail-on-critical --cleanup-cache # Scan strict avec nettoyage"
}

# Fonction principale
main() {
    local target="all"
    
    # Parsing des arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --type)
                SCAN_TYPE="$2"
                shift 2
                ;;
            --fail-on-critical)
                FAIL_ON_CRITICAL="true"
                shift
                ;;
            --report)
                GENERATE_REPORT="true"
                shift
                ;;
            --format)
                REPORT_FORMAT="$2"
                shift 2
                ;;
            --cleanup-cache)
                CLEANUP_CACHE="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            all|frontend|backend|ai-ml|infrastructure)
                target="$1"
                shift
                ;;
            *)
                log_error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Vérification des prérequis
    check_prerequisites
    
    # Configuration des répertoires
    setup_directories
    
    # Scan selon la cible
    case $target in
        all)
            scan_all_images
            ;;
        frontend)
            scan_frontend_images
            ;;
        backend)
            scan_backend_images
            ;;
        ai-ml)
            scan_ai_ml_images
            ;;
        infrastructure)
            scan_infrastructure_images
            ;;
        *)
            log_error "Cible inconnue: $target"
            exit 1
            ;;
    esac
    
    # Génération du rapport de synthèse
    generate_summary_report
    
    # Nettoyage
    cleanup
    
    log_success "Scan de sécurité terminé avec succès !"
    log_info "Résultats disponibles dans: $SCAN_RESULTS_DIR"
}

# Exécution du script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

