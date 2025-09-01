#!/bin/sh

# 🚀 VIRIDA Backend API Gateway - Script de démarrage

echo "🚀 Démarrage du Backend API Gateway VIRIDA..."

# Création de la page d'accueil simple
cat > /app/index.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VIRIDA - Backend API Gateway</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
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
        }
        .endpoints {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 2rem;
        }
        .endpoint {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.2);
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
        <h1>🔧 VIRIDA</h1>
        <div class="subtitle">Backend API Gateway</div>
        
        <div class="status">
            ✅ Service opérationnel et prêt
        </div>
        
        <div class="endpoints">
            <div class="endpoint">
                <h3>👥 Users API</h3>
                <p>/api/users</p>
            </div>
            <div class="endpoint">
                <h3>📊 Data API</h3>
                <p>/api/data</p>
            </div>
            <div class="endpoint">
                <h3>🤖 AI API</h3>
                <p>/api/ai</p>
            </div>
        </div>
        
        <div class="version">
            Version 1.0.0 - Déployé via Jenkins CI/CD
        </div>
    </div>
</body>
</html>
EOF

# Démarrage de nginx
echo "🌐 Démarrage de nginx sur le port 8080..."
nginx -g "daemon off;"

