# 🎨 VIRIDA Dashboard - Dockerfile
# Interface de tableau de bord pour VIRIDA

# Stage 1: Build
FROM node:18-alpine AS builder

# Métadonnées
LABEL maintainer="VIRIDA Team <dev@virida.com>"
LABEL service="dashboard"
LABEL version="1.0.0"

# Variables d'environnement
ENV NODE_ENV=production
ENV REACT_APP_API_URL=http://localhost:8080/api

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
FROM nginx:alpine AS production

# Installation des outils nécessaires
RUN apk add --no-cache curl wget

# Copie de la configuration nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copie des fichiers buildés
COPY --from=builder /app/build /usr/share/nginx/html

# Création du répertoire pour les logs
RUN mkdir -p /var/log/nginx

# Configuration des permissions
RUN chown -R nginx:nginx /usr/share/nginx/html /var/log/nginx

# Exposition du port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Démarrage
CMD ["nginx", "-g", "daemon off;"]
