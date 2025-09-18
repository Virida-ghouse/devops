const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware basique
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>VIRIDA Frontend 3D Visualizer</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                margin: 0; 
                padding: 20px; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                min-height: 100vh;
            }
            .container { 
                max-width: 800px; 
                margin: 0 auto; 
                text-align: center;
            }
            h1 { 
                font-size: 3em; 
                margin-bottom: 20px;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            }
            .status { 
                background: rgba(255,255,255,0.1); 
                padding: 20px; 
                border-radius: 10px; 
                margin: 20px 0;
                backdrop-filter: blur(10px);
            }
            .info { 
                background: rgba(255,255,255,0.05); 
                padding: 15px; 
                border-radius: 8px; 
                margin: 10px 0;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🎨 VIRIDA Frontend 3D Visualizer</h1>
            <div class="status">
                <h2>✅ Application Native Clever Cloud</h2>
                <p>Runtime Node.js - Configuration automatique</p>
            </div>
            <div class="info">
                <h3>📊 Informations</h3>
                <p><strong>Port:</strong> ${PORT}</p>
                <p><strong>Environnement:</strong> ${process.env.NODE_ENV || 'development'}</p>
                <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
            </div>
            <div class="info">
                <h3>🔗 Services VIRIDA</h3>
                <p>Backend API: <code>virida-backend-api.cleverapps.io</code></p>
                <p>AI/ML Engine: <code>virida-ai-ml.cleverapps.io</code></p>
                <p>Gitea Bridge: <code>virida-gitea-bridge.cleverapps.io</code></p>
            </div>
        </div>
    </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'virida-frontend-3d',
    timestamp: new Date().toISOString(),
    port: PORT,
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/api/status', (req, res) => {
  res.json({
    service: 'virida-frontend-3d',
    version: '1.0.0',
    runtime: 'node.js',
    platform: 'clever-cloud',
    status: 'running'
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 VIRIDA Frontend 3D Visualizer démarré sur le port ${PORT}`);
  console.log(`🌐 URL: http://localhost:${PORT}`);
  console.log(`📊 Health: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Arrêt du serveur...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('🛑 Arrêt du serveur...');
  process.exit(0);
});
