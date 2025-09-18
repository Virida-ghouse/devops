#!/usr/bin/env python3
"""
VIRIDA Grafana - Installation et démarrage automatique
"""

import os
import subprocess
import threading
import time
from flask import Flask, jsonify
import requests

app = Flask(__name__)
PORT = int(os.environ.get('PORT', 8080))

# Variables d'environnement
GRAFANA_PORT = int(os.environ.get('GRAFANA_PORT', 3000))
GRAFANA_PASSWORD = os.environ.get('GRAFANA_PASSWORD', 'admin')

def install_grafana():
    """Installer Grafana"""
    try:
        print("🔧 Installation de Grafana...")
        
        # Télécharger Grafana
        subprocess.run([
            'wget', '-q', 
            'https://dl.grafana.com/oss/release/grafana-10.2.0.linux-amd64.tar.gz'
        ], check=True)
        
        # Extraire
        subprocess.run([
            'tar', '-xzf', 'grafana-10.2.0.linux-amd64.tar.gz'
        ], check=True)
        
        # Se déplacer dans le dossier
        os.chdir('grafana-10.2.0')
        
        # Créer les répertoires
        os.makedirs('data', exist_ok=True)
        os.makedirs('logs', exist_ok=True)
        os.makedirs('plugins', exist_ok=True)
        
        print("✅ Grafana installé avec succès")
        return True
        
    except Exception as e:
        print(f"❌ Erreur installation Grafana: {e}")
        return False

def start_grafana():
    """Démarrer Grafana"""
    try:
        print("🚀 Démarrage de Grafana...")
        
        # Variables d'environnement pour Grafana
        env = os.environ.copy()
        env['GF_SECURITY_ADMIN_PASSWORD'] = GRAFANA_PASSWORD
        env['GF_SERVER_HTTP_PORT'] = str(GRAFANA_PORT)
        env['GF_SERVER_ROOT_URL'] = f'https://virida-grafana-v2.cleverapps.io'
        env['GF_DATABASE_TYPE'] = 'sqlite3'
        env['GF_DATABASE_PATH'] = 'data/grafana.db'
        
        # Démarrer Grafana
        subprocess.Popen([
            './bin/grafana-server',
            '--config=conf/defaults.ini',
            '--homepath=.',
            '--packaging=tar.bz2'
        ], env=env)
        
        print(f"✅ Grafana démarré sur le port {GRAFANA_PORT}")
        return True
        
    except Exception as e:
        print(f"❌ Erreur démarrage Grafana: {e}")
        return False

def check_grafana_health():
    """Vérifier la santé de Grafana"""
    try:
        response = requests.get(f'http://localhost:{GRAFANA_PORT}/api/health', timeout=5)
        return response.status_code == 200
    except:
        return False

# Démarrer Grafana en arrière-plan
def init_grafana():
    """Initialiser Grafana"""
    if install_grafana():
        time.sleep(2)  # Attendre l'installation
        start_grafana()
        
        # Attendre que Grafana soit prêt
        for i in range(30):  # 30 tentatives
            if check_grafana_health():
                print("✅ Grafana est prêt !")
                break
            time.sleep(2)
        else:
            print("⚠️ Grafana n'est pas encore prêt")

# Démarrer l'initialisation en arrière-plan
threading.Thread(target=init_grafana, daemon=True).start()

@app.route('/')
def home():
    grafana_status = "running" if check_grafana_health() else "starting"
    return jsonify({
        'service': 'VIRIDA Grafana Manager',
        'status': grafana_status,
        'grafana_url': f'http://localhost:{GRAFANA_PORT}',
        'grafana_external': 'https://virida-grafana-v2.cleverapps.io',
        'admin_password': GRAFANA_PASSWORD,
        'message': 'Grafana installation and management service'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'grafana_ready': check_grafana_health(),
        'port': PORT
    })

@app.route('/grafana/status')
def grafana_status():
    if check_grafana_health():
        return jsonify({
            'status': 'running',
            'url': f'http://localhost:{GRAFANA_PORT}',
            'external_url': 'https://virida-grafana-v2.cleverapps.io'
        })
    else:
        return jsonify({
            'status': 'starting',
            'message': 'Grafana is starting up, please wait...'
        })

if __name__ == '__main__':
    print("🚀 Démarrage du gestionnaire Grafana VIRIDA...")
    app.run(host='0.0.0.0', port=PORT, debug=False)
