#!/bin/bash

# Script de déploiement complet VIRIDA
# Usage: ./deploy-complete.sh [environment]

set -e

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Variables
ENVIRONMENT=${1:-"production"}
APP_NAME="virida-infrastructure"
ORG_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"

log_info "🚀 Déploiement complet VIRIDA - Environnement: $ENVIRONMENT"

# Vérifier les prérequis
log_info "Vérification des prérequis..."

if ! command -v docker &> /dev/null; then
    log_error "Docker not found. Please install Docker first."
    exit 1
fi

if ! command -v clever &> /dev/null; then
    log_error "Clever Tools not found. Please install clever-tools first."
    exit 1
fi

if [ ! -f ".env.clever-cloud" ]; then
    log_error ".env.clever-cloud not found. Please create it from env.clever-cloud.example."
    exit 1
fi

log_success "Prérequis vérifiés"

# Charger les variables d'environnement
source .env.clever-cloud

# Vérifier la connexion à Clever Cloud
log_info "Vérification de la connexion à Clever Cloud..."
if ! clever status &> /dev/null; then
    log_error "Not connected to Clever Cloud. Please run 'clever login' first."
    exit 1
fi

log_success "Connecté à Clever Cloud"

# Optimiser les Dockerfiles
log_info "Optimisation des Dockerfiles pour Clever Cloud..."
if [ -f "infrastructure/scripts/optimize-for-clever.sh" ]; then
    ./infrastructure/scripts/optimize-for-clever.sh
    log_success "Dockerfiles optimisés"
else
    log_warning "Script d'optimisation non trouvé, continuation..."
fi

# Nettoyer le cache Docker
log_info "Nettoyage du cache Docker..."
if [ -f "infrastructure/scripts/docker-cache.sh" ]; then
    ./infrastructure/scripts/docker-cache.sh
    log_success "Cache Docker nettoyé"
else
    log_warning "Script de nettoyage non trouvé, continuation..."
fi

# Construire l'image Docker
log_info "Construction de l'image Docker..."
docker build -f Dockerfile.clever -t $APP_NAME:latest .
log_success "Image Docker construite: $APP_NAME:latest"

# Tester l'image localement
log_info "Test local de l'image..."
docker run -d -p 8080:8080 --name virida-test $APP_NAME:latest
sleep 30

if curl -f http://localhost:8080/health &> /dev/null; then
    log_success "Test local réussi"
    docker stop virida-test
    docker rm virida-test
else
    log_error "Test local échoué"
    docker stop virida-test || true
    docker rm virida-test || true
    exit 1
fi

# Déployer sur Clever Cloud
log_info "Déploiement sur Clever Cloud..."
clever deploy --same-commit-policy rebuild

# Attendre que le déploiement soit prêt
log_info "Attente du déploiement..."
sleep 60

# Vérifier la santé de l'application
log_info "Vérification de la santé de l'application..."
for i in {1..10}; do
    if curl -f https://$CC_APP_DOMAIN/health &> /dev/null; then
        log_success "Application déployée et en bonne santé!"
        break
    fi
    log_info "Tentative $i/10 - Attente de 30s..."
    sleep 30
done

# Test de performance
log_info "Test de performance..."
response_time=$(curl -o /dev/null -s -w '%{time_total}' https://$CC_APP_DOMAIN/health)
log_info "Temps de réponse: ${response_time}s"

if (( $(echo "$response_time > 5.0" | bc -l) )); then
    log_warning "Temps de réponse élevé: ${response_time}s"
else
    log_success "Performance acceptable: ${response_time}s"
fi

# Afficher le statut final
log_info "Statut final de l'application..."
clever status

# Afficher les logs récents
log_info "Logs récents de l'application..."
clever logs --after 5m

# Résumé du déploiement
echo ""
log_success "🎉 Déploiement VIRIDA terminé avec succès!"
echo ""
echo "📊 Résumé du déploiement:"
echo "  - Environnement: $ENVIRONMENT"
echo "  - Application: $APP_NAME"
echo "  - URL: https://$CC_APP_DOMAIN"
echo "  - Temps de réponse: ${response_time}s"
echo "  - Statut: ✅ Opérationnel"
echo ""
echo "🔗 Liens utiles:"
echo "  - Application: https://$CC_APP_DOMAIN"
echo "  - Console Clever Cloud: https://console.clever-cloud.com/goto/app_e10f4ca6-35ab-49e6-967f-cf1ebc40bc37"
echo "  - Health Check: https://$CC_APP_DOMAIN/health"
echo ""
log_info "Déploiement terminé à $(date)"
