## Comment lancer les workflows CI manuellement sur Gitea

### 📍 URLs directes

**Interface Gitea Actions** : https://gitea.virida.org/Virida/devops/actions

**Workflows disponibles** :
- `ci-main.yml` : VIRIDA CI - Main Pipeline
- `sonar-nightly.yml` : SonarQube Analysis (auto)

---

### 🚀 Lancer la CI principale

1. **Va sur** : https://gitea.virida.org/Virida/devops/actions
2. **Clique sur** l'onglet "Actions" (en haut)
3. **Sélectionne** le workflow "VIRIDA CI - Main Pipeline"
4. **Clique** sur le bouton "Run workflow" (en haut à droite)
5. **Confirme** sur la branche `master`
6. Le workflow démarre immédiatement

---

### 🔍 Lancer l'analyse SonarQube

**Option 1 : Attendre que la CI se termine**
- Le workflow Sonar se déclenche **automatiquement** après la CI principale
- Config : `workflow_run: workflows: ["VIRIDA CI - Main Pipeline"]` (ligne 13-16 de sonar-nightly.yml)

**Option 2 : Lancer manuellement**
1. **Va sur** : https://gitea.virida.org/Virida/devops/actions
2. **Sélectionne** le workflow "SonarQube Analysis (auto)"
3. **Clique** sur "Run workflow"
4. **Confirme** sur la branche `master`

---

### 📊 Suivre l'exécution

**Logs en temps réel** :
1. Va sur https://gitea.virida.org/Virida/devops/actions
2. Clique sur le workflow en cours (status "Running" avec icône jaune)
3. Clique sur le job (ex: "Validate Code", "SonarQube Analysis")
4. Les logs s'affichent en direct

**Vérifier les résultats Sonar** :
- URL configurée dans le secret `SONAR_HOST_URL`
- Dashboard par projet : `<SONAR_HOST_URL>/dashboard?id=virida_api` (etc.)

---

### ⚙️ Mode automatique (pas d'intervention manuelle)

**CI principale** :
- Schedule : toutes les **10 minutes** (cron `*/10 * * * *`)
- Trigger auto : push sur `main` (mais désactivé en mode mirror)

**Sonar** :
- Schedule : tous les jours à **03:00 UTC** (cron `0 3 * * *`)
- Trigger auto : après complétion de la CI principale

**Note** : Le repo Gitea est en **mode mirror** (read-only depuis GitHub). Les push events ne déclenchent pas les workflows. C'est pourquoi les workflows utilisent des schedules périodiques comme filet de sécurité.

---

### ✅ Commit déjà synchronisé

Ton dernier commit est déjà sur GitHub :
```
581dad5 docs: add CI stabilization checklist and final setup instructions
e4c7824 fix(ci): stabilize CI workflows to remove blocking errors
```

Le mirror Gitea se synchronise automatiquement (intervalle : 10 min max).

**Pour forcer la synchronisation + lancer la CI immédiatement** :
→ Utilise l'interface web Gitea Actions (méthode ci-dessus)
