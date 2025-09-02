#!/bin/bash

# 🐳 Script interactif pour déployer VIRIDA sur Docker Hub
# Usage: ./scripts/deploy-to-dockerhub-interactive.sh

set -e

echo "🚀 Déploiement VIRIDA sur Docker Hub"
echo "======================================"
echo ""

# Demander le username Docker Hub
read -p "👤 Entrez votre username Docker Hub: " DOCKER_USERNAME

if [ -z "$DOCKER_USERNAME" ]; then
    echo "❌ Username requis !"
    exit 1
fi

echo ""
echo "🔐 Vérification de la connexion Docker Hub..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker n'est pas démarré"
    exit 1
fi

# Vérifier la connexion
echo "🔑 Test de connexion avec $DOCKER_USERNAME..."
docker tag virida-3d-visualizer:latest $DOCKER_USERNAME/test-connection:latest
if docker push $DOCKER_USERNAME/test-connection:latest >/dev/null 2>&1; then
    echo "✅ Connexion Docker Hub réussie !"
    docker rmi $DOCKER_USERNAME/test-connection:latest >/dev/null 2>&1
else
    echo "❌ Erreur de connexion. Vérifiez votre username et votre connexion."
    exit 1
fi

echo ""
echo "📦 Images VIRIDA à pousser :"
echo "  • virida-3d-visualizer:latest"
echo "  • virida-api-gateway:latest"
echo "  • virida-ai-prediction:latest"
echo ""

read -p "🚀 Continuer le déploiement ? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ Déploiement annulé"
    exit 0
fi

echo ""
echo "🔄 Déploiement en cours..."

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
    docker tag "${image}:latest" "${DOCKER_USERNAME}/${image}:latest"
    docker tag "${image}:latest" "${DOCKER_USERNAME}/${image}:v1.0.0"
    
    # Push vers Docker Hub
    echo "⬆️  Poussée de ${DOCKER_USERNAME}/${image}:latest"
    docker push "${DOCKER_USERNAME}/${image}:latest"
    
    echo "⬆️  Poussée de ${DOCKER_USERNAME}/${image}:v1.0.0"
    docker push "${DOCKER_USERNAME}/${image}:v1.0.0"
    
    echo "✅ $image poussée avec succès"
done

echo ""
echo "🎉 Toutes les images VIRIDA ont été poussées vers Docker Hub !"
echo ""
echo "📋 URLs des images :"
for image in "${IMAGES[@]}"; do
    echo "  • ${DOCKER_USERNAME}/${image}:latest"
    echo "  • ${DOCKER_USERNAME}/${image}:v1.0.0"
done
echo ""
echo "🔗 Registry: https://hub.docker.com/u/$DOCKER_USERNAME"

# Mettre à jour les manifests
echo ""
echo "📝 Mise à jour des manifests Kubernetes..."
find k8s/production -name "*.yaml" -exec sed -i '' "s/votre-username/$DOCKER_USERNAME/g" {} \;
echo "✅ Manifests mis à jour avec $DOCKER_USERNAME"

echo ""
echo "🚀 Prêt pour le déploiement GitOps !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. git add k8s/production/"
echo "2. git commit -m '🚀 Deploy VIRIDA v1.0.0 to production'"
echo "3. git push origin main"
echo "4. ArgoCD déploiera automatiquement !"
echo ""
echo "🌐 URLs de production :"
echo "  • Frontend 3D: https://3d.virida.com"
echo "  • API Gateway: https://api.virida.com"
echo "  • AI/ML Engine: https://ai.virida.com"
