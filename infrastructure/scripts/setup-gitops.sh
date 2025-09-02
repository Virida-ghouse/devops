#!/bin/bash

# Script de configuration GitOps pour VIRIDA
# Usage: ./setup-gitops.sh

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

log_info "🔧 Configuration GitOps pour VIRIDA"

# Vérifier les prérequis
log_info "Vérification des prérequis..."

if ! command -v kubectl &> /dev/null; then
    log_error "kubectl not found. Please install kubectl first."
    exit 1
fi

if ! command -v argocd &> /dev/null; then
    log_warning "argocd CLI not found. Installing..."
    # Installer ArgoCD CLI
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install argocd
    else
        curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
        sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
        rm argocd-linux-amd64
    fi
fi

log_success "Prérequis vérifiés"

# Configuration des variables
ARGOCD_NAMESPACE="argocd"
ARGOCD_SERVER="argocd.cleverapps.io"
GIT_REPO="https://gitea.cleverapps.io/virida/virida.git"

# Attendre qu'ArgoCD soit prêt
log_info "Attente qu'ArgoCD soit prêt..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n $ARGOCD_NAMESPACE

# Récupérer le mot de passe admin
log_info "Récupération du mot de passe admin ArgoCD..."
ARGOCD_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Se connecter à ArgoCD
log_info "Connexion à ArgoCD..."
argocd login $ARGOCD_SERVER --username admin --password $ARGOCD_PASSWORD --insecure

# Créer un projet ArgoCD pour VIRIDA
log_info "Création du projet VIRIDA dans ArgoCD..."
argocd proj create virida \
  --description "VIRIDA Infrastructure Project" \
  --src $GIT_REPO \
  --dest https://kubernetes.default.svc,virida \
  --dest https://kubernetes.default.svc,monitoring \
  --allow-namespace virida \
  --allow-namespace monitoring \
  --allow-namespace argocd

# Configurer les permissions du projet
log_info "Configuration des permissions du projet..."
argocd proj add-source virida $GIT_REPO
argocd proj add-destination virida https://kubernetes.default.svc virida
argocd proj add-destination virida https://kubernetes.default.svc monitoring

# Créer les applications ArgoCD
log_info "Création des applications ArgoCD..."

# Application VIRIDA Infrastructure
argocd app create virida-infrastructure \
  --project virida \
  --repo $GIT_REPO \
  --path k8s/services \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace virida \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Application VIRIDA Monitoring
argocd app create virida-monitoring \
  --project virida \
  --repo $GIT_REPO \
  --path k8s/monitoring \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace monitoring \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Synchroniser les applications
log_info "Synchronisation des applications..."
argocd app sync virida-infrastructure
argocd app sync virida-monitoring

# Configurer les webhooks (si Gitea est configuré)
log_info "Configuration des webhooks GitOps..."
log_warning "Pour activer la synchronisation automatique, configurez un webhook dans Gitea:"
echo "  URL: https://argocd.cleverapps.io/api/webhook"
echo "  Secret: (générez un secret et configurez-le dans ArgoCD)"
echo "  Events: Push, Pull Request"

# Afficher le statut des applications
log_info "Statut des applications ArgoCD..."
argocd app list

# Afficher les détails des applications
log_info "Détails des applications..."
argocd app get virida-infrastructure
argocd app get virida-monitoring

# Créer un script de synchronisation manuelle
log_info "Création du script de synchronisation..."
cat > sync-apps.sh << 'EOF'
#!/bin/bash
# Script de synchronisation manuelle des applications ArgoCD

echo "🔄 Synchronisation des applications VIRIDA..."

# Se connecter à ArgoCD
argocd login argocd.cleverapps.io --username admin --password $ARGOCD_PASSWORD --insecure

# Synchroniser toutes les applications
argocd app sync virida-infrastructure
argocd app sync virida-monitoring

echo "✅ Synchronisation terminée"
EOF

chmod +x sync-apps.sh

# Résumé de la configuration GitOps
echo ""
log_success "🎉 Configuration GitOps terminée avec succès!"
echo ""
echo "📊 Résumé de la configuration:"
echo "  - Projet ArgoCD: virida"
echo "  - Applications: virida-infrastructure, virida-monitoring"
echo "  - Repository Git: $GIT_REPO"
echo "  - Synchronisation: Automatique"
echo ""
echo "🔗 Accès:"
echo "  - ArgoCD: https://$ARGOCD_SERVER (admin / $ARGOCD_PASSWORD)"
echo "  - Applications: https://$ARGOCD_SERVER/applications"
echo ""
echo "📋 Commandes utiles:"
echo "  argocd app list"
echo "  argocd app get virida-infrastructure"
echo "  argocd app sync virida-infrastructure"
echo "  ./sync-apps.sh"
echo ""
echo "🔧 Configuration webhook Gitea:"
echo "  URL: https://$ARGOCD_SERVER/api/webhook"
echo "  Secret: (à configurer dans ArgoCD)"
echo ""
log_info "Configuration GitOps terminée à $(date)"
