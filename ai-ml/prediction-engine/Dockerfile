# 🤖 VIRIDA Prediction Engine - Dockerfile
# Moteur de prédiction IA pour VIRIDA

# 🤖 VIRIDA Prediction Engine - Dockerfile
FROM python:3.11-slim

# Métadonnées
LABEL maintainer="VIRIDA Team <dev@virida.com>"
LABEL service="prediction-engine"
LABEL version="1.0.0"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=8000

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Création d'un utilisateur non-root
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY requirements*.txt ./

# Installation des dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code source
COPY . .

# Changement de propriétaire
RUN chown -R appuser:appuser /app

# Utilisateur non-root
USER appuser

# Exposition du port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Démarrage
CMD ["python", "main.py"]
