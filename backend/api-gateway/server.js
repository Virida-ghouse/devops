const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    service: 'VIRIDA API Gateway',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      api: '/api/v1',
      services: '/api/v1/services',
      docs: '/api/v1/docs'
    },
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'api-gateway',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    uptime: process.uptime()
  });
});

app.get('/api/v1', (req, res) => {
  res.json({
    message: 'Welcome to VIRIDA API Gateway',
    version: 'v1',
    services: [
      'frontend-3d-visualizer',
      'backend-api-gateway',
      'ai-ml-prediction',
      'iot-sensor-collector',
      'monitoring'
    ]
  });
});

app.get('/api/v1/services', (req, res) => {
  res.json({
    services: [
      {
        name: 'frontend-3d-visualizer',
        status: 'running',
        url: 'http://frontend-3d-visualizer:3000',
        endpoints: ['/', '/health', '/api/status']
      },
      {
        name: 'ai-ml-prediction',
        status: 'running',
        url: 'http://ai-ml-prediction:8000',
        endpoints: ['/', '/health', '/api/predict']
      },
      {
        name: 'monitoring',
        status: 'running',
        url: 'http://prometheus:9090',
        endpoints: ['/metrics', '/api/v1/query']
      }
    ]
  });
});

app.get('/api/v1/docs', (req, res) => {
  res.json({
    title: 'VIRIDA API Documentation',
    version: '1.0.0',
    description: 'API Gateway pour tous les services VIRIDA',
    endpoints: {
      'GET /': 'Service information',
      'GET /health': 'Health check',
      'GET /api/v1': 'API version info',
      'GET /api/v1/services': 'List all services',
      'GET /api/v1/docs': 'API documentation'
    }
  });
});

// Proxy routes (simulation)
app.get('/api/v1/3d/*', (req, res) => {
  res.json({
    message: 'Proxied to 3D Visualizer',
    originalUrl: req.originalUrl,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/v1/ai/*', (req, res) => {
  res.json({
    message: 'Proxied to AI/ML Prediction Engine',
    originalUrl: req.originalUrl,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/v1/monitoring/*', (req, res) => {
  res.json({
    message: 'Proxied to Monitoring Service',
    originalUrl: req.originalUrl,
    timestamp: new Date().toISOString()
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`⚡ VIRIDA API Gateway running on port ${PORT}`);
});
