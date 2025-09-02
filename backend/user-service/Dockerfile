# ⚡ VIRIDA User Service - Dockerfile
# Service de gestion des utilisateurs pour VIRIDA

# Stage 1: Build
FROM node:18-alpine AS builder

# Métadonnées
LABEL maintainer="VIRIDA Team <dev@virida.com>"
LABEL service="user-service"
LABEL version="1.0.0"

# Variables d'environnement
ENV NODE_ENV=production

# Répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY package*.json ./

# Installation des dépendances
RUN npm ci --only=production && npm cache clean --force

# Copie du code source
COPY . .

# Build de l'application
RUN npm run build

# Stage 2: Production
FROM node:18-alpine AS production

# Métadonnées
LABEL maintainer="VIRIDA Team <dev@virida.com>"
LABEL service="user-service"
LABEL version="1.0.0"

# Variables d'environnement
ENV NODE_ENV=production
ENV PORT=8082

# Création d'un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY package*.json ./

# Installation des dépendances de production
RUN npm ci --only=production && npm cache clean --force

# Copie du code buildé
COPY --from=builder /app/dist ./dist

# Copie des fichiers de configuration
COPY --from=builder /app/config ./config

# Changement de propriétaire
RUN chown -R nodejs:nodejs /app

# Utilisateur non-root
USER nodejs

# Exposition du port
EXPOSE 8082

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8082/health || exit 1

# Démarrage
CMD ["node", "dist/index.js"]
