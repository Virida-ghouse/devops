# 📋 Explication des Workflows Gitea Actions - VIRIDA

Ce document explique à quoi sert chaque workflow et quand il s'exécute.

## 🎯 Vue d'ensemble

Tu as actuellement **10 workflows** dans `.gitea/workflows/`. Voici leur rôle :

---

## 🚀 Workflows Principaux (à utiliser)

### 1. **ci-main.yml** - 🚀 VIRIDA CI - Main Pipeline
**Rôle** : Workflow principal de CI (Continuous Integration)
**Quand s'exécute** :
- À chaque push sur `devops_crk`
- À chaque Pull Request vers `devops_crk`
- Manuellement (workflow_dispatch)

**Ce qu'il fait** :
1. ✅ **Validate** : Valide les fichiers YAML et JSON
2. 🧪 **Test Frontend** : Teste et build `virida_app`
3. 🧪 **Test Backend** : Teste et build `virida_api`
4. 🔒 **Security** : Scan de sécurité (npm audit)
5. 🏗️ **Build** : Build final des deux projets
6. 📊 **Summary** : Résumé de tous les jobs

**À utiliser** : ✅ **OUI** - C'est le workflow principal à utiliser

---

### 2. **simple-test.yml** - 🧪 Simple Test Workflow
**Rôle** : Test basique pour vérifier que la CI fonctionne
**Quand s'exécute** :
- À chaque push sur `devops_crk`
- À chaque Pull Request vers `devops_crk`
- Manuellement

**Ce qu'il fait** :
- Liste les fichiers
- Vérifie que Git fonctionne
- Vérifie Node.js et Python (si disponibles)

**À utiliser** : ✅ **OUI** - Pour tester rapidement que tout fonctionne

---

### 3. **test.yml** - 🧪 Test VIRIDA
**Rôle** : Tests détaillés frontend et backend
**Quand s'exécute** :
- À chaque push sur `devops_crk`
- À chaque Pull Request vers `devops_crk`
- Manuellement

**Ce qu'il fait** :
- Tests complets de `virida_app` (frontend)
- Tests complets de `virida_api` (backend)
- Lint et build des deux projets
- Résumé des résultats

**À utiliser** : ✅ **OUI** - Pour des tests plus détaillés que ci-main.yml

---

### 4. **pr-validation.yml** - PR Validation & Review
**Rôle** : Valide les Pull Requests avant merge
**Quand s'exécute** :
- À chaque Pull Request vers `devops_crk`
- Manuellement

**Ce qu'il fait** :
- Vérifie la taille de la PR
- Analyse le code
- Valide les builds

**À utiliser** : ✅ **OUI** - Pour valider les PRs

---

### 5. **security-scan.yml** - 🔒 Security Scan
**Rôle** : Scan de sécurité du code
**Quand s'exécute** :
- À chaque push sur `devops_crk`
- À chaque Pull Request vers `devops_crk`
- Tous les jours à 2h du matin (schedule)
- Manuellement

**Ce qu'il fait** :
- Scan des dépendances npm (virida_app et virida_api)
- Validation des Dockerfiles avec hadolint
- Génère un rapport de sécurité

**À utiliser** : ✅ **OUI** - Pour la sécurité

---

## 🏗️ Workflows de Déploiement (optionnels)

### 6. **deploy-clever-cloud.yml** - 🚀 Deploy VIRIDA to Clever Cloud
**Rôle** : Déploie l'infrastructure CI/CD sur Clever Cloud
**Quand s'exécute** :
- À chaque push sur `devops_crk`
- Manuellement

**Ce qu'il fait** :
- Déploie le runner Gitea sur Clever Cloud
- Health checks

**À utiliser** : ⚠️ **Optionnel** - Seulement si tu veux déployer le runner sur Clever Cloud

---

### 7. **deploy-virida-native.yml** - Deploy VIRIDA Native Applications
**Rôle** : Déploie les applications VIRIDA (frontend, backend, etc.)
**Quand s'exécute** :
- À chaque push sur `devops_crk`
- À chaque Pull Request vers `devops_crk`
- Manuellement

