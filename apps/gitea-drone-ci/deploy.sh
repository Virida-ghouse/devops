#!/bin/bash

echo "🚀 Déploiement de VIRIDA Gitea + Drone CI"
echo "=========================================="

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "main.go" ]; then
    echo "❌ Erreur: main.go non trouvé. Exécutez ce script depuis le répertoire apps/gitea-drone-ci"
    exit 1
fi

# Vérifier que git est configuré
if ! git config user.name > /dev/null 2>&1; then
    echo "⚠️  Configuration Git manquante. Configuration automatique..."
    git config user.name "VIRIDA Deploy"
    git config user.email "deploy@virida.com"
fi

# Ajouter et commiter les changements
echo "📝 Ajout des changements..."
git add .

echo "💾 Commit des changements..."
git commit -m "Deploy VIRIDA Gitea + Drone CI - $(date)"

# Pousser vers le remote
echo "📤 Push vers Clever Cloud..."
git push origin staging

echo "✅ Déploiement terminé !"
echo ""
echo "📊 URLs d'accès :"
echo "- Application: https://gitea-drone-ci.cleverapps.io"
echo "- Gitea: https://gitea-drone-ci.cleverapps.io:3000"
echo "- Drone CI: https://gitea-drone-ci.cleverapps.io:3001"
echo ""
echo "🔧 Configuration OAuth nécessaire :"
echo "1. Accédez à Gitea et créez une application OAuth"
echo "2. Configurez les variables d'environnement dans Clever Cloud"
echo ""
echo "📋 Variables à configurer :"
echo "- GITEA_CLIENT_ID"
echo "- GITEA_CLIENT_SECRET"
echo "- DRONE_SECRET"
