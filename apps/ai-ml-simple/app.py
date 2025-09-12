#!/usr/bin/env python3
"""
VIRIDA AI/ML Prediction Engine - Version Ultra-Simple
"""

import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'service': 'VIRIDA AI/ML Prediction Engine',
        'version': '1.0.0',
        'status': 'running',
        'message': 'Service AI/ML opérationnel'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'virida-ai-ml'
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
