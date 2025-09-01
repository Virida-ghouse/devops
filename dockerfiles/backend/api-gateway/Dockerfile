# ⚙️ VIRIDA API Gateway - Dockerfile Multi-Stage Optimisé
# Service de routage et d'authentification centralisé

# ========================================
# STAGE 1: Build Dependencies
# ========================================
FROM node:18-alpine AS deps

# Installer les dépendances système
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./
COPY yarn.lock* ./
COPY pnpm-lock.yaml* ./

# Installer les dépendances avec cache optimisé
RUN if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
    elif [ -f pnpm-lock.yaml ]; then npm install -g pnpm && pnpm install --frozen-lockfile; \
    else npm ci --only=production; \
    fi

# ========================================
# STAGE 2: Build Application
# ========================================
FROM node:18-alpine AS builder

# Installer les dépendances de build
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Copier les dépendances depuis le stage précédent
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Variables d'environnement de build
ENV NODE_ENV=production
ENV BUILD_TARGET=production

# Build de l'application
RUN npm run build

# ========================================
# STAGE 3: Production Runtime
# ========================================
FROM node:18-alpine AS runner

# Créer un utilisateur non-root pour la sécurité
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodejs

# Installer les dépendances système minimales
RUN apk add --no-cache \
    dumb-init \
    curl \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Variables d'environnement de production
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# Copier les fichiers de build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Copier les fichiers de configuration
COPY --from=builder /app/config ./config
COPY --from=builder /app/scripts ./scripts

# Changer les permissions pour l'utilisateur non-root
RUN chown -R nodejs:nodejs /app
USER nodejs

# Exposer le port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Point d'entrée avec dumb-init
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]

# ========================================
# STAGE 4: Development
# ========================================
FROM node:18-alpine AS dev

# Installer les outils de développement
RUN apk add --no-cache \
    git \
    vim \
    curl \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Copier les dépendances depuis le stage deps
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Variables d'environnement de développement
ENV NODE_ENV=development
ENV PORT=3000
ENV HOST=0.0.0.0

# Exposer le port de développement
EXPOSE 3000

# Commande de développement avec hot-reload
CMD ["npm", "run", "dev"]

# ========================================
# Métadonnées de l'Image
# ========================================
LABEL org.virida.service="api-gateway" \
      org.virida.version="1.0.0" \
      org.virida.description="API Gateway Service for VIRIDA" \
      org.virida.maintainer="devops@virida.com" \
      org.virida.architecture="arm64" \
      org.virida.base-image="node:18-alpine"

# ========================================
# Informations de Build
# ========================================
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.name="VIRIDA API Gateway" \
      org.label-schema.description="API Gateway Service" \
      org.label-schema.vendor="VIRIDA" \
      org.label-schema.schema-version="1.0"

