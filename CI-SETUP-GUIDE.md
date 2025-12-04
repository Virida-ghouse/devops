# 🚀 Guide de Configuration CI - VIRIDA

## 📋 Vue d'ensemble

Ce guide te permet de configurer la CI (Continuous Integration) pour VIRIDA étape par étape, dans le bon ordre.

## ✅ Checklist de Configuration

### Étape 1 : Activer Gitea Actions dans le dépôt

1. Va sur **https://gitea.virida.org/Virida/devops**
2. Clique sur **Settings** (Paramètres)
3. Va dans **Actions** → **General**
4. Active **Enable Actions** (Activer les Actions)
5. Sauvegarde

✅ **Vérification** : Tu devrais voir l'onglet "Actions" dans le menu du dépôt

---

### Étape 2 : Configurer un Runner Gitea

Le runner est nécessaire pour exécuter les workflows. Tu as deux options :

#### Option A : Runner Local (pour tester rapidement)

```bash
# 1. Télécharger act_runner (macOS ARM64)
cd /tmp
wget https://gitea.com/gitea/act_runner/releases/download/v0.2.13/act_runner-0.2.13-darwin-arm64
chmod +x act_runner-0.2.13-darwin-arm64
sudo mv act_runner-0.2.13-darwin-arm64 /usr/local/bin/act_runner

# 2. Obtenir le Registration Token
# Va sur: https://gitea.virida.org/Virida/devops/settings/actions/runners
# Clique sur "Create new Runner"
# Copie le REGISTRATION TOKEN

# 3. Enregistrer le runner
act_runner register \
  --instance https://gitea.virida.org \
  --token VOTRE_REGISTRATION_TOKEN \
  --name virida-runner-local \
  --labels ubuntu-latest:docker://node:18 \
  --no-interactive

# 4. Démarrer le runner
act_runner daemon
```

#### Option B : Runner sur Clever Cloud (Production)

Utilise le script existant :
```bash
./scripts/configure-gitea-runner-manual.sh
```

✅ **Vérification** : Va sur https://gitea.virida.org/Virida/devops/settings/actions/runners
Tu devrais voir ton runner avec le statut "Online" (En ligne)

---

### Étape 3 : Vérifier les Workflows

Les workflows sont dans `.gitea/workflows/` :

- ✅ **ci-main.yml** : Workflow principal CI (validate, test, build, security)
- ✅ **test.yml** : Tests détaillés frontend/backend
- ✅ **pr-validation.yml** : Validation des Pull Requests
- ✅ **security-scan.yml** : Scan de sécurité
- ✅ **simple-test.yml** : Test simple pour vérifier que ça fonctionne

✅ **Vérification** : 
```bash
ls -la .gitea/workflows/
```

---

### Étape 4 : Tester la CI

#### Test 1 : Workflow Simple (Recommandé pour commencer)

1. **Push sur la branche devops_crk** :
   ```bash
   git add .
   git commit -m "test: trigger CI workflow"
   git push origin devops_crk
   ```

2. **Vérifier l'exécution** :
   - Va sur https://gitea.virida.org/Virida/devops/actions
   - Tu devrais voir le workflow "🧪 Simple Test Workflow" s'exécuter
   - Clique dessus pour voir les logs

#### Test 2 : Workflow CI Principal

Une fois le test simple fonctionne, teste le workflow principal :

1. **Push sur la branche devops_crk** :
   ```bash
   git add .
   git commit -m "test: trigger main CI pipeline"
   git push origin devops_crk
   ```

2. **Vérifier l'exécution** :
   - Va sur https://gitea.virida.org/Virida/devops/actions
   - Tu devrais voir le workflow "🚀 VIRIDA CI - Main Pipeline"
   - Vérifie que tous les jobs passent :
     - ✅ Validate
     - 🧪 Test Frontend
     - 🧪 Test Backend
     - 🔒 Security
     - 🏗️ Build

---

## 🔍 Dépannage

### Le runner ne prend pas les jobs

1. **Vérifier que le runner est actif** :
   ```bash
   ps aux | grep act_runner
   ```

2. **Vérifier les logs du runner** :
   - Si local : regarde la sortie de `act_runner daemon`
   - Si sur Clever Cloud : `clever logs --app virida-gitea-runner`

3. **Vérifier que Docker fonctionne** (si tu utilises des labels Docker) :
   ```bash
   docker ps
   ```

### Les workflows ne se déclenchent pas

1. ✅ Vérifier que Gitea Actions est activé dans les paramètres du dépôt
2. ✅ Vérifier que les fichiers `.gitea/workflows/*.yml` sont présents
3. ✅ Vérifier la syntaxe YAML des workflows
4. ✅ Vérifier que tu push sur la branche `devops_crk`

### Erreur "No runner available"

1. ✅ Vérifier qu'au moins un runner est enregistré et actif
2. ✅ Vérifier que les labels du workflow correspondent aux labels du runner
   - Les workflows utilisent `runs-on: ubuntu-latest`
   - Le runner doit avoir le label `ubuntu-latest`

### Erreur dans les tests

Si les tests échouent :

1. **Vérifier les logs** dans l'interface Gitea Actions
2. **Tester localement** :
   ```bash
   # Frontend
   cd virida_app
   npm ci
   npm run lint
   npm run build
   
   # Backend
   cd virida_api
   npm ci
   npm run lint
   npm test
   ```

---

## 📊 Ordre d'Exécution des Workflows

Quand tu push sur `devops_crk`, les workflows s'exécutent dans cet ordre :

1. **simple-test.yml** : Test basique (vérifie que tout fonctionne)
2. **ci-main.yml** : Pipeline CI complet
   - Validate → Test Frontend → Test Backend → Security → Build → Summary
3. **test.yml** : Tests détaillés (si présent)
4. **security-scan.yml** : Scan de sécurité (si configuré)

---

## 🎯 Prochaines Étapes

Une fois la CI fonctionnelle :

1. ✅ Configurer les secrets pour les déploiements (si nécessaire)
2. ✅ Configurer SonarQube (optionnel)
3. ✅ Configurer les notifications (email, Slack, etc.)
4. ✅ Optimiser les workflows selon tes besoins

---

## 📚 Ressources

- [Documentation Gitea Actions](https://docs.gitea.com/usage/actions/overview)
- [Documentation act_runner](https://gitea.com/gitea/act_runner)
- [Workflows VIRIDA](.gitea/workflows/)

---

## ✅ Checklist Finale

- [ ] Gitea Actions activé dans le dépôt
- [ ] Runner installé et enregistré
- [ ] Runner actif et en ligne
- [ ] Workflow simple-test.yml testé avec succès
- [ ] Workflow ci-main.yml testé avec succès
- [ ] Tous les jobs passent (validate, test, build, security)

**🎉 Félicitations ! Ta CI est maintenant configurée et fonctionnelle !**