**Ce qu'il fait** :
- Déploie `virida_app` (frontend)
- Déploie `virida_api` (backend)
- Déploie d'autres apps (frontend-3d, ai-ml, monitoring)
- Health checks

**À utiliser** : ⚠️ **Optionnel** - Seulement si tu veux déployer automatiquement

**Note** : Ce workflow référence des dossiers qui n'existent peut-être pas (`apps/frontend-3d`, `apps/ai-ml`, etc.)

---

### 8. **release.yml** - Release Management
**Rôle** : Gère les releases (versions) de l'application
**Quand s'exécute** :
- Quand tu push un tag `v*` (ex: `v1.0.0`)
- Manuellement avec un numéro de version

**Ce qu'il fait** :
- Prépare la release
- Build toutes les applications
- Déploie en production
- Crée les notes de release

**À utiliser** : ⚠️ **Optionnel** - Seulement pour gérer les releases

**Note** : Ce workflow référence aussi des dossiers qui n'existent peut-être pas

---

### 9. **environments.yml** - 🌍 Environment Management
**Rôle** : Gère les environnements (dev, staging, production)
**Quand s'exécute** :
- Manuellement uniquement (workflow_dispatch)

**Ce qu'il fait** :
- Déploie sur un environnement (dev/staging/production)
- Rollback d'un environnement
- Scale un environnement
- Affiche le statut
- Récupère les logs

**À utiliser** : ⚠️ **Optionnel** - Pour gérer les environnements manuellement

---

### 10. **ci-cd.yml** - VIRIDA CI/CD Pipeline
**Rôle** : Pipeline CI/CD complet avec SonarQube
**Quand s'exécute** :
- À chaque push sur `devops_crk`
- À chaque Pull Request vers `devops_crk`
- Manuellement

**Ce qu'il fait** :
- Validate, Test, Build
- Security scan (Trivy)
- SonarQube analysis
- Déploiement staging et production

**À utiliser** : ⚠️ **Optionnel** - Si tu utilises SonarQube

**Note** : Nécessite la configuration de SonarQube (secrets, etc.)

---

## 📊 Recommandations

### ✅ Workflows à **GARDER** et utiliser :

1. **ci-main.yml** - Workflow principal CI
2. **simple-test.yml** - Test rapide
3. **test.yml** - Tests détaillés
4. **pr-validation.yml** - Validation des PRs
5. **security-scan.yml** - Scan de sécurité

### ⚠️ Workflows **OPTIONNELS** (peuvent être supprimés si non utilisés) :

6. **deploy-clever-cloud.yml** - Si tu ne déploies pas sur Clever Cloud
7. **deploy-virida-native.yml** - Si tu ne déploies pas automatiquement
8. **release.yml** - Si tu ne gères pas de releases
9. **environments.yml** - Si tu ne gères pas d'environnements
10. **ci-cd.yml** - Si tu n'utilises pas SonarQube

---

## 🎯 Workflow Recommandé pour Commencer

Pour commencer simplement, utilise seulement :

1. **ci-main.yml** - Pour la CI complète
2. **simple-test.yml** - Pour tester rapidement

Les autres workflows peuvent être ajoutés plus tard selon tes besoins.

---

## 🗑️ Nettoyage (Optionnel)

Si tu veux simplifier, tu peux supprimer les workflows que tu n'utilises pas :

```bash
# Exemple : supprimer les workflows de déploiement si tu ne les utilises pas
rm .gitea/workflows/deploy-clever-cloud.yml
rm .gitea/workflows/deploy-virida-native.yml
rm .gitea/workflows/release.yml
rm .gitea/workflows/environments.yml
rm .gitea/workflows/ci-cd.yml  # Si tu n'utilises pas SonarQube
```

---

## 📝 Résumé

- **5 workflows essentiels** : ci-main, simple-test, test, pr-validation, security-scan
- **5 workflows optionnels** : déploiement, release, environnements, SonarQube

**Conseil** : Commence avec les workflows essentiels, ajoute les autres selon tes besoins !

