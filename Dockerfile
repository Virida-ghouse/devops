# 🚀 VIRIDA Services - Dockerfile Simple pour Clever Cloud
FROM nginx:alpine

# Installation des outils nécessaires
RUN apk add --no-cache curl wget

# Suppression de la configuration par défaut
RUN rm -rf /etc/nginx/conf.d/*

# Copie des fichiers de configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

# Création du répertoire app et copie du fichier HTML
RUN mkdir -p /app
COPY index.html /app/index.html

# Configuration des permissions
RUN chown -R nginx:nginx /app /usr/share/nginx/html

# Exposition du port (Clever Cloud utilise le port 8080)
EXPOSE 8080

# Démarrage de nginx
CMD ["nginx", "-g", "daemon off;"]