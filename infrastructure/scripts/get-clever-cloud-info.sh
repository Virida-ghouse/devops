#!/bin/bash

# Script pour récupérer les informations des applications Clever Cloud
# Usage: ./get-clever-cloud-info.sh

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

log_info "🔍 Récupération des informations Clever Cloud..."

# Vérifier la connexion à Clever Cloud
if ! clever status &> /dev/null; then
    log_error "Not connected to Clever Cloud. Please run 'clever login' first."
    exit 1
fi

log_success "Connecté à Clever Cloud"

# Récupérer la liste des applications
log_info "Applications Clever Cloud:"
clever applications list

echo ""

# Récupérer les variables d'environnement
log_info "Variables d'environnement:"
clever env

echo ""

# Récupérer les informations de l'application actuelle
log_info "Informations de l'application actuelle:"
clever status

echo ""

# Récupérer les logs récents
log_info "Logs récents (dernières 10 lignes):"
clever logs --after 5m | tail -10

echo ""

# Créer un fichier de configuration pour Kubernetes
log_info "Création du fichier de configuration Kubernetes..."

cat > k8s/clever-cloud-config.yaml << EOF
# Configuration Clever Cloud pour Kubernetes
# Généré automatiquement le $(date)

apiVersion: v1
kind: ConfigMap
metadata:
  name: clever-cloud-config
  namespace: virida
data:
  # Applications Clever Cloud
  gitea-app-id: "app_eb0b5b92-1e91-41fe-814e-4ec1a30f8c8d"
  n8n-app-id: "app_5c3113e8-1093-4eab-9fa1-cc5d355e9ee3"
  virida-ihm-app-id: "app_4fdbaf24-6225-4bc5-a2bb-84319ea72bfb"
  virida-infrastructure-app-id: "app_e10f4ca6-35ab-49e6-967f-cf1ebc40bc37"
  
  # Base de données
  postgres-host: "bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com"
  postgres-database: "bjduvaldxkbwljy3uuel"
  postgres-user: "uncer3i7fyqs2zeult6r"
  
  # Domaines
  gitea-domain: "gitea.cleverapps.io"
  n8n-domain: "n8n.cleverapps.io"
  virida-ihm-domain: "virida-ihm.cleverapps.io"
  virida-infrastructure-domain: "app-e10f4ca6-35ab-49e6-967f-cf1ebc40bc37.cleverapps.io"
EOF

log_success "Configuration Kubernetes créée: k8s/clever-cloud-config.yaml"

# Créer un fichier de secrets pour Kubernetes
log_info "Création du fichier de secrets Kubernetes..."

cat > k8s/clever-cloud-secrets.yaml << EOF
# Secrets Clever Cloud pour Kubernetes
# Généré automatiquement le $(date)

apiVersion: v1
kind: Secret
metadata:
  name: clever-cloud-secrets
  namespace: virida
type: Opaque
data:
  # Base64 encoded secrets from Clever Cloud
  postgres-password: V3VvYlBsNk55azlYMFo0REtGN0JseEU1NXoyYnV1 # WuobPl6Nyk9X0Z4DKF7BlxE55z2buu
  jwt-secret: M2YyODA1MzBmOGZiNTM4YzgxNjdlN2Y5ODIxYTkyM2JiZjI0YzAwNzU5NDIwNmQ5OGYwYzdmMTBkOWI2MTNhMg== # 3f280530f8fb538c8167e7f9821a923bbf24c007594206d98f0c7f10d9b613a2
  gitea-secret-key: MWE5OGM1NzI0YzcyMGEzMDJlNjE2ZDJkNjIxZDA1ZTY5ZWRiNmE4Yzc0NTUwOGU0ZDg5ZTRlYzYwODI0NjlmYg== # 1a98c5724c720a302e616d2d621d05e69edb6a8c745508e4d89e4ec6082469fb
  grafana-admin-password: VmlyaWRhQWRtaW4yMDI0IQ== # ViridaAdmin2024!
  acme-email: Y3VydGlzLmt1bWJpQGVwaXRlY2guZXU= # curtis.kumbi@epitech.eu
EOF

log_success "Secrets Kubernetes créés: k8s/clever-cloud-secrets.yaml"

# Résumé
echo ""
log_success "🎉 Informations Clever Cloud récupérées avec succès!"
echo ""
echo "📊 Résumé:"
echo "  - Applications: 4 (gitea, n8n, virida_ihm, virida-infrastructure)"
echo "  - Base de données: PostgreSQL (bjduvaldxkbwljy3uuel)"
echo "  - Configuration: k8s/clever-cloud-config.yaml"
echo "  - Secrets: k8s/clever-cloud-secrets.yaml"
echo ""
echo "🔗 Prochaines étapes:"
echo "  1. Appliquer la configuration: kubectl apply -f k8s/clever-cloud-config.yaml"
echo "  2. Appliquer les secrets: kubectl apply -f k8s/clever-cloud-secrets.yaml"
echo "  3. Déployer Kubernetes: make k8s-deploy"
echo ""
log_info "Récupération terminée à $(date)"
