# 🦊 Guide de Configuration GitLab pour VIRIDA

## 📋 Configuration Actuelle

### ✅ **GitLab Configuré**
- **URL** : https://gitlab.com
- **Projet** : virida/virida
- **Token** : Deploy Token (gldt-s3GXE...)
- **Type** : Deploy Token (permissions limitées)

### ❌ **Clever Cloud Manquant**
- **Token** : Non configuré
- **Secret** : Non configuré

## 🔧 Configuration Requise

### 1. **Credentials Clever Cloud**

Pour obtenir vos credentials Clever Cloud :

1. **Allez sur** https://console.clever-cloud.com
2. **Cliquez sur votre profil** (en haut à droite)
3. **Sélectionnez "API Keys"**
4. **Créez une nouvelle clé API** ou utilisez une existante
5. **Copiez le Token et le Secret**

### 2. **Configuration des Variables**

```bash
# Exportez vos credentials Clever Cloud
export CLEVER_TOKEN="votre_token_clever_ici"
export CLEVER_SECRET="votre_secret_clever_ici"

# Variables GitLab (déjà configurées)
export GITLAB_URL="https://gitlab.com"
export GITLAB_TOKEN="gldt-s3GXEHLypuXmLaxEo4UM"
export GITLAB_PROJECT="virida/virida"
```

### 3. **Vérification de la Configuration**

```bash
# Test de la configuration complète
./scripts/test-gitlab-config.sh

# Test des credentials Clever Cloud
clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET"
```

## 🚀 Déploiement

### **Option 1: Déploiement avec Token GitLab**

```bash
# Déploiement adapté pour deploy token
./scripts/deploy-with-gitlab-token.sh
```

### **Option 2: Déploiement Complet (DCP)**

```bash
# Déploiement complet de l'infrastructure
./scripts/dcp.sh
```

### **Option 3: Déploiement GitLab Runner uniquement**

```bash
# Déploiement du GitLab Runner
./scripts/deploy-gitlab-runner.sh
```

## 📊 Applications à Déployer

| Application | Type | Port | Description |
|-------------|------|------|-------------|
| **frontend-3d** | Node.js | 3000 | Interface 3D |
| **ai-ml** | Python | 8000 | Intelligence Artificielle |
| **gitlab-runner** | Ubuntu | 8080 | Runner CI/CD |

## 🔍 Vérification Post-Déploiement

### **1. Statut des Applications**

```bash
# Vérification du statut
clever status

# Logs d'une application
clever logs --alias virida-frontend-3d
clever logs --alias virida-ai-ml
clever logs --alias virida-gitlab-runner
```

### **2. URLs des Applications**

- **Frontend 3D** : https://virida-frontend-3d.cleverapps.io
- **AI/ML** : https://virida-ai-ml.cleverapps.io
- **GitLab Runner** : https://virida-gitlab-runner.cleverapps.io

### **3. Configuration GitLab CI/CD**

1. **Allez sur** https://gitlab.com/virida/virida
2. **Settings > CI/CD > Variables**
3. **Ajoutez les variables** :
   - `CLEVER_TOKEN` : Votre token Clever Cloud
   - `CLEVER_SECRET` : Votre secret Clever Cloud
   - `BUCKET_FTP_PASSWORD` : Odny785DsL9LYBZc
   - `BUCKET_FTP_USERNAME` : ua9e0425888f
   - `BUCKET_HOST` : bucket-a9e04258-88ff-4a8b-b7b0-87aa96455684-fsbucket.services.clever-cloud.com

## 🛠️ Dépannage

### **Problème : Credentials Clever Cloud manquants**

```bash
# Vérifiez que les variables sont définies
echo $CLEVER_TOKEN
echo $CLEVER_SECRET

# Si vides, définissez-les
export CLEVER_TOKEN="votre_token"
export CLEVER_SECRET="votre_secret"
```

### **Problème : Connexion Clever Cloud échouée**

```bash
# Test de connexion
clever login --token "$CLEVER_TOKEN" --secret "$CLEVER_SECRET"

# Vérification du statut
clever status
```

### **Problème : Déploiement échoué**

```bash
# Vérifiez les logs
clever logs --alias <nom_app>

# Redémarrez l'application
clever restart --alias <nom_app>
```

## 📝 Notes Importantes

### **Deploy Token GitLab**

- ✅ **Avantages** : Sécurisé, permissions limitées
- ⚠️ **Limitations** : Pas d'accès à l'API complète
- 🔧 **Usage** : Idéal pour les déploiements automatisés

### **Configuration Clever Cloud**

- **Organisation** : orga_a7844a87-3356-462b-9e22-ce6c5437b0aa
- **Région** : Europe (Paris)
- **Type** : Docker

### **Variables d'Environnement**

Toutes les applications VIRIDA partagent :
- Variables Bucket (stockage)
- Variables PostgreSQL (base de données)
- Variables de monitoring
- Variables de notification

## 🎯 Prochaines Étapes

1. **Configurez vos credentials Clever Cloud**
2. **Lancez le test de configuration**
3. **Déployez l'infrastructure VIRIDA**
4. **Configurez GitLab CI/CD**
5. **Testez les pipelines**

## 📞 Support

- **Documentation Clever Cloud** : https://www.clever-cloud.com/doc/
- **Documentation GitLab** : https://docs.gitlab.com/
- **Projet VIRIDA** : https://gitlab.com/virida/virida

---

**🚀 VIRIDA Infrastructure Ready!** 🚀



