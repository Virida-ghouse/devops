#!/bin/bash

# 🚀 VIRIDA Clever Cloud Optimization Script
# Script pour optimiser les builds Docker pour Clever Cloud

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Variables
CLEVER_APP_NAME="virida"
CLEVER_ORG_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"

log_info "Optimisation des builds Docker pour Clever Cloud"

# Vérification de Clever Tools
if ! command -v clever &> /dev/null; then
    log_error "Clever Tools n'est pas installé"
    log_info "Installez-le avec: npm install -g clever-tools"
    exit 1
fi

# Vérification de la connexion
if ! clever status &> /dev/null; then
    log_error "Non connecté à Clever Cloud"
    log_info "Connectez-vous avec: clever login"
    exit 1
fi

log_success "Connecté à Clever Cloud"

# Fonction pour optimiser un Dockerfile
optimize_dockerfile() {
    local service_path=$1
    local service_name=$2
    
    log_info "Optimisation du Dockerfile pour $service_name"
    
    if [ ! -f "$service_path/Dockerfile" ]; then
        log_warning "Dockerfile non trouvé pour $service_name"
        return
    fi
    
    # Création d'un .dockerignore optimisé
    cat > "$service_path/.dockerignore" << EOF
# Dependencies
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production builds
dist
build

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
.vscode
.idea
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Git
.git
.gitignore

# Documentation
README.md
docs/

# Tests
coverage/
.nyc_output

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/

# PyInstaller
*.manifest
*.spec

# Unit test / coverage reports
htmlcov/
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/
EOF

    log_success "Dockerfile optimisé pour $service_name"
}

# Optimisation de tous les services
services=(
    "frontend/3d-visualizer:3d-visualizer"
    "frontend/dashboard:dashboard"
    "frontend/mobile:mobile"
    "backend/api-gateway:api-gateway"
    "backend/auth-service:auth-service"
    "backend/user-service:user-service"
    "backend/business-services:business-services"
    "ai-ml/prediction-engine:prediction-engine"
    "ai-ml/eve-assistant:eve-assistant"
    "iot/sensor-collector:sensor-collector"
    "iot/mqtt-broker:mqtt-broker"
    "iot/device-manager:device-manager"
)

for service in "${services[@]}"; do
    IFS=':' read -r path name <<< "$service"
    optimize_dockerfile "../../$path" "$name"
done

# Création d'un script de build optimisé pour Clever Cloud
cat > "build-for-clever.sh" << 'EOF'
#!/bin/bash

# 🚀 VIRIDA Build Script for Clever Cloud
# Script optimisé pour construire et déployer sur Clever Cloud

set -e

# Variables
CLEVER_APP_NAME="virida"
CLEVER_ORG_ID="orga_a7844a87-3356-462b-9e22-ce6c5437b0aa"

echo "🚀 Construction et déploiement sur Clever Cloud"

# Construction de l'image principale
echo "📦 Construction de l'image Docker..."
docker build -t $CLEVER_APP_NAME:latest .

# Tag pour Clever Cloud
echo "🏷️  Tagging pour Clever Cloud..."
docker tag $CLEVER_APP_NAME:latest $CLEVER_APP_NAME:clever

# Déploiement sur Clever Cloud
echo "☁️  Déploiement sur Clever Cloud..."
clever deploy --app $CLEVER_APP_NAME

echo "✅ Déploiement terminé avec succès"
EOF

chmod +x build-for-clever.sh

# Création d'un Dockerfile optimisé pour Clever Cloud
cat > "Dockerfile.clever" << 'EOF'
# 🚀 VIRIDA - Dockerfile optimisé pour Clever Cloud
# Point d'entrée principal pour le déploiement des services VIRIDA

FROM nginx:alpine

# Installation des outils nécessaires
RUN apk add --no-cache curl wget

# Création des répertoires
RUN mkdir -p /app /app/config /app/logs

# Création de la configuration nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Création de la page d'accueil VIRIDA
COPY index.html /usr/share/nginx/html/index.html

# Configuration des permissions
RUN chown -R nginx:nginx /app

# Exposition du port (Clever Cloud utilise le port 8080)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Démarrage de nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

# Création des fichiers de configuration
cat > "nginx.conf" << 'EOF'
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
        root /usr/share/nginx/html;
        index index.html;
        
        # Health check endpoint
        location /health {
            add_header Content-Type application/json;
            return 200 '{"status":"healthy","service":"virida","timestamp":"$time_iso8601"}';
        }
        
        # API proxy
        location /api/ {
            proxy_pass http://backend-api-gateway:8080/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Static files
        location / {
            try_files $uri $uri/ /index.html;
            add_header Cache-Control "public, max-age=31536000";
        }
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    }
}
EOF

cat > "index.html" << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VIRIDA - Infrastructure Services</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .container {
            text-align: center;
            max-width: 800px;
            padding: 2rem;
        }
        
        .logo {
            font-size: 4rem;
            font-weight: bold;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .subtitle {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        
        .services {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 2rem;
        }
        
        .service {
            background: rgba(255,255,255,0.1);
            padding: 1rem;
            border-radius: 10px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.2);
        }
        
        .service h3 {
            margin-bottom: 0.5rem;
            color: #ffd700;
        }
        
        .status {
            display: inline-block;
            width: 10px;
            height: 10px;
            background: #4CAF50;
            border-radius: 50%;
            margin-right: 0.5rem;
        }
        
        .footer {
            margin-top: 2rem;
            opacity: 0.7;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🚀 VIRIDA</div>
        <div class="subtitle">Infrastructure Services - Optimisé pour Clever Cloud</div>
        
        <div class="services">
            <div class="service">
                <h3>🎨 Frontend</h3>
                <p><span class="status"></span>3D Visualizer</p>
                <p><span class="status"></span>Dashboard</p>
                <p><span class="status"></span>Mobile App</p>
            </div>
            
            <div class="service">
                <h3>⚡ Backend</h3>
                <p><span class="status"></span>API Gateway</p>
                <p><span class="status"></span>Auth Service</p>
                <p><span class="status"></span>User Service</p>
            </div>
            
            <div class="service">
                <h3>🤖 AI/ML</h3>
                <p><span class="status"></span>Prediction Engine</p>
                <p><span class="status"></span>Eve Assistant</p>
            </div>
            
            <div class="service">
                <h3>🌐 IoT</h3>
                <p><span class="status"></span>Sensor Collector</p>
                <p><span class="status"></span>MQTT Broker</p>
                <p><span class="status"></span>Device Manager</p>
            </div>
        </div>
        
        <div class="footer">
            <p>Infrastructure DevOps complète - Déployée sur Clever Cloud</p>
            <p>Version 1.0.0 | Optimisé pour la production</p>
        </div>
    </div>
</body>
</html>
EOF

log_success "Optimisation terminée pour Clever Cloud"
log_info "Fichiers créés:"
log_info "  - build-for-clever.sh (script de déploiement)"
log_info "  - Dockerfile.clever (Dockerfile optimisé)"
log_info "  - nginx.conf (configuration Nginx)"
log_info "  - index.html (page d'accueil)"
log_info "  - .dockerignore (optimisé pour chaque service)"

log_info "Pour déployer sur Clever Cloud:"
log_info "  ./build-for-clever.sh"
