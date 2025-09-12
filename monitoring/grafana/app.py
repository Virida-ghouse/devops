#!/usr/bin/env python3
"""
VIRIDA Grafana - Application simple
"""

import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'service': 'VIRIDA Grafana',
        'version': '1.0.0',
        'status': 'running',
        'message': 'Service Grafana opérationnel'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'virida-grafana'
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
