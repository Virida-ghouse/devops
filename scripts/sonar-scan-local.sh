#!/usr/bin/env bash
# Run a SonarQube scan locally (from your dev machine).
#
# Why: the Clever Cloud runner is resource-constrained (~1 GB RAM) which makes
# Sonar scans slow and flaky in CI. Running locally uses your full RAM/CPU and
# is typically 5-10x faster.
#
# Prerequisites:
#   - Docker (for the official sonarsource/sonar-scanner-cli image), OR
#   - SonarScanner CLI installed locally (brew install sonar-scanner, etc.)
#
# Usage:
#   export SONAR_TOKEN=xxx         # Your Sonar Global Analysis Token
#   export SONAR_HOST_URL=https://sonarqube.example.com
#   ./scripts/sonar-scan-local.sh [api|app|both]
#
# Examples:
#   ./scripts/sonar-scan-local.sh app       # scan virida_app only
#   ./scripts/sonar-scan-local.sh api       # scan virida_api only
#   ./scripts/sonar-scan-local.sh           # scan both (default)

set -euo pipefail

TARGET="${1:-both}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -z "${SONAR_TOKEN:-}" ] || [ -z "${SONAR_HOST_URL:-}" ]; then
  echo "ERROR: SONAR_TOKEN and SONAR_HOST_URL must be set in the environment."
  echo ""
  echo "Example:"
  echo "  export SONAR_TOKEN=sqa_xxxxx"
  echo "  export SONAR_HOST_URL=https://your-sonar.example.com"
  echo "  $0 both"
  exit 1
fi

# Normalize Sonar URL (strip path/query)
SONAR_HOST_URL_CLEAN="$(printf '%s\n' "${SONAR_HOST_URL}" | sed -E 's#(https?://[^/]+).*#\1#')"

# Pick the scanner to use
if command -v sonar-scanner >/dev/null 2>&1; then
  SCANNER=(sonar-scanner)
  echo "[INFO] Using local sonar-scanner: $(sonar-scanner --version 2>&1 | head -1)"
elif command -v docker >/dev/null 2>&1; then
  SCANNER=(docker run --rm
    -e "SONAR_HOST_URL=${SONAR_HOST_URL_CLEAN}"
    -e "SONAR_TOKEN=${SONAR_TOKEN}"
    -v "${REPO_ROOT}:/usr/src"
    sonarsource/sonar-scanner-cli:latest)
  echo "[INFO] Using sonarsource/sonar-scanner-cli via Docker"
else
  echo "ERROR: neither 'sonar-scanner' nor 'docker' found in PATH."
  echo "Install one of:"
  echo "  - macOS: brew install sonar-scanner"
  echo "  - Docker: https://docs.docker.com/get-docker/"
  exit 1
fi

scan_api() {
  local dir="${REPO_ROOT}/virida_api"
  if [ ! -f "${dir}/package.json" ]; then
    echo "[WARN] ${dir}/package.json not found — skipping virida_api scan."
    return 0
  fi
  echo ""
  echo "=== Scanning virida_api ==="
  (cd "${dir}" && "${SCANNER[@]}" \
    -Dsonar.host.url="${SONAR_HOST_URL_CLEAN}" \
    -Dsonar.token="${SONAR_TOKEN}" \
    -Dsonar.projectKey=virida_api \
    -Dsonar.projectName=virida_api \
    -Dsonar.sources=src \
    -Dsonar.tests=tests \
    -Dsonar.test.inclusions="tests/**/*" \
    -Dsonar.exclusions="node_modules/**,dist/**,build/**,coverage/**,**/*.min.js,**/*.bundle.js,prisma/migrations/**,**/*.generated.*" \
    -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
    -Dsonar.sourceEncoding=UTF-8)
}

scan_app() {
  local dir="${REPO_ROOT}/virida_app"
  if [ ! -f "${dir}/package.json" ]; then
    echo "[WARN] ${dir}/package.json not found — skipping virida_app scan."
    return 0
  fi
  echo ""
  echo "=== Scanning virida_app ==="
  (cd "${dir}" && "${SCANNER[@]}" \
    -Dsonar.host.url="${SONAR_HOST_URL_CLEAN}" \
    -Dsonar.token="${SONAR_TOKEN}" \
    -Dsonar.projectKey=virida_app \
    -Dsonar.projectName=virida_app \
    -Dsonar.sources=src \
    -Dsonar.tests=src \
    -Dsonar.test.inclusions="src/**/*.test.ts,src/**/*.test.tsx,src/**/*.integration.test.tsx" \
    -Dsonar.exclusions="dist/**,public/**,node_modules/**,coverage/**,**/*.d.ts,**/*.min.js,**/*.bundle.js,**/*.generated.*,src/assets/**" \
    -Dsonar.sourceEncoding=UTF-8)
}

case "${TARGET}" in
  api)   scan_api ;;
  app)   scan_app ;;
  both)  scan_api; scan_app ;;
  *)
    echo "Usage: $0 [api|app|both]"
    exit 1
    ;;
esac

echo ""
echo "[OK] Scan(s) complete. Results: ${SONAR_HOST_URL_CLEAN}"
