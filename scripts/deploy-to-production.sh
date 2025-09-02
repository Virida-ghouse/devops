#!/bin/bash

# 🚀 Script de déploiement VIRIDA en production
# Usage: ./scripts/deploy-to-production.sh [dockerhub-username]

set -e

# Configuration
DOCKER_USERNAME=${1:-"votre-username"}
REGISTRY_TYPE=${2:-"dockerhub"}  # dockerhub ou gitea

echo "🚀 Déploiement VIRIDA en production"
echo "👤 Username: $DOCKER_USERNAME"
echo "📦 Registry: $REGISTRY_TYPE"
echo ""

# Fonction pour mettre à jour les manifests
update_manifests() {
    local username=$1
    local registry_type=$2
    
    echo "📝 Mise à jour des manifests Kubernetes..."
    
    if [ "$registry_type" = "dockerhub" ]; then
        # Docker Hub
        find k8s/production -name "*.yaml" -exec sed -i '' "s/votre-username/$username/g" {} \;
        echo "✅ Manifests mis à jour pour Docker Hub: $username"
    elif [ "$registry_type" = "gitea" ]; then
        # Gitea Registry
        find k8s/production -name "*.yaml" -exec sed -i '' "s|votre-username/virida-|gitea.cleverapps.io/virida/virida-|g" {} \;
        echo "✅ Manifests mis à jour pour Gitea Registry"
    fi
}

# Fonction pour pousser les images
push_images() {
    local username=$1
    local registry_type=$2
    
    echo "📦 Poussée des images vers le registry..."
    
    if [ "$registry_type" = "dockerhub" ]; then
        ./scripts/push-to-dockerhub.sh "$username"
    elif [ "$registry_type" = "gitea" ]; then
        ./scripts/push-to-gitea.sh
    fi
}

# Fonction pour déployer via GitOps
deploy_gitops() {
    echo "🔄 Déploiement via GitOps..."
    
    # Commit et push des changements
    git add k8s/production/
    git commit -m "🚀 Deploy VIRIDA v1.0.0 to production

- Updated image URLs for production registry
- Configured production-ready manifests
- Added resource limits and security contexts
- Enabled TLS with Let's Encrypt
- Configured ArgoCD for automated deployment

Services:
- Frontend 3D Visualizer: 3d.virida.com
- Backend API Gateway: api.virida.com  
- AI/ML Prediction Engine: ai.virida.com
- Monitoring: Grafana + Prometheus

Registry: $REGISTRY_TYPE
Version: v1.0.0"
    
    git push origin main
    
    echo "✅ Changements poussés vers Git"
    echo "🔄 ArgoCD va automatiquement déployer en production"
}

# Fonction pour vérifier le déploiement
check_deployment() {
    echo "🔍 Vérification du déploiement..."
    
    # Attendre que ArgoCD synchronise
    echo "⏳ Attente de la synchronisation ArgoCD (30s)..."
    sleep 30
    
    # Vérifier les applications ArgoCD
    echo "📊 Statut des applications ArgoCD:"
    kubectl get applications -n argocd | grep virida-production || echo "Applications en cours de création..."
    
    # Vérifier les pods
    echo "🐳 Statut des pods VIRIDA:"
    kubectl get pods -n virida || echo "Namespace virida en cours de création..."
}

# Menu principal
echo "🎯 Options de déploiement:"
echo "1. Docker Hub (recommandé)"
echo "2. Gitea Container Registry"
echo "3. Mise à jour des manifests seulement"
echo "4. Déploiement GitOps seulement"
echo ""

read -p "Choisissez une option (1-4): " choice

case $choice in
    1)
        echo "🐳 Déploiement via Docker Hub"
        read -p "Entrez votre username Docker Hub: " dockerhub_username
        update_manifests "$dockerhub_username" "dockerhub"
        push_images "$dockerhub_username" "dockerhub"
        deploy_gitops
        check_deployment
        ;;
    2)
        echo "🏗️ Déploiement via Gitea Registry"
        update_manifests "virida" "gitea"
        push_images "virida" "gitea"
        deploy_gitops
        check_deployment
        ;;
    3)
        echo "📝 Mise à jour des manifests seulement"
        read -p "Entrez votre username registry: " username
        read -p "Type de registry (dockerhub/gitea): " registry_type
        update_manifests "$username" "$registry_type"
        echo "✅ Manifests mis à jour. Poussez manuellement vers Git."
        ;;
    4)
        echo "🔄 Déploiement GitOps seulement"
        deploy_gitops
        check_deployment
        ;;
    *)
        echo "❌ Option invalide"
        exit 1
        ;;
esac

echo ""
echo "🎉 Déploiement VIRIDA en production terminé !"
echo ""
echo "📋 URLs de production:"
echo "  • Frontend 3D: https://3d.virida.com"
echo "  • API Gateway: https://api.virida.com"
echo "  • AI/ML Engine: https://ai.virida.com"
echo "  • ArgoCD: https://argocd.cleverapps.io"
echo ""
echo "🔍 Surveillez le déploiement:"
echo "  kubectl get applications -n argocd"
echo "  kubectl get pods -n virida"
