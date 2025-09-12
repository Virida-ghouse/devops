#!/bin/bash

# VIRIDA Gitea + Drone CI Setup Script
# Ce script configure l'environnement pour l'application

set -e

echo "🚀 Configuration de VIRIDA Gitea + Drone CI..."

# Variables
DATA_DIR=${DATA_DIR:-"/tmp/gitea-drone"}
GITEA_PORT=${GITEA_PORT:-"3000"}
DRONE_PORT=${DRONE_PORT:-"3001"}

# Créer les répertoires nécessaires
echo "📁 Création des répertoires..."
mkdir -p "$DATA_DIR"/{gitea/{data,config},drone/data}

# Installer les dépendances système
echo "📦 Installation des dépendances..."
apt-get update
apt-get install -y wget tar sqlite3

# Télécharger et installer Gitea
echo "🔧 Installation de Gitea..."
if [ ! -f "$DATA_DIR/gitea/gitea" ]; then
    wget -O /tmp/gitea.tar.gz "https://dl.gitea.io/gitea/1.21.0/gitea-1.21.0-linux-amd64"
    tar -xzf /tmp/gitea.tar.gz -C /tmp/
    mv /tmp/gitea "$DATA_DIR/gitea/gitea"
    chmod +x "$DATA_DIR/gitea/gitea"
    rm /tmp/gitea.tar.gz
fi

# Télécharger et installer Drone
echo "🔧 Installation de Drone CI..."
if [ ! -f "$DATA_DIR/drone/drone-server" ]; then
    # Drone Server
    wget -O /tmp/drone-server.tar.gz "https://github.com/harness/drone/releases/download/v2.20.0/drone_linux_amd64.tar.gz"
    tar -xzf /tmp/drone-server.tar.gz -C /tmp/
    mv /tmp/drone "$DATA_DIR/drone/drone-server"
    chmod +x "$DATA_DIR/drone/drone-server"
    rm /tmp/drone-server.tar.gz

    # Drone Runner
    wget -O /tmp/drone-runner.tar.gz "https://github.com/harness/drone/releases/download/v2.20.0/drone-runner-docker_linux_amd64.tar.gz"
    tar -xzf /tmp/drone-runner.tar.gz -C /tmp/
    mv /tmp/drone-runner-docker "$DATA_DIR/drone/drone-runner"
    chmod +x "$DATA_DIR/drone/drone-runner"
    rm /tmp/drone-runner.tar.gz
fi

# Configurer les permissions
echo "🔐 Configuration des permissions..."
chown -R 1000:1000 "$DATA_DIR"
chmod -R 755 "$DATA_DIR"

echo "✅ Configuration terminée !"
echo "📊 Répertoire de données: $DATA_DIR"
echo "🌐 Gitea sera disponible sur le port: $GITEA_PORT"
echo "🚀 Drone CI sera disponible sur le port: $DRONE_PORT"
