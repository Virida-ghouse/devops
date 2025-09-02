#!/bin/bash

# 🏗️ Script pour pousser les images VIRIDA vers Gitea Container Registry
# Usage: ./scripts/push-to-gitea.sh

set -e

# Configuration Gitea
GITEA_HOST="gitea.cleverapps.io"
GITEA_USERNAME="virida"
REGISTRY="${GITEA_HOST}"
VERSION="latest"

echo "🏗️ Poussée des images VIRIDA vers Gitea Container Registry"
echo "🌐 Host: $GITEA_HOST"
echo "👤 Username: $GITEA_USERNAME"
echo "📦 Registry: $REGISTRY"
echo "🏷️  Version: $VERSION"
echo ""

# Vérification de la connexion
echo "🔐 Vérification de la connexion Gitea..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker n'est pas démarré"
    exit 1
fi

# Login Gitea Container Registry
echo "🔑 Connexion à Gitea Container Registry..."
echo "💡 Entrez vos identifiants Gitea (username: $GITEA_USERNAME)"
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
    
    # Tag pour Gitea Registry
    docker tag "${image}:latest" "${REGISTRY}/${GITEA_USERNAME}/${image}:${VERSION}"
    docker tag "${image}:latest" "${REGISTRY}/${GITEA_USERNAME}/${image}:v1.0.0"
    
    # Push vers Gitea Registry
    echo "⬆️  Poussée de ${REGISTRY}/${GITEA_USERNAME}/${image}:${VERSION}"
    docker push "${REGISTRY}/${GITEA_USERNAME}/${image}:${VERSION}"
    
    echo "⬆️  Poussée de ${REGISTRY}/${GITEA_USERNAME}/${image}:v1.0.0"
    docker push "${REGISTRY}/${GITEA_USERNAME}/${image}:v1.0.0"
    
    echo "✅ $image poussée avec succès"
done

echo ""
echo "🎉 Toutes les images VIRIDA ont été poussées vers Gitea !"
echo ""
echo "📋 URLs des images :"
for image in "${IMAGES[@]}"; do
    echo "  • ${REGISTRY}/${GITEA_USERNAME}/${image}:${VERSION}"
    echo "  • ${REGISTRY}/${GITEA_USERNAME}/${image}:v1.0.0"
done
echo ""
echo "🔗 Registry: https://${GITEA_HOST}/user/package/docker"
