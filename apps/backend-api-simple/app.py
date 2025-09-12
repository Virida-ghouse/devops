#!/usr/bin/env python3
"""
VIRIDA Backend API - Application simple
"""

import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'service': 'VIRIDA Backend API',
        'version': '1.0.0',
        'status': 'running',
        'message': 'Service Backend API opérationnel'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'virida-backend-api'
    })

@app.route('/api/data')
def get_data():
    return jsonify({
        'data': 'Données du backend VIRIDA',
        'timestamp': '2025-09-12T08:00:00Z'
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
