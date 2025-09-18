#!/bin/bash

echo "🚀 Déploiement rapide VIRIDA Gitea + Drone CI"
echo "=============================================="

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "main.go" ]; then
    echo "❌ Erreur: main.go non trouvé. Exécutez ce script depuis le répertoire apps/gitea-drone-ci"
    exit 1
fi

# Demander l'URL de déploiement
echo "📋 Entrez l'URL de déploiement Clever Cloud :"
echo "   (Format: https://push-n3-par-clevercloud-customers.services.clever-cloud.com/app_XXXXXXXX.git)"
read -p "URL: " DEPLOY_URL

if [ -z "$DEPLOY_URL" ]; then
    echo "❌ URL de déploiement requise"
    exit 1
fi

# Configurer le remote
echo "🔧 Configuration du remote Git..."
git remote add gitea-drone-ci "$DEPLOY_URL"

# Vérifier la configuration
echo "📊 Vérification de la configuration..."
git remote -v | grep gitea-drone-ci

# Déployer
echo "📤 Déploiement de l'application..."
git push gitea-drone-ci staging

echo "✅ Déploiement terminé !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Configurez les variables d'environnement dans Clever Cloud"
echo "2. Attendez 2-3 minutes que l'application démarre"
echo "3. Accédez à https://gitea-drone-ci.cleverapps.io:3000"
echo "4. Créez un compte admin dans Gitea"
echo "5. Configurez OAuth pour Drone CI"
echo ""
echo "🔧 Variables à configurer :"
echo "   Exécutez: ./setup-variables.sh"

