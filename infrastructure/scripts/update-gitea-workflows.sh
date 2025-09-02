#!/bin/bash

# Script de mise à jour des workflows Gitea Actions
# Usage: ./update-gitea-workflows.sh

set -e

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_info "🔄 Mise à jour des workflows Gitea Actions..."

# Vérifier si le répertoire .gitea/workflows existe
if [ ! -d ".gitea/workflows" ]; then
    log_error "Répertoire .gitea/workflows non trouvé"
    exit 1
fi

# Lister les workflows existants
log_info "Workflows existants:"
ls -la .gitea/workflows/

# Vérifier la syntaxe des workflows
log_info "Vérification de la syntaxe des workflows..."

for workflow in .gitea/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        log_info "Vérification de $(basename "$workflow")..."
        
        # Vérifier la syntaxe YAML basique
        if command -v yq &> /dev/null; then
            if yq eval '.' "$workflow" > /dev/null 2>&1; then
                log_success "Syntaxe YAML valide: $(basename "$workflow")"
            else
                log_error "Erreur de syntaxe YAML: $(basename "$workflow")"
                exit 1
            fi
        else
            log_warning "yq non installé, vérification de syntaxe ignorée"
        fi
    fi
done

# Optimiser les workflows pour Gitea Actions
log_info "Optimisation des workflows pour Gitea Actions..."

# Mettre à jour les actions pour utiliser des versions compatibles
for workflow in .gitea/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        log_info "Optimisation de $(basename "$workflow")..."
        
        # Remplacer les actions GitHub par des versions compatibles Gitea
        sed -i '' 's|actions/checkout@v4|actions/checkout@v3|g' "$workflow"
        sed -i '' 's|actions/setup-node@v4|actions/setup-node@v3|g' "$workflow"
        sed -i '' 's|actions/setup-python@v4|actions/setup-python@v4|g' "$workflow"
        sed -i '' 's|actions/upload-artifact@v3|actions/upload-artifact@v3|g' "$workflow"
        sed -i '' 's|actions/download-artifact@v3|actions/download-artifact@v3|g' "$workflow"
        
        log_success "Workflow optimisé: $(basename "$workflow")"
    fi
done

# Créer un fichier de configuration Gitea Actions
log_info "Création de la configuration Gitea Actions..."

cat > .gitea/actions.yml << EOF
# Configuration Gitea Actions pour VIRIDA
# Ce fichier configure les actions disponibles

actions:
  # Actions de base
  - name: checkout
    version: v3
    url: https://github.com/actions/checkout
    
  - name: setup-node
    version: v3
    url: https://github.com/actions/setup-node
    
  - name: setup-python
    version: v4
    url: https://github.com/actions/setup-python
    
  - name: upload-artifact
    version: v3
    url: https://github.com/actions/upload-artifact
    
  - name: download-artifact
    version: v3
    url: https://github.com/actions/download-artifact
    
  # Actions de sécurité
  - name: trivy-action
    version: master
    url: https://github.com/aquasecurity/trivy-action
    
  # Actions de déploiement
  - name: gh-pages
    version: v3
    url: https://github.com/peaceiris/actions-gh-pages
    
  # Actions de test
  - name: codecov
    version: v3
    url: https://github.com/codecov/codecov-action
EOF

log_success "Configuration Gitea Actions créée"

# Créer un script de test des workflows
log_info "Création du script de test des workflows..."

cat > infrastructure/scripts/test-workflows.sh << 'EOF'
#!/bin/bash

# Script de test des workflows Gitea Actions
# Usage: ./test-workflows.sh

set -e

echo "🧪 Test des workflows Gitea Actions..."

# Vérifier la syntaxe des workflows
for workflow in .gitea/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        echo "Vérification de $(basename "$workflow")..."
        
        # Vérifier la syntaxe YAML
        if command -v yq &> /dev/null; then
            yq eval '.' "$workflow" > /dev/null
            echo "✅ Syntaxe YAML valide"
        else
            echo "⚠️ yq non installé, vérification ignorée"
        fi
        
        # Vérifier les actions utilisées
        echo "Actions utilisées:"
        grep -E "uses:" "$workflow" | sed 's/.*uses: //' | sort | uniq
        echo ""
    fi
done

echo "✅ Test des workflows terminé"
EOF

chmod +x infrastructure/scripts/test-workflows.sh
log_success "Script de test des workflows créé"

# Créer un guide de configuration
log_info "Création du guide de configuration..."

