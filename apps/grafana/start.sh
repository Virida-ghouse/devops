#!/bin/bash

# Script de démarrage pour Grafana sur Clever Cloud
echo "🚀 Démarrage de VIRIDA Grafana..."

# Télécharger et installer Grafana
wget -q https://dl.grafana.com/oss/release/grafana-10.2.0.linux-amd64.tar.gz
tar -xzf grafana-10.2.0.linux-amd64.tar.gz
cd grafana-10.2.0

# Créer les répertoires nécessaires
mkdir -p data logs plugins

# Configurer Grafana
cp ../grafana.conf conf/grafana.ini

# Configurer le port depuis l'environnement
export GF_SERVER_HTTP_PORT=${GF_SERVER_HTTP_PORT:-3000}
export GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD:-admin}

# Démarrer Grafana
echo "✅ Démarrage de Grafana sur le port $GF_SERVER_HTTP_PORT"
echo "🌐 URL: http://localhost:$GF_SERVER_HTTP_PORT"
echo "👤 Admin: admin / $GF_SECURITY_ADMIN_PASSWORD"

# Démarrer Grafana en arrière-plan
./bin/grafana-server --config=conf/grafana.ini --homepath=. --packaging=tar.bz2 &
GRAFANA_PID=$!

# Attendre que Grafana soit prêt
sleep 15

# Vérifier que Grafana fonctionne
if ps -p $GRAFANA_PID > /dev/null; then
    echo "✅ Grafana démarré avec succès (PID: $GRAFANA_PID)"
    echo "🌐 URL: http://localhost:$GF_SERVER_HTTP_PORT"
    echo "👤 Admin: admin / $GF_SECURITY_ADMIN_PASSWORD"
    
    # Garder le processus actif
    wait $GRAFANA_PID
else
    echo "❌ Erreur: Grafana n'a pas pu démarrer"
    exit 1
fi
