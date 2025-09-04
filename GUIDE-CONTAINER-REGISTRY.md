# 🐳 Guide de Configuration du Gitea Container Registry

## 📋 Vue d'ensemble

Ce guide explique comment configurer le Container Registry Gitea pour VIRIDA et migrer de Docker Hub vers un registry privé.

## 🔧 Configuration Gitea (Administrateur)

### 1. **Activer le Container Registry**

Ajoutez cette configuration dans votre `app.ini` Gitea :

```ini
[container]
ENABLED = true
REGISTRY_TYPE = docker
REGISTRY_HOST = gitea.cleverapps.io
REGISTRY_PORT = 443
REGISTRY_USE_HTTPS = true
REGISTRY_ALLOWED_TYPES = docker
REGISTRY_BLOB_STORAGE_TYPE = local
REGISTRY_BLOB_STORAGE_PATH = /var/lib/gitea/containers
```

### 2. **Redémarrer Gitea**

```bash
# Redémarrer le service Gitea
sudo systemctl restart gitea
# ou
docker restart gitea
```

### 3. **Vérifier l'activation**

```bash
# Tester l'accès au registry
curl -I https://gitea.cleverapps.io/v2/
# Devrait retourner HTTP 200 ou 401
```

## 🚀 Migration des Images VIRIDA

### 1. **Prérequis**

```bash
# Variables d'environnement
export GITEA_TOKEN="your-gitea-token"
export GITEA_USER="admin"
export ORG_NAME="virida"
```

### 2. **Exécuter la migration**

```bash
# Configuration du Container Registry
./scripts/setup-gitea-container-registry.sh

# Push des images VIRIDA
./scripts/push-to-gitea-registry.sh
```

### 3. **Vérifier la migration**

```bash
# Lister les images dans le registry
curl -H "Authorization: token $GITEA_TOKEN" \
  https://gitea.cleverapps.io/v2/_catalog

# Vérifier une image spécifique
curl -H "Authorization: token $GITEA_TOKEN" \
  https://gitea.cleverapps.io/v2/virida/virida-3d-visualizer/tags/list
```

## 🐳 Utilisation du Container Registry

### **Login**

```bash
# Connexion au registry
docker login gitea.cleverapps.io -u admin
# Entrer le token comme mot de passe
```

### **Pull d'images**

```bash
# Pull des images VIRIDA
docker pull gitea.cleverapps.io/virida/virida-3d-visualizer:latest
docker pull gitea.cleverapps.io/virida/virida-api-gateway:latest
docker pull gitea.cleverapps.io/virida/virida-ai-prediction:latest
docker pull gitea.cleverapps.io/virida/gitea-virida-bridge:latest
```

### **Push d'images**

```bash
# Tag d'une image
docker tag my-image:latest gitea.cleverapps.io/virida/my-image:latest

# Push de l'image
docker push gitea.cleverapps.io/virida/my-image:latest
```

## 🔄 Déploiement Clever Cloud

### **Dockerfiles optimisés**

Les nouveaux Dockerfiles utilisent le Gitea Container Registry :

```dockerfile
# Dockerfile.gitea-3d
FROM gitea.cleverapps.io/virida/virida-3d-visualizer:latest
LABEL clevercloud.region="par"
EXPOSE 3000
CMD ["npm", "start"]
```

### **Script de déploiement**

```bash
# Déploiement avec Gitea Registry
./scripts/deploy-with-gitea-registry.sh
```

## 📊 Avantages du Container Registry privé

### ✅ **Sécurité**
- Images privées et sécurisées
- Contrôle d'accès granulaire
- Audit des images

### ✅ **Performance**
- Images stockées localement
- Pull plus rapide
- Pas de limite de rate

### ✅ **Contrôle**
- Gestion centralisée
- Versioning des images
- Intégration avec Git

## 🔧 Maintenance

### **Nettoyage des images**

```bash
# Supprimer les anciennes images
docker image prune -a

# Nettoyer le registry Gitea
# (via l'interface web Gitea)
```

### **Sauvegarde**

```bash
# Sauvegarder les images
docker save gitea.cleverapps.io/virida/virida-3d-visualizer:latest | gzip > virida-3d-visualizer.tar.gz

# Restaurer les images
gunzip -c virida-3d-visualizer.tar.gz | docker load
```

## 🆘 Dépannage

### **Problèmes courants**

1. **Registry non accessible**
   ```bash
   # Vérifier la configuration
   curl -I https://gitea.cleverapps.io/v2/
   ```

2. **Erreur d'authentification**
   ```bash
   # Re-login
   docker logout gitea.cleverapps.io
   docker login gitea.cleverapps.io -u admin
   ```

3. **Image non trouvée**
   ```bash
   # Vérifier les tags
   curl -H "Authorization: token $GITEA_TOKEN" \
     https://gitea.cleverapps.io/v2/virida/virida-3d-visualizer/tags/list
   ```

## 📚 Ressources

- [Documentation Gitea Container Registry](https://docs.gitea.io/en-us/features/container-registry/)
- [Docker Registry API](https://docs.docker.com/registry/spec/api/)
- [Clever Cloud Docker](https://www.clever-cloud.com/doc/deploy/application/docker/)

---

**🎉 Container Registry Gitea configuré pour VIRIDA !**
