#!/bin/bash
set -e

echo "Starting Gitea Runner VIRIDA"
echo "============================"

# Defaults (can be overridden by environment)
: "${RUNNER_WORK_DIR:=/tmp/act_runner/workspace}"

cd /opt/gitea-runner

# Ensure common system paths are present. JS-based actions (checkout, upload-artifact, setup-node, ...)
# require `node` to be resolvable via PATH.
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${HOME}/.cargo/bin:${PATH:-}"

echo "PATH: $PATH"
if command -v node >/dev/null 2>&1; then
    echo "Node: $(command -v node) ($(node --version 2>/dev/null || true))"
else
    echo "[ERROR] Node.js is required to run JS-based Actions, but 'node' was not found in PATH."
    exit 1
fi

# Podman is daemonless -- just check if the CLI is available
has_container_cli() {
    command -v podman >/dev/null 2>&1 || command -v docker >/dev/null 2>&1
}

if has_container_cli; then
    echo "Container engine: $(podman --version 2>/dev/null || docker --version 2>/dev/null)"
else
    echo "[WARN] No container engine (podman/docker) found."
fi

ensure_workdir() {
    local desired="$1"
    local fallback="/tmp/act_runner/workspace"
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

write_config() {
    cat > "$CONFIG_PATH" <<EOF
log:
  level: info

runner:
  file: .runner
  capacity: 1
  envs:
    PATH: "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

host:
  workdir_parent: "${RUNNER_WORK_DIR}"
EOF
}

write_config

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

EFFECTIVE_LABELS="${RUNNER_LABELS:-virida-host:host}"
if ! has_container_cli; then
    EFFECTIVE_LABELS="virida-host:host"
    echo "[WARN] No container engine; forcing host labels: ${EFFECTIVE_LABELS}"
else
    EFFECTIVE_LABELS="virida-host:host"
    echo "Labels: ${EFFECTIVE_LABELS}"
fi
echo "Workdir: ${RUNNER_WORK_DIR}"
echo ""

# Start a tiny HTTP server so Clever Cloud healthchecks pass (binds to $PORT, defaults to 8080)
python3 /usr/local/bin/health_server.py &

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
        --labels "${EFFECTIVE_LABELS}" \
        --no-interactive
else
    if ! grep -q "virida-host" "/opt/gitea-runner/.runner" 2>/dev/null; then
        echo "[WARN] Existing .runner labels do not match required 'virida-host'. Re-registering."
        rm -f "/opt/gitea-runner/.runner"
        if [ -z "${GITEA_TOKEN:-}" ]; then
            echo "[ERROR] Need GITEA_TOKEN to re-register runner with host labels"
            exit 1
        fi
        act_runner register \
            --instance "${GITEA_INSTANCE_URL}" \
            --token "${GITEA_TOKEN}" \
            --name "${RUNNER_NAME}" \
            --labels "virida-host:host" \
            --no-interactive
    fi
fi

echo "Starting act_runner daemon..."
mkdir -p "${RUNNER_WORK_DIR}"
exec act_runner daemon --config "${CONFIG_PATH}"
