#!/bin/bash

# Script pour supprimer la branche master après avoir changé la branche par défaut

echo "Vérification de la branche par défaut..."
HEAD_BRANCH=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')

if [ "$HEAD_BRANCH" = "master" ]; then
    echo "❌ La branche par défaut est toujours 'master'"
    echo ""
    echo "⚠️  Tu dois d'abord changer la branche par défaut sur GitHub :"
    echo "   1. Va sur https://github.com/Virida-ghouse/devops/settings/branches"
    echo "   2. Change la branche par défaut de 'master' vers 'devops_crk'"
    echo "   3. Relance ce script : ./scripts/delete-master-branch.sh"
    exit 1
fi

echo "✅ La branche par défaut est '$HEAD_BRANCH'"
echo ""
echo "Suppression de la branche master distante..."

# Rafraîchir les références distantes
git fetch --prune

# Supprimer la branche distante master
if git push origin --delete master 2>&1; then
    echo "✅ Branche 'master' supprimée avec succès sur origin"
else
    echo "⚠️  La branche 'master' n'existe peut-être plus ou a déjà été supprimée"
fi

# Supprimer la branche locale master si elle existe encore
if git show-ref --verify --quiet refs/heads/master; then
    git branch -D master
    echo "✅ Branche locale 'master' supprimée"
else
    echo "ℹ️  Pas de branche locale 'master' à supprimer"
fi

# Nettoyer les références distantes
git fetch --prune

echo ""
echo "✅ Nettoyage terminé !"
git branch -a | grep -E "(master|main)" || echo "Aucune branche master/main restante"


