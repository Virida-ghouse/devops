#!/bin/bash

# Script de démarrage pour Grafana sur Clever Cloud
echo "🚀 Démarrage de VIRIDA Grafana..."

# Installer Grafana
apt-get update
apt-get install -y wget
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install -y grafana

# Configurer Grafana
cp grafana.conf /etc/grafana/grafana.ini

# Démarrer Grafana
systemctl start grafana-server
systemctl enable grafana-server

# Attendre que Grafana soit prêt
sleep 10

echo "✅ Grafana démarré sur le port 3000"
echo "🌐 URL: http://localhost:3000"
echo "👤 Admin: admin / admin"

# Garder le processus actif
tail -f /var/log/grafana/grafana.log
