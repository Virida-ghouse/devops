#!/bin/bash

# 🚀 Script de déploiement VIRIDA sur Clever Cloud
# Usage: ./scripts/deploy-to-clever-cloud.sh

set -e

echo "🚀 Déploiement VIRIDA sur Clever Cloud"
echo "======================================"
echo ""

# Vérification de la connexion Clever Cloud
echo "🔐 Vérification de la connexion Clever Cloud..."
if ! clever status >/dev/null 2>&1; then
    echo "❌ Erreur de connexion Clever Cloud. Vérifiez votre authentification."
    exit 1
fi

echo "✅ Connexion Clever Cloud OK"
echo ""

# Services à déployer
SERVICES=(
    "virida-3d-visualizer:Dockerfile.clever-3d"
    "virida-api-gateway:Dockerfile.clever-api"
    "virida-ai-prediction:Dockerfile.clever-ai"
)

# Fonction pour déployer un service
deploy_service() {
    local service_name=$1
    local dockerfile=$2
    
    echo "📦 Déploiement de $service_name..."
    
    # Sélectionner l'application
    clever link $service_name
    
    # Copier le Dockerfile approprié
    cp $dockerfile Dockerfile
    
    # Déployer
    echo "⬆️  Déploiement en cours..."
    clever deploy --force
    
    # Vérifier le statut
    echo "🔍 Vérification du déploiement..."
    sleep 10
    clever status
    
    echo "✅ $service_name déployé avec succès"
    echo ""
}

# Déployer tous les services
for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r service_name dockerfile <<< "$service_info"
    deploy_service "$service_name" "$dockerfile"
done

echo "🎉 Tous les services VIRIDA ont été déployés sur Clever Cloud !"
echo ""
echo "📋 URLs des services :"
echo "  • Frontend 3D: https://virida-3d-visualizer.cleverapps.io"
echo "  • API Gateway: https://virida-api-gateway.cleverapps.io"
echo "  • AI/ML Engine: https://virida-ai-prediction.cleverapps.io"
echo ""
echo "🔗 Console Clever Cloud: https://console.clever-cloud.com"
echo ""
echo "🔍 Surveillez les déploiements:"
echo "  clever logs --follow"
echo "  clever status"
