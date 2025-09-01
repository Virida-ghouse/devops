# 🤖 VIRIDA AI/ML Prediction Engine - Dockerfile Multi-Stage Optimisé
# Service d'intelligence artificielle avec support GPU/TPU

# ========================================
# STAGE 1: Base Python avec CUDA Support
# ========================================
FROM nvidia/cuda:11.8-runtime-ubuntu20.04 AS cuda-base

# Variables d'environnement CUDA
ENV CUDA_VISIBLE_DEVICES=0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# ========================================
# STAGE 2: Python Dependencies
# ========================================
FROM python:3.11-slim AS deps

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les fichiers de dépendances
COPY requirements.txt ./
COPY requirements-dev.txt ./
COPY setup.py ./
COPY pyproject.toml ./

# Installer les dépendances Python avec cache optimisé
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# ========================================
# STAGE 3: Build Application
# ========================================
FROM python:3.11-slim AS builder

# Installer les dépendances de build
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les dépendances depuis le stage précédent
COPY --from=deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=deps /usr/local/bin /usr/local/bin

# Copier le code source
COPY . .

# Variables d'environnement de build
ENV PYTHONPATH=/app
ENV BUILD_TARGET=production

# Build de l'application
RUN python setup.py build_ext --inplace

# ========================================
# STAGE 4: Production Runtime
# ========================================
FROM nvidia/cuda:11.8-runtime-ubuntu20.04 AS runner

# Installer Python et les dépendances minimales
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-pip \
    python3.11-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Créer un utilisateur non-root pour la sécurité
RUN useradd --create-home --shell /bin/bash --uid 1001 mluser
RUN usermod -aG video mluser

WORKDIR /app

# Variables d'environnement de production
ENV PYTHONPATH=/app
ENV CUDA_VISIBLE_DEVICES=0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV PORT=8000
ENV HOST=0.0.0.0

# Copier les fichiers de build
COPY --from=builder /app /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copier les modèles pré-entraînés
COPY --from=builder /app/models ./models
COPY --from=builder /app/config ./config

# Changer les permissions pour l'utilisateur non-root
RUN chown -R mluser:mluser /app
USER mluser

# Exposer le port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Point d'entrée
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

# ========================================
# STAGE 5: Development
# ========================================
FROM python:3.11-slim AS dev

# Installer les outils de développement
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les dépendances depuis le stage deps
COPY --from=deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=deps /usr/local/bin /usr/local/bin

# Copier le code source
COPY . .

# Variables d'environnement de développement
ENV PYTHONPATH=/app
ENV ENVIRONMENT=development
ENV PORT=8000
ENV HOST=0.0.0.0

# Installer les dépendances de développement
RUN pip install --no-cache-dir -r requirements-dev.txt

# Exposer le port de développement
EXPOSE 8000

# Commande de développement avec hot-reload
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ========================================
# STAGE 6: GPU Training (Optionnel)
# ========================================
FROM nvidia/cuda:11.8-devel-ubuntu20.04 AS gpu-train

# Installer Python et les dépendances de training
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-pip \
    python3.11-dev \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier le code source
COPY . .

# Variables d'environnement GPU
ENV CUDA_VISIBLE_DEVICES=0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Installer les dépendances de training
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r requirements-dev.txt

# Commande de training
CMD ["python", "train.py"]

# ========================================
# Métadonnées de l'Image
# ========================================
LABEL org.virida.service="prediction-engine" \
      org.virida.version="1.0.0" \
      org.virida.description="AI/ML Prediction Engine for VIRIDA" \
      org.virida.maintainer="devops@virida.com" \
      org.virida.architecture="arm64" \
      org.virida.base-image="nvidia/cuda:11.8-runtime-ubuntu20.04" \
      org.virida.gpu-support="true" \
      org.virida.cuda-version="11.8"

# ========================================
# Informations de Build
# ========================================
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.name="VIRIDA AI/ML Prediction Engine" \
      org.label-schema.description="AI/ML Prediction Service" \
      org.label-schema.vendor="VIRIDA" \
      org.label-schema.schema-version="1.0"

