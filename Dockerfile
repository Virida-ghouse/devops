# 🚀 VIRIDA Services - Dockerfile pour Clever Cloud
# Point d'entrée principal pour le déploiement des services VIRIDA

FROM nginx:alpine

# Installation des outils nécessaires
RUN apk add --no-cache curl wget

# Création des répertoires
RUN mkdir -p /app /app/config /app/logs

# Copie de la configuration nginx pour le point d'entrée
COPY <<EOF /etc/nginx/nginx.conf
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    server {
        listen 8080;
        server_name localhost;
        
        # Root directory
        root /app;
        index index.html;
        
        # Health check endpoints
        location /health {
            add_header Content-Type application/json;
            return 200 '{"status":"healthy","service":"virida-infrastructure","timestamp":"$time_iso8601"}';
        }
        
        location /ready {
            add_header Content-Type application/json;
            return 200 '{"status":"ready","service":"virida-infrastructure","timestamp":"$time_iso8601"}';
        }
        
        location /metrics {
            add_header Content-Type application/json;
            return 200 '{"status":"ok","service":"virida-infrastructure","version":"1.0.0","timestamp":"$time_iso8601"}';
        }
        
        # Main application - Page d'accueil VIRIDA
        location / {
            try_files $uri $uri/ /index.html;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    }
}
EOF

# Création de la page d'accueil VIRIDA
COPY <<EOF /app/index.html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VIRIDA - Infrastructure Services</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            max-width: 800px;
        }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
        }
        .subtitle {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        .status {
            background: rgba(76, 175, 80, 0.2);
            padding: 1rem;
            border-radius: 10px;
            border: 1px solid rgba(76, 175, 80, 0.5);
            margin-bottom: 2rem;
        }
        .services {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 2rem;
        }
        .service {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .service h3 {
            margin-top: 0;
        }
        .deployment-info {
            margin-top: 2rem;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            font-size: 0.9rem;
            opacity: 0.8;
        }
        .version {
            margin-top: 2rem;
            opacity: 0.7;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 VIRIDA</h1>
        <div class="subtitle">Infrastructure Services - Clever Cloud</div>
        
        <div class="status">
            ✅ Infrastructure déployée et opérationnelle
        </div>
        
        <div class="services">
            <div class="service">
                <h3>🎨 Frontend 3D</h3>
                <p>Interface de visualisation 3D</p>
            </div>
            <div class="service">
                <h3>⚡ Backend API</h3>
                <p>API Gateway et services</p>
            </div>
            <div class="service">
                <h3>🤖 AI/ML Engine</h3>
                <p>Moteur de prédiction IA</p>
            </div>
            <div class="service">
                <h3>📊 Monitoring</h3>
                <p>Prometheus & Grafana</p>
            </div>
        </div>
        
        <div class="deployment-info">
            <strong>Déploiement :</strong> Clever Cloud<br>
            <strong>Base de données :</strong> PostgreSQL<br>
            <strong>Reverse Proxy :</strong> Traefik<br>
            <strong>Monitoring :</strong> Prometheus + Grafana
        </div>
        
        <div class="version">
            Version 1.0.0 - Déployé via Clever Cloud
        </div>
    </div>
</body>
</html>
EOF

# Configuration des permissions
RUN chown -R nginx:nginx /app

# Exposition du port (Clever Cloud utilise le port 8080)
EXPOSE 8080

# Démarrage de nginx
CMD ["nginx", "-g", "daemon off;"]
