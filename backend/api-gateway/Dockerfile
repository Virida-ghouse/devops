# ⚡ VIRIDA API Gateway - Dockerfile
# Gateway API pour tous les services VIRIDA

# ⚡ VIRIDA API Gateway - Dockerfile
FROM node:18-alpine

# Métadonnées
LABEL maintainer="VIRIDA Team <dev@virida.com>"
LABEL service="api-gateway"
LABEL version="1.0.0"

# Variables d'environnement
ENV NODE_ENV=production
ENV PORT=8080

# Installation des outils nécessaires
RUN apk add --no-cache curl

# Création d'un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY package*.json ./

# Installation des dépendances
RUN npm install --omit=dev && npm cache clean --force

# Copie du code source
COPY . .

# Changement de propriétaire
RUN chown -R nodejs:nodejs /app

# Utilisateur non-root
USER nodejs

# Exposition du port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Démarrage
CMD ["npm", "start"]
