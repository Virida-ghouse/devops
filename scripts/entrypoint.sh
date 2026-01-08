#!/bin/bash
set -e

echo "Starting Gitea Runner VIRIDA"
echo "============================"

# Defaults (can be overridden by environment)
: "${RUNNER_WORK_DIR:=/tmp/act_runner/workspace}"

cd /opt/gitea-runner

ensure_workdir() {
    local desired="$1"
    local fallback="/tmp/act_runner/workspace"

    # Try desired workdir
    if mkdir -p "$desired" 2>/dev/null; then
        if ( : > "$desired/.virida_write_test" ) 2>/dev/null; then
            rm -f "$desired/.virida_write_test" 2>/dev/null || true
            echo "$desired"
            return 0
        fi
    fi

    echo "[WARN] RUNNER_WORK_DIR='$desired' is not writable. Falling back to '$fallback'."
    mkdir -p "$fallback"
    echo "$fallback"
}

RUNNER_WORK_DIR="$(ensure_workdir "$RUNNER_WORK_DIR")"
export RUNNER_WORK_DIR

CONFIG_PATH="/opt/gitea-runner/config.yaml"
WORKDIR_PARENT_CONTAINER="${RUNNER_WORK_DIR#/}"  # act_runner expects no leading "/" for container.workdir_parent

cat > "$CONFIG_PATH" <<EOF
log:
  level: info

runner:
  file: .runner
  capacity: 1

container:
  workdir_parent: "${WORKDIR_PARENT_CONTAINER}"

host:
  workdir_parent: "${RUNNER_WORK_DIR}"
EOF

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
        --no-interactive
fi

echo "Starting act_runner daemon..."
mkdir -p "${RUNNER_WORK_DIR}"
exec act_runner daemon --config "${CONFIG_PATH}"


