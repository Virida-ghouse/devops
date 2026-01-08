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

# Installer Node.js 20 (JS-based Actions like actions/checkout/setup-node run with node16/node20 runtimes)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version \
    && ln -sf "$(command -v node)" /usr/local/bin/node16 \
    && ln -sf "$(command -v node)" /usr/local/bin/node20

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

# Script de démarrage (pas de heredoc: compatible avec le builder Clever Cloud)
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Changer vers l'utilisateur runner
USER runner

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]