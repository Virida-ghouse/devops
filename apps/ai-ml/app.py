#!/usr/bin/env python3
"""
VIRIDA AI/ML Prediction Engine - Application native Clever Cloud
"""

import os
import json
import logging
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import joblib

# Configuration
app = Flask(__name__)
CORS(app)
PORT = int(os.environ.get('PORT', 8000))

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global variables
model = None
model_loaded = False

def load_model():
    """Load or create a simple ML model"""
    global model, model_loaded
    try:
        # Create a simple model for demonstration
        # In production, you would load a pre-trained model
        X = np.random.rand(100, 4)
        y = np.random.randint(0, 2, 100)
        
        model = RandomForestClassifier(n_estimators=10, random_state=42)
        model.fit(X, y)
        
        model_loaded = True
        logger.info("✅ Modèle ML chargé avec succès")
    except Exception as e:
        logger.error(f"❌ Erreur lors du chargement du modèle: {e}")
        model_loaded = False

@app.route('/')
def home():
    """Home endpoint"""
    return jsonify({
        'service': 'VIRIDA AI/ML Prediction Engine',
        'version': '1.0.0',
        'runtime': 'python',
        'platform': 'clever-cloud',
        'status': 'running',
        'timestamp': datetime.now().isoformat(),
        'model_loaded': model_loaded,
        'endpoints': {
            'health': '/health',
            'predict': '/predict',
            'train': '/train',
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
        'model_loaded': model_loaded,
        'python_version': os.sys.version
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Make predictions using the ML model"""
    try:
        if not model_loaded:
            return jsonify({'error': 'Modèle non chargé'}), 500
        
        data = request.get_json()
        if not data or 'features' not in data:
            return jsonify({'error': 'Données manquantes'}), 400
        
        features = np.array(data['features']).reshape(1, -1)
        prediction = model.predict(features)[0]
        probability = model.predict_proba(features)[0].tolist()
        
        return jsonify({
            'prediction': int(prediction),
            'probability': probability,
            'features': data['features'],
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        logger.error(f"Erreur lors de la prédiction: {e}")
        return jsonify({'error': 'Erreur lors de la prédiction'}), 500

@app.route('/train', methods=['POST'])
def train():
    """Train the ML model with new data"""
    try:
        data = request.get_json()
        if not data or 'X' not in data or 'y' not in data:
            return jsonify({'error': 'Données d\'entraînement manquantes'}), 400
        
        X = np.array(data['X'])
        y = np.array(data['y'])
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        # Train model
        global model
        model = RandomForestClassifier(n_estimators=10, random_state=42)
        model.fit(X_train, y_train)
        
        # Evaluate
        y_pred = model.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        
        global model_loaded
        model_loaded = True
        
        return jsonify({
            'message': 'Modèle entraîné avec succès',
            'accuracy': float(accuracy),
            'training_samples': len(X_train),
            'test_samples': len(X_test),
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        logger.error(f"Erreur lors de l'entraînement: {e}")
        return jsonify({'error': 'Erreur lors de l\'entraînement'}), 500

@app.route('/model/info')
def model_info():
    """Get information about the current model"""
    if not model_loaded:
        return jsonify({'error': 'Modèle non chargé'}), 500
    
    return jsonify({
        'model_type': type(model).__name__,
        'model_params': model.get_params(),
        'feature_importance': model.feature_importances_.tolist() if hasattr(model, 'feature_importances_') else None,
        'n_estimators': model.n_estimators if hasattr(model, 'n_estimators') else None,
        'timestamp': datetime.now().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint non trouvé'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Erreur interne du serveur'}), 500

if __name__ == '__main__':
    # Load model on startup
    load_model()
    
    # Start server
    logger.info(f"🚀 VIRIDA AI/ML Prediction Engine démarré sur le port {PORT}")
    logger.info(f"🌐 URL: http://localhost:{PORT}")
    logger.info(f"📊 Health: http://localhost:{PORT}/health")
    
    app.run(host='0.0.0.0', port=PORT, debug=False)

