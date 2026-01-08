#!/bin/bash
set -e

echo "Starting Gitea Runner VIRIDA"
echo "============================"

# Defaults (can be overridden by environment)
: "${RUNNER_WORK_DIR:=/tmp/act_runner/workspace}"

# Vérifier les variables d'environnement
if [ -z "${GITEA_INSTANCE_URL:-}" ]; then
    echo "[ERROR] GITEA_INSTANCE_URL is not set"
    exit 1
fi

if [ -z "${RUNNER_NAME:-}" ]; then
    echo "[ERROR] RUNNER_NAME is not set"
    exit 1
fi

echo "Gitea instance: ${GITEA_INSTANCE_URL}"
echo "Runner name: ${RUNNER_NAME}"
echo "Labels: ${RUNNER_LABELS:-}"
echo "Workdir: ${RUNNER_WORK_DIR}"
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
    if [ -z "${GITEA_TOKEN:-}" ]; then
        echo "[ERROR] Runner is not registered and GITEA_TOKEN is not set"
        echo "        Set GITEA_TOKEN in Clever Cloud environment variables"
        exit 1
    fi

    echo "Registering runner with Gitea..."
    mkdir -p "${RUNNER_WORK_DIR}"
    act_runner register \
        --instance "${GITEA_INSTANCE_URL}" \
        --token "${GITEA_TOKEN}" \
        --name "${RUNNER_NAME}" \
        --labels "${RUNNER_LABELS:-}" \
        --workdir "${RUNNER_WORK_DIR}" \
        --no-interactive
fi

echo "Starting act_runner daemon..."
mkdir -p "${RUNNER_WORK_DIR}"
exec act_runner daemon --workdir "${RUNNER_WORK_DIR}"


