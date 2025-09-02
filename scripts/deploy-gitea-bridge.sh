#!/bin/bash
set -euo pipefail

echo "🔗 Déploiement du Gitea-Virida Bridge"
echo "====================================="

# Configuration
ORG_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"
APP_NAME="gitea-virida-bridge"
DOCKER_USERNAME="crkdocker1"

# Vérifier la connexion Clever Cloud
echo "🔐 Vérification de la connexion Clever Cloud..."
if ! clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET" > /dev/null 2>&1; then
    echo "❌ Erreur de connexion Clever Cloud. Veuillez vous connecter."
    exit 1
fi
echo "✅ Connecté à Clever Cloud."

# Créer l'application si elle n'existe pas
echo "📦 Vérification de l'application $APP_NAME..."
if ! clever applications show "$APP_NAME" > /dev/null 2>&1; then
    echo "🆕 Création de l'application $APP_NAME..."
    clever create --type docker --org "$ORG_ID" "$APP_NAME"
    echo "✅ Application créée."
else
    echo "✅ Application existante trouvée."
fi

# Récupérer l'ID de l'application
APP_ID=$(clever applications show "$APP_NAME" --json | jq -r '.[0].id')
echo "🆔 ID de l'application: $APP_ID"

# Configurer les variables d'environnement
echo "⚙️ Configuration des variables d'environnement..."
clever env set NODE_ENV production --app "$APP_ID"
clever env set PORT 3001 --app "$APP_ID"
clever env set GITEA_URL "https://gitea.cleverapps.io" --app "$APP_ID"

# Demander le token Gitea
echo "🔑 Configuration du token Gitea..."
read -p "Veuillez entrer votre token Gitea (ou appuyez sur Entrée pour utiliser un token par défaut): " GITEA_TOKEN
if [ -z "$GITEA_TOKEN" ]; then
    GITEA_TOKEN="your-gitea-token-here"
    echo "⚠️ Utilisation d'un token par défaut. Veuillez le configurer manuellement."
fi
clever env set GITEA_TOKEN "$GITEA_TOKEN" --app "$APP_ID"

# Configurer les variables de base de données si disponibles
if [ -n "${CC_POSTGRESQL_ADDON_HOST:-}" ]; then
    echo "🗄️ Configuration des variables de base de données..."
    clever env set CC_POSTGRESQL_ADDON_HOST "$CC_POSTGRESQL_ADDON_HOST" --app "$APP_ID"
    clever env set CC_POSTGRESQL_ADDON_DB "$CC_POSTGRESQL_ADDON_DB" --app "$APP_ID"
    clever env set CC_POSTGRESQL_ADDON_USER "$CC_POSTGRESQL_ADDON_USER" --app "$APP_ID"
    clever env set CC_POSTGRESQL_ADDON_PASSWORD "$CC_POSTGRESQL_ADDON_PASSWORD" --app "$APP_ID"
    echo "✅ Variables de base de données configurées."
fi

echo "✅ Variables d'environnement configurées."

# Construire et pousser l'image Docker
echo "🐳 Construction et push de l'image Docker..."
cd gitea-virida-bridge

# Construire l'image
docker build -t "$DOCKER_USERNAME/gitea-virida-bridge:latest" .
docker tag "$DOCKER_USERNAME/gitea-virida-bridge:latest" "$DOCKER_USERNAME/gitea-virida-bridge:v1.0.0"

# Pousser vers Docker Hub
docker push "$DOCKER_USERNAME/gitea-virida-bridge:latest"
docker push "$DOCKER_USERNAME/gitea-virida-bridge:v1.0.0"

echo "✅ Image Docker poussée vers Docker Hub."

# Mettre à jour le Dockerfile.clever pour utiliser l'image Docker Hub
echo "📝 Mise à jour du Dockerfile.clever..."
cat > Dockerfile.clever << EOF
FROM $DOCKER_USERNAME/gitea-virida-bridge:v1.0.0
LABEL clevercloud.region="par"
EXPOSE 3001
CMD ["npm", "start"]
EOF

# Déployer l'application
echo "🚀 Déploiement de l'application..."
clever deploy --alias "$APP_NAME"

echo "✅ Déploiement terminé !"
echo ""
echo "🌐 URLs d'accès :"
echo "   - Application: https://app-$(echo $APP_ID | tr '[:upper:]' '[:lower:]').cleverapps.io/"
echo "   - Health Check: https://app-$(echo $APP_ID | tr '[:upper:]' '[:lower:]').cleverapps.io/health"
echo "   - API Documentation: https://app-$(echo $APP_ID | tr '[:upper:]' '[:lower:]').cleverapps.io/"
echo ""
echo "🔗 Intégration avec virida_ihm :"
echo "   1. Ajoutez le composant GiteaIntegration.jsx à votre application virida_ihm"
echo "   2. Configurez REACT_APP_GITEA_BRIDGE_URL dans virida_ihm"
echo "   3. Les données Gitea seront automatiquement synchronisées"
echo ""
echo "📊 Fonctionnalités disponibles :"
echo "   - Informations du dépôt VIRIDA"
echo "   - Commits récents et statistiques"
echo "   - Branches et issues"
echo "   - Synchronisation des données environnementales"
echo ""
echo "🎉 Gitea-Virida Bridge déployé avec succès !"
