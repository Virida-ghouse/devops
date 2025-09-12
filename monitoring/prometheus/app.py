#!/usr/bin/env python3
"""
VIRIDA Prometheus - Application simple
"""

import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'service': 'VIRIDA Prometheus',
        'version': '1.0.0',
        'status': 'running',
        'message': 'Service Prometheus opérationnel'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'virida-prometheus'
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
