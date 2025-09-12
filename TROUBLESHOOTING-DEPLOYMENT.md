# 🚨 Guide de Dépannage - Déploiements VIRIDA

## **Problèmes Identifiés et Solutions**

### **1. ❌ Version Python Incompatible**
**Problème** : `PYTHON_VERSION: "3.11"` dans `clevercloud.json` mais environnement virtuel utilise Python 3.13
**Solution** : ✅ **CORRIGÉ** - Mise à jour vers `PYTHON_VERSION: "3.13"`

### **2. ❌ Configuration des Ports Incorrecte**
**Problème** : Conflits de ports entre les applications
**Solutions** :
- ✅ **Frontend 3D** : Port 3000 (au lieu de 8080)
- ✅ **Backend API** : Port 8080 (correct)
- ✅ **AI/ML Engine** : Port 8000 (correct)

### **3. ❌ Dépendances Trop Lourdes (AI/ML)**
**Problème** : `tensorflow` et `torch` causent des timeouts de build
**Solution** : ✅ **CORRIGÉ** - Suppression des dépendances lourdes du `requirements.txt`

---

## **🔧 Commandes de Dépannage**

### **Vérifier les Logs de Déploiement**
```bash
# Logs de l'application AI/ML
clever logs --alias virida-ai-ml

# Logs de l'application Frontend
clever logs --alias virida-frontend-3d

# Logs de l'application Backend
clever logs --alias virida-backend-api
```

### **Vérifier les Variables d'Environnement**
```bash
# Variables d'environnement AI/ML
clever env --alias virida-ai-ml

# Variables d'environnement Frontend
clever env --alias virida-frontend-3d

# Variables d'environnement Backend
clever env --alias virida-backend-api
```

### **Redéployer une Application**
```bash
# Redéployer AI/ML
cd apps/ai-ml
clever deploy --alias virida-ai-ml

# Redéployer Frontend
cd apps/frontend-3d
clever deploy --alias virida-frontend-3d

# Redéployer Backend
cd apps/backend-api
clever deploy --alias virida-backend-api
```

### **Tester les Services**
```bash
# Tester tous les services
./scripts/test-deployments.sh

# Tester un service spécifique
curl -f https://virida-ai-ml.cleverapps.io/health
curl -f https://virida-frontend-3d.cleverapps.io/health
curl -f https://virida-backend-api.cleverapps.io/health
```

---

## **📊 Status des Applications**

| Application | Type | Port | Status | URL | Problèmes |
|-------------|------|------|--------|-----|-----------|
| **virida-ai-ml** | Python | 8000 | 🔧 En cours | `virida-ai-ml.cleverapps.io` | Version Python corrigée |
| **virida-frontend-3d** | Node.js | 3000 | 🔧 En cours | `virida-frontend-3d.cleverapps.io` | Port corrigé |
| **virida-backend-api** | Node.js | 8080 | ✅ OK | `virida-backend-api.cleverapps.io` | Aucun problème |

---

## **🚀 Prochaines Étapes**

1. **Redéployer les applications** avec les corrections
2. **Tester les health checks** pour vérifier le bon fonctionnement
3. **Monitorer les logs** pour détecter d'éventuels nouveaux problèmes
4. **Configurer les domaines personnalisés** si nécessaire

---

## **💡 Conseils de Prévention**

- **Toujours tester localement** avant de déployer
- **Vérifier les versions** des runtimes (Python, Node.js)
- **Éviter les dépendances lourdes** qui peuvent causer des timeouts
- **Utiliser des ports différents** pour chaque application
- **Monitorer les logs** après chaque déploiement

---

## **🆘 Support**

Si les problèmes persistent :
1. Vérifier les logs Clever Cloud
2. Contacter le support Clever Cloud
3. Consulter la documentation Clever Cloud
4. Vérifier les quotas et limites de l'account



