#!/bin/bash

echo "🔧 Configuration des variables d'environnement pour Gitea + Drone CI"
echo "=================================================================="

# Variables à configurer dans Clever Cloud
echo "📋 Variables à ajouter dans Clever Cloud (Settings > Environment variables):"
echo ""

echo "# Configuration Gitea"
echo "GITEA_PORT=3000"
echo "GITEA_DOMAIN=gitea-drone-ci.cleverapps.io"
echo "GITEA_CLIENT_ID=gitea-oauth-client-2024"
echo "GITEA_CLIENT_SECRET=gitea-oauth-secret-2024"
echo ""

echo "# Configuration Drone"
echo "DRONE_PORT=3001"
echo "DRONE_HOST=gitea-drone-ci.cleverapps.io"
echo "DRONE_SECRET=virida-super-secret-key-2024"
echo ""

echo "# Configuration des bases de données"
echo "GITEA_DB_TYPE=postgres"
echo "GITEA_DB_HOST=bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:50013"
echo "GITEA_DB_NAME=bjduvaldxkbwljy3uuel"
echo "GITEA_DB_USER=uncer3i7fyqs2zeult6r"
echo "GITEA_DB_PASS=WuobPl6Nyk9X0Z4DKF7BlxE55z2buu"
echo ""

echo "DRONE_DB_TYPE=postgres"
echo "DRONE_DB_HOST=bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:50013"
echo "DRONE_DB_NAME=bjduvaldxkbwljy3uuel"
echo "DRONE_DB_USER=uncer3i7fyqs2zeult6r"
echo "DRONE_DB_PASS=WuobPl6Nyk9X0Z4DKF7BlxE55z2buu"
echo ""

echo "# Configuration générale"
echo "DATA_DIR=/tmp/gitea-drone"
echo ""

echo "✅ Copiez-collez ces variables dans Clever Cloud"
echo "📍 Allez dans : Settings > Environment variables"
echo "➕ Cliquez sur 'Add an environment variable' pour chaque ligne"
