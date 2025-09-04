const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware basique
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    service: 'VIRIDA Backend API Gateway',
    version: '1.0.0',
    runtime: 'node.js',
    platform: 'clever-cloud',
    status: 'running',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      api: '/api/v1',
      docs: '/api/docs'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'virida-backend-api',
    timestamp: new Date().toISOString(),
    port: PORT,
    environment: process.env.NODE_ENV || 'development',
    database: process.env.DATABASE_URL ? 'connected' : 'not configured'
  });
});

// API Routes
app.use('/api/v1', (req, res, next) => {
  res.json({
    message: 'VIRIDA API v1',
    endpoints: {
      users: '/api/v1/users',
      projects: '/api/v1/projects',
      analytics: '/api/v1/analytics',
      predictions: '/api/v1/predictions'
    }
  });
});

// API Documentation
app.get('/api/docs', (req, res) => {
  res.json({
    title: 'VIRIDA API Documentation',
    version: '1.0.0',
    description: 'API Gateway pour les services VIRIDA',
    endpoints: {
      'GET /': 'Informations sur l\'API',
      'GET /health': 'Statut de santé de l\'API',
      'GET /api/v1': 'Liste des endpoints API v1',
      'GET /api/docs': 'Documentation de l\'API'
    },
    authentication: {
      type: 'Bearer Token',
      header: 'Authorization: Bearer <token>'
    },
    rateLimit: {
      window: '15 minutes',
      max: '100 requests per IP'
    }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong!'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Not found',
    message: `Route ${req.method} ${req.path} not found`
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 VIRIDA Backend API Gateway démarré sur le port ${PORT}`);
  console.log(`🌐 URL: http://localhost:${PORT}`);
  console.log(`📊 Health: http://localhost:${PORT}/health`);
  console.log(`📚 Docs: http://localhost:${PORT}/api/docs`);
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
// Force rebuild Thu Sep  4 11:26:34 CEST 2025
// Force rebuild Thu Sep  4 11:26:46 CEST 2025
