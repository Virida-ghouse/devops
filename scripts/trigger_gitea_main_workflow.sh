#!/usr/bin/env bash
# Lance une fois le workflow "VIRIDA CI - Main Pipeline" (ci-main.yml) sur Gitea
# pour qu'il apparaisse dans la liste déroulante de l'onglet Actions.
# Usage: GITEA_URL=... GITEA_TOKEN=... ./scripts/trigger_gitea_main_workflow.sh [owner] [repo]
# Exemple: ./scripts/trigger_gitea_main_workflow.sh Virida devops

set -euo pipefail

OWNER="${1:-Virida}"
REPO="${2:-devops}"

if [[ -z "${GITEA_URL:-}" ]] || [[ -z "${GITEA_TOKEN:-}" ]]; then
  echo "Usage: GITEA_URL=<url> GITEA_TOKEN=<token> $0 [owner] [repo]"
  echo "Example: GITEA_URL=https://gitea.example.com GITEA_TOKEN=xxx $0 Virida devops"
  exit 1
fi

# Retirer une éventuelle barre finale
GITEA_URL="${GITEA_URL%/}"
BASE="$GITEA_URL/api/v1/repos/$OWNER/$REPO/actions/workflows"

echo "Listing workflows for $OWNER/$REPO..."
RESP=$(curl -s -S -H "Authorization: token $GITEA_TOKEN" "$BASE")
if ! echo "$RESP" | grep -q '"workflows"'; then
  echo "Failed to list workflows. Response:"
  echo "$RESP" | head -20
  exit 1
fi

# Gitea renvoie workflows avec .id (souvent le path) et .path (ex: .gitea/workflows/ci-main.yml)
WORKFLOW_ID=""
if command -v jq &>/dev/null; then
  # Essayer par path (ci-main.yml ou .gitea/workflows/ci-main.yml)
  WORKFLOW_ID=$(echo "$RESP" | jq -r '.workflows[]? | select(.path != null and (.path | test("ci-main"))?) | .id' 2>/dev/null | head -1)
  if [[ -z "$WORKFLOW_ID" ]] || [[ "$WORKFLOW_ID" == "null" ]]; then
    WORKFLOW_ID=$(echo "$RESP" | jq -r '.workflows[]? | select(.name != null and (.name | test("Main Pipeline"))?) | .id' 2>/dev/null | head -1)
  fi
fi
if [[ -z "$WORKFLOW_ID" ]] || [[ "$WORKFLOW_ID" == "null" ]]; then
  # Nom de fichier attendu par l'API (souvent le basename du path)
  WORKFLOW_ID="ci-main.yml"
  echo "Using workflow file name: $WORKFLOW_ID"
fi

TARGET_REF="${TARGET_REF:-master}"
if [[ "$TARGET_REF" != "main" ]] && [[ "$TARGET_REF" != "master" ]]; then
  echo "::error::Only TARGET_REF=main or TARGET_REF=master is supported by policy."
  exit 1
fi
echo "Dispatching workflow: $WORKFLOW_ID on branch ${TARGET_REF}..."
HTTP=$(curl -s -w "%{http_code}" -o /tmp/gitea_dispatch_resp.txt -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"ref\":\"${TARGET_REF}\"}" \
  "$BASE/$WORKFLOW_ID/dispatches")
BODY=$(cat /tmp/gitea_dispatch_resp.txt)

if [[ "$HTTP" == "204" ]] || [[ "$HTTP" == "200" ]]; then
  echo "Workflow dispatch sent successfully (HTTP $HTTP). Check the Actions tab on Gitea."
else
  echo "Dispatch failed (HTTP $HTTP). Response: $BODY"
  exit 1
fi
