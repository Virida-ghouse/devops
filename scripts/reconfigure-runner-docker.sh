#!/bin/bash

# Script pour reconfigurer le runner avec Docker
# Usage: ./scripts/reconfigure-runner-docker.sh

set -e

echo "Reconfiguration du runner avec Docker"
echo "=========================================="
echo ""

# Workdir pour les jobs (doit être writable)
: "${RUNNER_WORK_DIR:=/tmp/act_runner/workspace}"

# Arrêter le runner actuel
echo "1. Arret du runner actuel..."
pkill -f "act_runner daemon" 2>/dev/null && sleep 2 || echo "  Runner deja arrete"
echo "  [OK] Runner arrete"
echo ""

# Sauvegarder l'ancienne config
if [ -f ".runner" ]; then
    echo "2. Sauvegarde de l'ancienne configuration..."
    cp .runner .runner.backup
    echo "  [OK] Configuration sauvegardee dans .runner.backup"
    echo ""
fi

# Supprimer l'ancienne config
echo "3. Suppression de l'ancienne configuration..."
rm -f .runner
echo "  [OK] Ancienne configuration supprimee"
echo ""

# Obtenir le token
echo "4. Configuration du runner avec Docker"
echo ""
echo "[WARN] Tu dois obtenir un nouveau Registration Token depuis Gitea :"
echo "   1. Va sur https://gitea.virida.org/Virida/devops/settings/actions/runners"
echo "   2. Clique sur 'Creer un nouvel executeur' (Create new runner)"
echo "   3. Copie le REGISTRATION TOKEN affiche"
echo ""
read -p "Entre le Registration Token : " REGISTRATION_TOKEN

if [ -z "$REGISTRATION_TOKEN" ]; then
    echo "[ERROR] Token requis"
    exit 1
fi

# Enregistrer le runner avec Docker
echo ""
echo "5. Enregistrement du runner avec Docker..."
mkdir -p "$RUNNER_WORK_DIR"
act_runner register \
  --instance https://gitea.virida.org \
  --token "$REGISTRATION_TOKEN" \
  --name virida-runner-mac \
  --labels ubuntu-latest:docker://node:18 \
  --workdir "$RUNNER_WORK_DIR" \
  --no-interactive

echo ""
echo "  [OK] Runner enregistre avec Docker"
echo ""

# Démarrer le runner
echo "6. Demarrage du runner..."
mkdir -p "$RUNNER_WORK_DIR"
nohup act_runner daemon --workdir "$RUNNER_WORK_DIR" > /tmp/act_runner.log 2>&1 &
sleep 3

if ps aux | grep -q "act_runner daemon" | grep -v grep; then
    echo "  [OK] Runner demarre"
else
    echo "  [ERROR] Erreur lors du demarrage"
    exit 1
fi

echo ""
echo "[SUCCESS] Runner reconfigure avec Docker !"
echo ""
echo "Verification :"
echo "  - Runner actif : ps aux | grep act_runner"
echo "  - Logs : tail -f /tmp/act_runner.log"
echo "  - Dans Gitea : https://gitea.virida.org/Virida/devops/settings/actions/runners"
echo ""

