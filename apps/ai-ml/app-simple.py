#!/usr/bin/env python3
"""
VIRIDA AI/ML - Version Ultra-Simple
"""

from flask import Flask, jsonify
import os

app = Flask(__name__)
PORT = int(os.environ.get('PORT', 8000))

@app.route('/')
def home():
    return jsonify({
        'service': 'VIRIDA AI/ML Engine',
        'status': 'running',
        'version': '1.0.0-simple',
        'message': 'Application ultra-simple qui fonctionne !'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'port': PORT
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT, debug=False)