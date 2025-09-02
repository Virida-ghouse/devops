#!/bin/bash

# 🐳 Script pour pousser les images VIRIDA vers Docker Hub
# Usage: ./scripts/push-to-dockerhub.sh [votre-username-dockerhub]

set -e

# Configuration
DOCKER_USERNAME=${1:-"votre-username"}
REGISTRY="docker.io"
VERSION="latest"

echo "🚀 Poussée des images VIRIDA vers Docker Hub"
echo "👤 Username: $DOCKER_USERNAME"
echo "📦 Registry: $REGISTRY"
echo "🏷️  Version: $VERSION"
echo ""

# Vérification de la connexion Docker Hub
echo "🔐 Vérification de la connexion Docker Hub..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker n'est pas démarré"
    exit 1
fi

# Login Docker Hub (si nécessaire)
echo "🔑 Connexion à Docker Hub..."
echo "💡 Si vous n'êtes pas connecté, entrez vos identifiants Docker Hub"
docker login $REGISTRY

# Images à pousser
IMAGES=(
    "virida-3d-visualizer"
    "virida-api-gateway" 
    "virida-ai-prediction"
)

# Tag et push des images
for image in "${IMAGES[@]}"; do
    echo ""
    echo "📦 Traitement de $image..."
    
    # Tag pour Docker Hub
    docker tag "${image}:latest" "${DOCKER_USERNAME}/${image}:${VERSION}"
    docker tag "${image}:latest" "${DOCKER_USERNAME}/${image}:v1.0.0"
    
    # Push vers Docker Hub
    echo "⬆️  Poussée de ${DOCKER_USERNAME}/${image}:${VERSION}"
    docker push "${DOCKER_USERNAME}/${image}:${VERSION}"
    
    echo "⬆️  Poussée de ${DOCKER_USERNAME}/${image}:v1.0.0"
    docker push "${DOCKER_USERNAME}/${image}:v1.0.0"
    
    echo "✅ $image poussée avec succès"
done

echo ""
echo "🎉 Toutes les images VIRIDA ont été poussées vers Docker Hub !"
echo ""
echo "📋 URLs des images :"
for image in "${IMAGES[@]}"; do
    echo "  • ${DOCKER_USERNAME}/${image}:${VERSION}"
    echo "  • ${DOCKER_USERNAME}/${image}:v1.0.0"
done
echo ""
echo "🔗 Registry: https://hub.docker.com/u/$DOCKER_USERNAME"
