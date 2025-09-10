#!/usr/bin/env python3
"""
VIRIDA Grafana - Version Ultra-Simple
"""

from flask import Flask, jsonify, send_file
import os

app = Flask(__name__)
PORT = int(os.environ.get('PORT', 8080))

@app.route('/')
def home():
    return jsonify({
        'service': 'VIRIDA Grafana',
        'status': 'running',
        'version': '1.0.0-simple',
        'message': 'Grafana ultra-simple qui fonctionne !',
        'url': f'http://localhost:{PORT}'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'port': PORT
    })

@app.route('/api/health')
def api_health():
    return jsonify({
        'status': 'healthy',
        'service': 'grafana-simple'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT, debug=False)
