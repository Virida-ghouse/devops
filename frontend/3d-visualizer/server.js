const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.static('public'));
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>VIRIDA 3D Visualizer</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
            .container { max-width: 1200px; margin: 0 auto; text-align: center; }
            .header { margin-bottom: 40px; }
            .visualizer { background: rgba(255,255,255,0.1); padding: 40px; border-radius: 15px; margin: 20px 0; }
            .controls { display: flex; justify-content: center; gap: 20px; margin: 20px 0; }
            .btn { padding: 10px 20px; background: #4CAF50; color: white; border: none; border-radius: 5px; cursor: pointer; }
            .btn:hover { background: #45a049; }
            .status { margin: 20px 0; padding: 15px; background: rgba(0,0,0,0.2); border-radius: 8px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎨 VIRIDA 3D Visualizer</h1>
                <p>Interface 3D pour visualiser les données VIRIDA</p>
            </div>
            
            <div class="visualizer">
                <h2>Visualisation 3D</h2>
                <div id="canvas" style="width: 100%; height: 400px; background: rgba(0,0,0,0.3); border-radius: 8px; display: flex; align-items: center; justify-content: center; margin: 20px 0;">
                    <p>🎯 Zone de visualisation 3D<br><small>Three.js sera intégré ici</small></p>
                </div>
                
                <div class="controls">
                    <button class="btn" onclick="rotateView()">🔄 Rotation</button>
                    <button class="btn" onclick="zoomIn()">🔍 Zoom +</button>
                    <button class="btn" onclick="zoomOut()">🔍 Zoom -</button>
                    <button class="btn" onclick="resetView()">🏠 Reset</button>
                </div>
            </div>
            
            <div class="status">
                <h3>📊 Status du Service</h3>
                <p><strong>Service:</strong> Frontend 3D Visualizer</p>
                <p><strong>Version:</strong> 1.0.0</p>
                <p><strong>Status:</strong> <span style="color: #4CAF50;">✅ Opérationnel</span></p>
                <p><strong>Timestamp:</strong> <span id="timestamp"></span></p>
                <p><strong>Pod:</strong> <span id="pod"></span></p>
            </div>
        </div>
        
        <script>
            document.getElementById('timestamp').textContent = new Date().toLocaleString();
            document.getElementById('pod').textContent = window.location.hostname;
            
            function rotateView() { alert('🔄 Rotation activée'); }
            function zoomIn() { alert('🔍 Zoom avant'); }
            function zoomOut() { alert('🔍 Zoom arrière'); }
            function resetView() { alert('🏠 Vue réinitialisée'); }
        </script>
    </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: '3d-visualizer',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/api/status', (req, res) => {
  res.json({
    service: 'VIRIDA 3D Visualizer',
    status: 'running',
    endpoints: ['/', '/health', '/api/status'],
    features: ['3D Visualization', 'Real-time Data', 'Interactive Controls']
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🎨 VIRIDA 3D Visualizer running on port ${PORT}`);
});
