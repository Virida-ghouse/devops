#!/usr/bin/env python3
"""
VIRIDA AI/ML Prediction Engine - Version Simplifiée
"""

import os
import json
import logging
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS

# Configuration
app = Flask(__name__)
CORS(app)
PORT = int(os.environ.get('PORT', 8000))

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/')
def home():
    """Home endpoint"""
    return jsonify({
        'service': 'VIRIDA AI/ML Prediction Engine',
        'version': '1.0.0-simple',
        'runtime': 'python',
        'platform': 'clever-cloud',
        'status': 'running',
        'timestamp': datetime.now().isoformat(),
        'endpoints': {
            'health': '/health',
            'predict': '/predict',
            'model_info': '/model/info'
        }
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'virida-ai-ml',
        'timestamp': datetime.now().isoformat(),
        'port': PORT,
        'environment': os.environ.get('NODE_ENV', 'development'),
        'python_version': os.sys.version,
        'version': 'simple'
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Make predictions using a simple model"""
    try:
        data = request.get_json()
        if not data or 'features' not in data:
            return jsonify({'error': 'Données manquantes'}), 400
        
        features = data['features']
        
        # Simple prediction logic (remplace un vrai modèle ML)
        if len(features) >= 2:
            prediction = 1 if sum(features) > 0 else 0
            probability = [0.3, 0.7] if prediction == 1 else [0.7, 0.3]
        else:
            prediction = 0
            probability = [0.5, 0.5]
        
        return jsonify({
            'prediction': prediction,
            'probability': probability,
            'features': features,
            'timestamp': datetime.now().isoformat(),
            'model': 'simple-demo'
        })
    
    except Exception as e:
        logger.error(f"Erreur lors de la prédiction: {e}")
        return jsonify({'error': 'Erreur lors de la prédiction'}), 500

@app.route('/model/info')
def model_info():
    """Get information about the current model"""
    return jsonify({
        'model_type': 'Simple Demo Model',
        'description': 'Modèle de démonstration simplifié',
        'features_expected': 2,
        'timestamp': datetime.now().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint non trouvé'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Erreur interne du serveur'}), 500

if __name__ == '__main__':
    # Start server
    logger.info(f"🚀 VIRIDA AI/ML Prediction Engine (Simple) démarré sur le port {PORT}")
    logger.info(f"🌐 URL: http://localhost:{PORT}")
    logger.info(f"📊 Health: http://localhost:{PORT}/health")
    
    app.run(host='0.0.0.0', port=PORT, debug=False)
