#!/bin/bash

# Script de génération du PDF d'analyse comparative CI/CD
# Usage: ./generate-pdf-analysis.sh

set -e

echo "📄 Génération du PDF d'analyse comparative CI/CD VIRIDA"
echo "======================================================"

# Variables
INPUT_FILE="ANALYSE-COMPARATIVE-CI-CD-VIRIDA.md"
OUTPUT_FILE="ANALYSE-COMPARATIVE-CI-CD-VIRIDA.pdf"
TEMP_HTML="temp_analysis.html"

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
    
    # Vérifier pandoc
    if ! command -v pandoc &> /dev/null; then
        log_error "pandoc n'est pas installé. Installez-le d'abord :"
        echo "  Ubuntu/Debian: sudo apt-get install pandoc"
        echo "  macOS: brew install pandoc"
        echo "  Windows: choco install pandoc"
        exit 1
    fi
    
    # Vérifier wkhtmltopdf
    if ! command -v wkhtmltopdf &> /dev/null; then
        log_warn "wkhtmltopdf n'est pas installé. Installation alternative avec pandoc..."
        USE_PANDOC_PDF=true
    else
        USE_PANDOC_PDF=false
    fi
    
    # Vérifier le fichier source
    if [ ! -f "$INPUT_FILE" ]; then
        log_error "Fichier source $INPUT_FILE non trouvé"
        exit 1
    fi
    
    log_info "Prérequis OK ✓"
}

# Générer le PDF avec pandoc
generate_pdf_pandoc() {
    log_info "Génération du PDF avec pandoc..."
    
    pandoc "$INPUT_FILE" \
        --pdf-engine=wkhtmltopdf \
        --css=<(cat << 'EOF'
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 5px;
        }
        h3 {
            color: #7f8c8d;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #3498db;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .score-high {
            background-color: #d4edda;
            color: #155724;
            font-weight: bold;
        }
        .score-medium {
            background-color: #fff3cd;
            color: #856404;
            font-weight: bold;
        }
        .score-low {
            background-color: #f8d7da;
            color: #721c24;
            font-weight: bold;
        }
        code {
            background-color: #f4f4f4;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
        }
        pre {
            background-color: #f4f4f4;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        blockquote {
            border-left: 4px solid #3498db;
            margin: 0;
            padding-left: 20px;
            color: #7f8c8d;
        }
        .toc {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .highlight {
            background-color: #fff3cd;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #ffc107;
        }
        .success {
            background-color: #d4edda;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #28a745;
        }
        .warning {
            background-color: #fff3cd;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #ffc107;
        }
        .error {
            background-color: #f8d7da;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #dc3545;
        }
        EOF
        ) \
        --toc \
        --toc-depth=3 \
        --number-sections \
        --highlight-style=github \
        --metadata title="Analyse Comparative des Solutions CI/CD pour VIRIDA" \
        --metadata author="Équipe DevOps VIRIDA" \
        --metadata date="$(date '+%d %B %Y')" \
        -o "$OUTPUT_FILE"
    
    log_info "PDF généré avec succès ✓"
}

# Générer le PDF avec wkhtmltopdf
generate_pdf_wkhtmltopdf() {
    log_info "Génération du PDF avec wkhtmltopdf..."
    
    # Convertir Markdown en HTML
    pandoc "$INPUT_FILE" \
        --standalone \
        --css=<(cat << 'EOF'
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 5px;
        }
        h3 {
            color: #7f8c8d;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #3498db;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .score-high {
            background-color: #d4edda;
            color: #155724;
            font-weight: bold;
        }
        .score-medium {
            background-color: #fff3cd;
            color: #856404;
            font-weight: bold;
        }
        .score-low {
            background-color: #f8d7da;
            color: #721c24;
            font-weight: bold;
        }
        code {
            background-color: #f4f4f4;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
        }
        pre {
            background-color: #f4f4f4;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        blockquote {
            border-left: 4px solid #3498db;
            margin: 0;
            padding-left: 20px;
            color: #7f8c8d;
        }
        .toc {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .highlight {
            background-color: #fff3cd;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #ffc107;
        }
        .success {
            background-color: #d4edda;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #28a745;
        }
        .warning {
            background-color: #fff3cd;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #ffc107;
        }
        .error {
            background-color: #f8d7da;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #dc3545;
        }
        EOF
        ) \
        --toc \
        --toc-depth=3 \
        --number-sections \
        --highlight-style=github \
        --metadata title="Analyse Comparative des Solutions CI/CD pour VIRIDA" \
        --metadata author="Équipe DevOps VIRIDA" \
        --metadata date="$(date '+%d %B %Y')" \
        -o "$TEMP_HTML"
    
    # Convertir HTML en PDF
    wkhtmltopdf \
        --page-size A4 \
        --margin-top 20mm \
        --margin-right 15mm \
        --margin-bottom 20mm \
        --margin-left 15mm \
        --encoding UTF-8 \
        --enable-local-file-access \
        --print-media-type \
        --no-stop-slow-scripts \
        --javascript-delay 2000 \
        "$TEMP_HTML" \
        "$OUTPUT_FILE"
    
    # Nettoyer le fichier temporaire
    rm -f "$TEMP_HTML"
    
    log_info "PDF généré avec succès ✓"
}

# Vérifier le PDF généré
verify_pdf() {
    log_info "Vérification du PDF généré..."
    
    if [ -f "$OUTPUT_FILE" ]; then
        FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
        log_info "PDF généré : $OUTPUT_FILE ($FILE_SIZE)"
        
        # Vérifier que le PDF n'est pas vide
        if [ -s "$OUTPUT_FILE" ]; then
            log_info "PDF valide ✓"
        else
            log_error "PDF vide ou corrompu"
            exit 1
        fi
    else
        log_error "PDF non généré"
        exit 1
    fi
}

# Afficher les informations
show_info() {
    echo ""
    log_info "PDF d'analyse comparative généré avec succès ! 🎉"
    echo ""
    echo "Fichier généré : $OUTPUT_FILE"
    echo "Taille : $(du -h "$OUTPUT_FILE" | cut -f1)"
    echo ""
    echo "Le PDF contient :"
    echo "  - Analyse comparative de 7 solutions CI/CD"
    echo "  - Justification détaillée du choix Gitea Actions"
    echo "  - Métriques de performance et ROI"
    echo "  - Plan de migration et formation"
    echo ""
    echo "Vous pouvez maintenant :"
    echo "  - Ouvrir le PDF : open $OUTPUT_FILE"
    echo "  - Partager avec l'équipe"
    echo "  - Utiliser pour la présentation"
    echo ""
}

# Fonction principale
main() {
    echo ""
    log_info "Début de la génération du PDF d'analyse"
    echo ""
    
    check_prerequisites
    
    if [ "$USE_PANDOC_PDF" = true ]; then
        generate_pdf_pandoc
    else
        generate_pdf_wkhtmltopdf
    fi
    
    verify_pdf
    show_info
}

# Exécuter le script
main "$@"
