# 🎨 VIRIDA 3D Visualizer - Dockerfile Multi-Stage Optimisé
# Build optimisé avec cache efficace et image finale légère

# ========================================
# STAGE 1: Build Dependencies
# ========================================
FROM node:18-alpine AS deps

# Installer les dépendances système nécessaires
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    && rm -rf /var/cache/apk/*

# Définir le répertoire de travail
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
ENV NEXT_TELEMETRY_DISABLED=1
ENV BUILD_STANDALONE=true

# Build de l'application
RUN npm run build

# ========================================
# STAGE 3: Production Runtime
# ========================================
FROM node:18-alpine AS runner

# Créer un utilisateur non-root pour la sécurité
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Installer les dépendances système minimales
RUN apk add --no-cache \
    dumb-init \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Variables d'environnement de production
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Copier les fichiers de build
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Copier les fichiers de configuration
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/package.json ./

# Changer les permissions pour l'utilisateur non-root
RUN chown -R nextjs:nodejs /app
USER nextjs

# Exposer le port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Point d'entrée avec dumb-init pour une meilleure gestion des signaux
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]

# ========================================
# STAGE 4: Development (Optionnel)
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
ENV NEXT_TELEMETRY_DISABLED=1

# Exposer le port de développement
EXPOSE 3000

# Commande de développement avec hot-reload
CMD ["npm", "run", "dev"]

# ========================================
# Métadonnées de l'Image
# ========================================
LABEL org.virida.service="3d-visualizer" \
      org.virida.version="1.0.0" \
      org.virida.description="3D Visualization Service for VIRIDA" \
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
      org.label-schema.name="VIRIDA 3D Visualizer" \
      org.label-schema.description="3D Visualization Service" \
      org.label-schema.vendor="VIRIDA" \
      org.label-schema.schema-version="1.0"

