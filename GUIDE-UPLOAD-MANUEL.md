# 📤 Guide d'Upload Manuel vers Gitea

## 🎯 Objectif
Uploader le code VIRIDA vers votre repository Gitea pour activer la CI/CD.

## 📋 Étapes d'Upload

### 1. **Accéder au Repository Gitea**
- Allez sur : [https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida](https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida)
- Connectez-vous avec vos credentials

### 2. **Méthode A : Upload de Fichiers**
1. Cliquez sur **"Upload Files"** ou **"Add Files"**
2. Glissez-déposez tous les fichiers du projet VIRIDA
3. Ou sélectionnez le fichier `virida-ci-cd.tar.gz` (1.1 MB)
4. Commitez avec le message : `Initial commit: VIRIDA CI/CD with Gitea Actions`

### 3. **Méthode B : Upload via Git (si vous avez un token)**
```bash
# Configurer l'authentification
git config --global credential.helper store

# Pousser le code
git push gitea-virida-test staging:main
# Entrez votre nom d'utilisateur et token comme mot de passe
```

## 📁 Fichiers à Uploader

### **Fichiers Critiques (OBLIGATOIRES)**
- `.gitea/workflows/` - Workflows Gitea Actions
- `apps/` - Applications (Frontend 3D, AI/ML, Go)
- `scripts/` - Scripts de déploiement
- `Dockerfile.gitea-runner` - Image du runner

### **Fichiers de Documentation**
- `ANALYSE-COMPARATIVE-CI-CD-VIRIDA.md`
- `RESUME-EXECUTIF-CI-CD-VIRIDA.md`
- `GUIDE-DEPLOIEMENT-FINAL.md`
- `README.md`

### **Fichiers de Configuration**
- `clevercloud*.json` - Configurations Clever Cloud
- `.gitlab-ci.yml` - Pipeline GitLab (pour référence)

## ✅ Vérification Post-Upload

### **1. Vérifier la Structure**
Le repository doit contenir :
```
virida/
├── .gitea/
│   └── workflows/
│       ├── ci-cd.yml
│       ├── pr-validation.yml
│       └── release.yml
├── apps/
│   ├── frontend-3d/
│   ├── ai-ml/
│   └── gitea-drone-ci/
├── scripts/
├── *.md
└── Dockerfile.gitea-runner
```

### **2. Vérifier les Workflows**
- Allez dans l'onglet **"Actions"**
- Vérifiez que les 3 workflows sont visibles
- Les workflows doivent être prêts à s'exécuter

### **3. Vérifier les Permissions**
- Vérifiez que vous avez accès aux **Settings**
- Vérifiez que vous pouvez créer des **Secrets**

## 🚀 Prochaines Étapes

Une fois l'upload terminé :

1. **Configurer le Runner** (5 min)
2. **Ajouter les Secrets** (2 min)
3. **Tester le Pipeline** (3 min)

## 🔗 Liens Utiles

- **Repository** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida
- **Actions** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/actions
- **Settings** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/settings
- **Secrets** : https://app-5d976fde-cfd7-4662-9fff-49ed6f693eee.cleverapps.io/crk_test/virida/settings/secrets/actions

## 🆘 Support

Si vous rencontrez des problèmes :
1. Vérifiez que vous êtes connecté à Gitea
2. Vérifiez que vous avez les permissions d'écriture
3. Essayez l'upload par petits lots de fichiers
4. Consultez les logs d'erreur dans Gitea

---

**Une fois l'upload terminé, nous configurerons le runner et les secrets !** 🚀
