# Dockerfile pour Gitea Runner VIRIDA
FROM ubuntu:22.04

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive
ENV ACT_RUNNER_VERSION=0.2.13
ENV GITEA_INSTANCE_URL=""
ENV RUNNER_NAME="virida-runner"
ENV RUNNER_LABELS="ubuntu-latest:docker://node:18,ubuntu-latest:docker://python:3.11,ubuntu-latest:docker://golang:1.21"
ENV RUNNER_WORK_DIR="/tmp/act_runner/workspace"

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    docker.io \
    docker-compose \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Installer Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Installer Python (utilisé pour le healthcheck et certains jobs)
# Note: sur Ubuntu, le paquet s'appelle python3-pip (pas python3.11-pip)
RUN apt-get update \
    && apt-get install -y python3 python3-pip python3-venv python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Installer Go (utile pour certains workflows)
RUN apt-get update \
    && apt-get install -y golang-go \
    && rm -rf /var/lib/apt/lists/*

# Note: Clever Tools CLI is not required inside the runner container.


# Créer un utilisateur pour le runner
RUN useradd -m -s /bin/bash runner \
    && usermod -aG docker runner

# Créer le répertoire de travail
WORKDIR /opt/gitea-runner
RUN chown -R runner:runner /opt/gitea-runner

# Télécharger et installer act_runner
# NOTE: Les releases act_runner ne fournissent pas (toujours) de .tar.gz ; l'asset est souvent un binaire direct.
RUN set -eux; \
    url="https://gitea.com/gitea/act_runner/releases/download/v${ACT_RUNNER_VERSION}/act_runner-${ACT_RUNNER_VERSION}-linux-amd64"; \
    curl -fsSL "$url" -o /usr/local/bin/act_runner; \
    chmod +x /usr/local/bin/act_runner; \
    /usr/local/bin/act_runner --version || true

# Copier les scripts
COPY scripts/start-gitea-runner.sh /usr/local/bin/start-gitea-runner.sh
RUN chmod +x /usr/local/bin/start-gitea-runner.sh

# Health server (Clever Cloud expects an open port)
COPY scripts/health_server.py /usr/local/bin/health_server.py
RUN chmod +x /usr/local/bin/health_server.py

# Exposer le port (si nécessaire)
EXPOSE 8080

# Script de démarrage
COPY <<EOF /usr/local/bin/entrypoint.sh
#!/bin/bash
set -e

echo "Starting Gitea Runner VIRIDA"
echo "============================"

# Vérifier les variables d'environnement
if [ -z "\$GITEA_INSTANCE_URL" ]; then
    echo "[ERROR] GITEA_INSTANCE_URL is not set"
    exit 1
fi

if [ -z "\$RUNNER_NAME" ]; then
    echo "[ERROR] RUNNER_NAME is not set"
    exit 1
fi

echo "Gitea instance: \$GITEA_INSTANCE_URL"
echo "Runner name: \$RUNNER_NAME"
echo "Labels: \$RUNNER_LABELS"
echo "Workdir: \$RUNNER_WORK_DIR"
echo ""

# Start a tiny HTTP server so Clever Cloud healthchecks pass (binds to $PORT, defaults to 8080)
python3 /usr/local/bin/health_server.py &

# Docker-in-Docker is often not available on PaaS platforms like Clever Cloud.
# Do not fail hard if Docker daemon isn't accessible.
if command -v docker >/dev/null 2>&1; then
    if ! docker info >/dev/null 2>&1; then
        echo "[WARN] Docker daemon not available. Continuing without Docker executor."
    fi
else
    echo "[WARN] Docker CLI not installed. Continuing without Docker executor."
fi

# Enregistrer le runner si nécessaire
if [ ! -f "/opt/gitea-runner/.runner" ]; then
    if [ -z "\$GITEA_TOKEN" ]; then
        echo "[ERROR] Runner is not registered and GITEA_TOKEN is not set"
        echo "        Set GITEA_TOKEN in Clever Cloud environment variables"
        exit 1
    fi

    echo "Registering runner with Gitea..."
    mkdir -p "\$RUNNER_WORK_DIR"
    act_runner register \
        --instance "\$GITEA_INSTANCE_URL" \
        --token "\$GITEA_TOKEN" \
        --name "\$RUNNER_NAME" \
        --labels "\$RUNNER_LABELS" \
        --workdir "\$RUNNER_WORK_DIR" \
        --no-interactive
fi

echo "Starting act_runner daemon..."
mkdir -p "\$RUNNER_WORK_DIR"
exec act_runner daemon --workdir "\$RUNNER_WORK_DIR"
EOF

RUN chmod +x /usr/local/bin/entrypoint.sh

# Changer vers l'utilisateur runner
USER runner

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]