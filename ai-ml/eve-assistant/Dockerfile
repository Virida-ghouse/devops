# 🤖 VIRIDA Eve Assistant - Dockerfile
# Assistant intelligent Eve pour VIRIDA

# Stage 1: Build
FROM python:3.11-slim AS builder

# Métadonnées
LABEL maintainer="VIRIDA Team <dev@virida.com>"
LABEL service="eve-assistant"
LABEL version="1.0.0"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY requirements*.txt ./

# Installation des dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Production
FROM python:3.11-slim AS production

# Métadonnées
LABEL maintainer="VIRIDA Team <dev@virida.com>"
LABEL service="eve-assistant"
LABEL version="1.0.0"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=8001

# Installation des dépendances système minimales
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Création d'un utilisateur non-root
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Répertoire de travail
WORKDIR /app

# Copie des dépendances Python depuis le stage builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copie du code source
COPY . .

# Copie des modèles IA
COPY models/ ./models/

# Changement de propriétaire
RUN chown -R appuser:appuser /app

# Utilisateur non-root
USER appuser

# Exposition du port
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8001/health || exit 1

# Démarrage
CMD ["python", "main.py"]