cat > GUIDE-WORKFLOWS-GITEA.md << 'EOF'
# 🔄 Guide de Configuration des Workflows Gitea Actions

## 📋 Vue d'ensemble

Ce guide vous explique comment configurer et utiliser les workflows Gitea Actions pour VIRIDA.

## 🚀 Configuration Initiale

### 1. Activer Gitea Actions

1. **Connectez-vous à votre instance Gitea**
2. **Allez dans Settings > Actions**
3. **Activez Gitea Actions**
4. **Configurez un runner** si nécessaire

### 2. Configurer les Secrets

Utilisez le script de configuration des secrets :

```bash
./infrastructure/scripts/setup-gitea-secrets.sh
```

### 3. Tester les Workflows

```bash
./infrastructure/scripts/test-workflows.sh
```

## 🔧 Workflows Disponibles

### 1. **Test** (`test.yml`)
- Tests unitaires et d'intégration
- Tests de performance
- Validation des builds

### 2. **Déploiement** (`deploy-clever-cloud.yml`)
- Déploiement automatique sur Clever Cloud
- Tests de santé post-déploiement
- Notifications de statut

### 3. **Sécurité** (`security-scan.yml`)
- Scan de vulnérabilités
- Audit des dépendances
- Scan des images Docker

### 4. **Documentation** (`docs.yml`)
- Génération automatique de documentation
- Publication sur GitHub Pages
- Mise à jour des API docs

### 5. **Release** (`release.yml`)
- Gestion des versions
- Création de packages
- Déploiement automatique

### 6. **Environnements** (`environments.yml`)
- Gestion des environnements
- Scaling automatique
- Rollback en cas de problème

## 🧪 Test des Workflows

### Déclencher manuellement

1. **Allez dans Actions** dans votre repository Gitea
2. **Sélectionnez le workflow** à exécuter
3. **Cliquez sur "Run workflow"**
4. **Sélectionnez la branche** et les paramètres
5. **Cliquez sur "Run workflow"**

### Vérifier les logs

1. **Allez dans Actions**
2. **Cliquez sur le workflow** en cours
3. **Consultez les logs** de chaque étape

## 🔍 Dépannage

### Problèmes Courants

#### 1. Workflow ne se déclenche pas
**Solution** : Vérifiez les conditions `on:` dans le workflow

#### 2. Secret manquant
**Solution** : Vérifiez que tous les secrets sont configurés

#### 3. Action non trouvée
**Solution** : Vérifiez que l'action est disponible dans Gitea

### Logs de Débogage

Activez les logs détaillés en ajoutant :

```yaml
- name: Debug
  run: |
    echo "Debug information:"
    echo "Branch: ${{ github.ref }}"
    echo "Event: ${{ github.event_name }}"
```

## 📈 Bonnes Pratiques

### 1. Sécurité
- ✅ Utiliser des secrets pour les tokens
- ✅ Limiter les permissions des actions
- ✅ Vérifier les vulnérabilités

### 2. Performance
- ✅ Utiliser le cache des dépendances
- ✅ Paralléliser les jobs
- ✅ Optimiser les images Docker

### 3. Maintenance
- ✅ Tester les workflows régulièrement
- ✅ Mettre à jour les actions
- ✅ Surveiller les logs

## 🆘 Support

En cas de problème :
1. Consultez les logs des workflows
2. Vérifiez la configuration des secrets
3. Testez localement avant de déployer
4. Consultez la documentation Gitea Actions

---

**🎯 Vos workflows Gitea Actions sont maintenant configurés et prêts à l'emploi !**
EOF

log_success "Guide de configuration créé"

# Résumé de la mise à jour
echo ""
log_success "🎉 Mise à jour des workflows Gitea Actions terminée!"
echo ""
echo "📊 Résumé de la mise à jour:"
echo "  - Workflows optimisés: $(ls .gitea/workflows/*.yml | wc -l)"
echo "  - Configuration créée: .gitea/actions.yml"
echo "  - Script de test créé: infrastructure/scripts/test-workflows.sh"
echo "  - Guide créé: GUIDE-WORKFLOWS-GITEA.md"
echo ""
echo "🔗 Prochaines étapes:"
echo "  1. Configurer les secrets: ./infrastructure/scripts/setup-gitea-secrets.sh"
echo "  2. Tester les workflows: ./infrastructure/scripts/test-workflows.sh"
echo "  3. Déployer: ./infrastructure/scripts/deploy-complete.sh"
echo ""
log_info "Mise à jour terminée à $(date)"
