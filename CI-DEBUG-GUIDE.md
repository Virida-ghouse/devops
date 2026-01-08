# 🔧 Guide de Diagnostic CI - VIRIDA

## ✅ Ce qui DOIT fonctionner

### 1. Runner Gitea
- ✅ **Runner actif** : `virida-runner-mac` (PID 67719)
- ✅ **Déclaré avec succès** : Version v0.2.13
- ✅ **Prend des tâches** : Les logs montrent task 15, 16, 17, 18, 19...

### 2. Workflows configurés
- ✅ `ci-main.yml` - Pipeline principal
- ✅ `simple-test.yml` - Test simple
- ✅ `pr-validation.yml` - Validation PR
- ✅ `security-scan.yml` - Scan sécurité

### 3. Branche
- ✅ `devops_crk` - Tous les workflows sont configurés pour cette branche

---

## ❌ Problèmes identifiés

### Problème 1 : Gitea est un miroir de GitHub
**Impact** : Les workflows peuvent ne pas se synchroniser immédiatement

**Solution** :
- Attendre la synchronisation (peut prendre 15-30 minutes)
- Ou pousser directement vers Gitea si possible

### Problème 2 : Anciens workflows visibles dans Gitea
**Cause** : Gitea indexe les workflows de toutes les branches, y compris `master`

**Solution** :
- Les workflows dans `devops_crk` sont corrects
- Ignorer les anciens workflows dans la liste
- Ils ne s'exécuteront pas sur `devops_crk`

### Problème 3 : Workflows qui échouent
**Causes possibles** :
1. Actions GitHub non disponibles dans Gitea Actions
2. Syntaxe incompatible
3. Runner qui ne peut pas exécuter certaines actions

---

## 🧪 Test Rapide

### Test 1 : Vérifier que le runner prend les tâches
```bash
# Voir les logs en temps réel
tail -f /tmp/act_runner.log
```

### Test 2 : Déclencher un workflow simple
```bash
# Créer un commit de test
echo "# Test" >> test.txt
git add test.txt
git commit -m "test: trigger workflow"
git push origin devops_crk
```

### Test 3 : Vérifier les workflows dans Gitea
1. Va sur : https://gitea.virida.org/Virida/devops/actions
2. Clique sur "Simple Test Workflow"
3. Vérifie les logs d'exécution

---

## 🔍 Diagnostic étape par étape

### Étape 1 : Vérifier le runner
```bash
ps aux | grep act_runner
tail -20 /tmp/act_runner.log
```

**Résultat attendu** : Runner actif et déclaré avec succès

### Étape 2 : Vérifier les workflows
```bash
ls -la .gitea/workflows/*.yml
```

**Résultat attendu** : 4 fichiers (ci-main, simple-test, pr-validation, security-scan)

### Étape 3 : Vérifier la branche
```bash
git branch
git status
```

**Résultat attendu** : Sur `devops_crk`, à jour avec `origin/devops_crk`

### Étape 4 : Vérifier dans Gitea
1. Va sur https://gitea.virida.org/Virida/devops/actions
2. Vérifie que les workflows s'exécutent
3. Clique sur un workflow pour voir les logs

---

## 🚨 Erreurs courantes

### Erreur : "No runner available"
**Cause** : Runner inactif ou déconnecté
**Solution** : Redémarrer le runner
```bash
pkill -f "act_runner daemon"
cd /Users/crk/Desktop/VIRIDA
nohup act_runner daemon > /tmp/act_runner.log 2>&1 &
```

### Erreur : "Workflow not found"
**Cause** : Workflow pas encore synchronisé (miroir)
**Solution** : Attendre la synchronisation ou pousser directement vers Gitea

### Erreur : "Action not found"
**Cause** : Action GitHub non disponible dans Gitea
**Solution** : Utiliser des actions compatibles Gitea Actions

---

## 📊 État Actuel

- ✅ Runner : Actif et fonctionnel
- ✅ Workflows : 4 workflows configurés correctement
- ✅ Branche : `devops_crk` à jour
- ⚠️ Synchronisation : Gitea miroir peut avoir un délai
- ⚠️ Interface : Peut montrer des workflows obsolètes

---

## 🎯 Prochaines Actions

1. **Attendre la synchronisation** du miroir (15-30 min)
2. **Vérifier dans Gitea** que les nouveaux workflows apparaissent
3. **Tester un workflow** en créant un commit
4. **Vérifier les logs** si un workflow échoue

---

## 💡 Conseil

Si ça ne marche toujours pas après 30 minutes :
1. Vérifie les logs du runner : `tail -f /tmp/act_runner.log`
2. Vérifie les logs dans Gitea Actions
3. Teste avec `simple-test.yml` qui est le plus simple

