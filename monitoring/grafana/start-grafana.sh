#!/bin/bash

# Script de démarrage Grafana pour Clever Cloud
echo "🚀 Démarrage de Grafana..."

# Configuration du port
export PORT=${PORT:-8080}
export GF_SERVER_HTTP_PORT=${PORT}

# Configuration de la base de données
export GF_DATABASE_TYPE=sqlite3
export GF_DATABASE_PATH=/tmp/grafana.db

# Configuration de l'authentification
export GF_SECURITY_ADMIN_USER=admin
export GF_SECURITY_ADMIN_PASSWORD=admin

# Configuration des logs
export GF_LOG_LEVEL=info

# Démarrer Grafana
echo "🌐 Grafana démarré sur le port $PORT"
echo "👤 Admin: admin / admin"

exec grafana-server --config=/etc/grafana/grafana.ini
