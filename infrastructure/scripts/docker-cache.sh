#!/bin/bash

# 🚀 VIRIDA Docker Cache Optimization Script
# Script pour optimiser le cache Docker et accélérer les builds

set -e

# Couleurs pour les messages
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

log_info "Optimisation du cache Docker pour VIRIDA"

# Fonction pour créer un cache Docker optimisé
create_docker_cache() {
    local service_path=$1
    local service_name=$2
    
    log_info "Optimisation du cache pour $service_name"
    
    if [ ! -f "$service_path/Dockerfile" ]; then
        log_warning "Dockerfile non trouvé pour $service_name"
        return
    fi
    
    # Création d'un Dockerfile avec cache optimisé
    cat > "$service_path/Dockerfile.cache" << EOF
# 🚀 VIRIDA $service_name - Dockerfile avec cache optimisé
# Optimisé pour les builds rapides

# Stage 1: Dependencies Cache
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Build Cache
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: Production
FROM nginx:alpine AS production
RUN apk add --no-cache curl
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:3000/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
EOF

    log_success "Cache optimisé créé pour $service_name"
}

# Optimisation de tous les services
services=(
    "frontend/3d-visualizer:3d-visualizer"
    "frontend/dashboard:dashboard"
    "frontend/mobile:mobile"
    "backend/api-gateway:api-gateway"
    "backend/auth-service:auth-service"
    "backend/user-service:user-service"
    "backend/business-services:business-services"
)

for service in "${services[@]}"; do
    IFS=':' read -r path name <<< "$service"
    create_docker_cache "../../$path" "$name"
done

# Création d'un script de build avec cache
cat > "build-with-cache.sh" << 'EOF'
#!/bin/bash

# 🚀 VIRIDA Build Script with Cache
# Script optimisé pour construire avec cache Docker

set -e

echo "🚀 Construction avec cache Docker optimisé"

# Variables
CLEVER_APP_NAME="virida"
CACHE_TAG="cache"

# Construction avec cache
echo "📦 Construction avec cache..."
docker build --cache-from $CLEVER_APP_NAME:$CACHE_TAG -t $CLEVER_APP_NAME:latest .

# Mise à jour du cache
echo "🔄 Mise à jour du cache..."
docker tag $CLEVER_APP_NAME:latest $CLEVER_APP_NAME:$CACHE_TAG

echo "✅ Construction avec cache terminée"
EOF

chmod +x build-with-cache.sh

# Création d'un script de nettoyage du cache
cat > "clean-cache.sh" << 'EOF'
#!/bin/bash

# 🧹 VIRIDA Cache Cleanup Script
# Script pour nettoyer le cache Docker

set -e

echo "🧹 Nettoyage du cache Docker"

# Nettoyage des images non utilisées
echo "🗑️  Suppression des images non utilisées..."
docker image prune -f

# Nettoyage des conteneurs arrêtés
echo "🗑️  Suppression des conteneurs arrêtés..."
docker container prune -f

# Nettoyage des volumes non utilisés
echo "🗑️  Suppression des volumes non utilisés..."
docker volume prune -f

# Nettoyage des réseaux non utilisés
echo "🗑️  Suppression des réseaux non utilisés..."
docker network prune -f

# Nettoyage complet du système
echo "🗑️  Nettoyage complet du système..."
docker system prune -af

echo "✅ Nettoyage du cache terminé"
EOF

chmod +x clean-cache.sh

# Création d'un script de monitoring du cache
cat > "cache-stats.sh" << 'EOF'
#!/bin/bash

# 📊 VIRIDA Cache Statistics Script
# Script pour afficher les statistiques du cache Docker

set -e

echo "📊 Statistiques du cache Docker VIRIDA"

# Taille des images
echo "📦 Taille des images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep virida

# Espace utilisé par Docker
echo "💾 Espace utilisé par Docker:"
docker system df

# Conteneurs en cours d'exécution
echo "🏃 Conteneurs en cours d'exécution:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Utilisation des ressources
echo "⚡ Utilisation des ressources:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
EOF

chmod +x cache-stats.sh

log_success "Optimisation du cache Docker terminée"
log_info "Scripts créés:"
log_info "  - build-with-cache.sh (construction avec cache)"
log_info "  - clean-cache.sh (nettoyage du cache)"
log_info "  - cache-stats.sh (statistiques du cache)"

log_info "Pour utiliser le cache optimisé:"
log_info "  ./build-with-cache.sh"
log_info "  ./cache-stats.sh"
log_info "  ./clean-cache.sh"
