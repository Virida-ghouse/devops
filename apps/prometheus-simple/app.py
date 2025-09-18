#!/usr/bin/env python3
"""
VIRIDA Prometheus - Installation et démarrage automatique
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
PROMETHEUS_PORT = int(os.environ.get('PROMETHEUS_PORT', 9090))

def install_prometheus():
    """Installer Prometheus"""
    try:
        print("🔧 Installation de Prometheus...")
        
        # Télécharger Prometheus
        subprocess.run([
            'wget', '-q', 
            'https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz'
        ], check=True)
        
        # Extraire
        subprocess.run([
            'tar', '-xzf', 'prometheus-2.45.0.linux-amd64.tar.gz'
        ], check=True)
        
        # Se déplacer dans le dossier
        os.chdir('prometheus-2.45.0')
        
        # Créer les répertoires
        os.makedirs('data', exist_ok=True)
        
        # Créer la configuration Prometheus
        config = f"""
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:{PROMETHEUS_PORT}']

  - job_name: 'virida-apps'
    static_configs:
      - targets: 
        - 'virida-frontend-3d.cleverapps.io:8080'
        - 'virida-ai-ml.cleverapps.io:8080'
        - 'virida-grafana-v2.cleverapps.io:3000'
        - 'gitea-drone-ci.cleverapps.io:8080'
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'virida-environmental'
    static_configs:
      - targets: ['virida-ai-ml.cleverapps.io:8080']
    metrics_path: '/api/metrics'
    scrape_interval: 60s
"""
        
        with open('prometheus.yml', 'w') as f:
            f.write(config)
        
        print("✅ Prometheus installé avec succès")
        return True
        
    except Exception as e:
        print(f"❌ Erreur installation Prometheus: {e}")
        return False

def start_prometheus():
    """Démarrer Prometheus"""
    try:
        print("🚀 Démarrage de Prometheus...")
        
        # Variables d'environnement pour Prometheus
        env = os.environ.copy()
        env['PROMETHEUS_CONFIG_FILE'] = 'prometheus.yml'
        env['PROMETHEUS_STORAGE_TSDB_PATH'] = 'data'
        env['PROMETHEUS_WEB_LISTEN_ADDRESS'] = f'0.0.0.0:{PROMETHEUS_PORT}'
        
        # Démarrer Prometheus
        subprocess.Popen([
            './prometheus',
            '--config.file=prometheus.yml',
            '--storage.tsdb.path=data',
            '--web.console.libraries=console_libraries',
            '--web.console.templates=consoles',
            '--web.enable-lifecycle'
        ], env=env)
        
        print(f"✅ Prometheus démarré sur le port {PROMETHEUS_PORT}")
        return True
        
    except Exception as e:
        print(f"❌ Erreur démarrage Prometheus: {e}")
        return False

def check_prometheus_health():
    """Vérifier la santé de Prometheus"""
    try:
        response = requests.get(f'http://localhost:{PROMETHEUS_PORT}/-/healthy', timeout=5)
        return response.status_code == 200
    except:
        return False

# Démarrer Prometheus en arrière-plan
def init_prometheus():
    """Initialiser Prometheus"""
    if install_prometheus():
        time.sleep(2)  # Attendre l'installation
        start_prometheus()
        
        # Attendre que Prometheus soit prêt
        for i in range(30):  # 30 tentatives
            if check_prometheus_health():
                print("✅ Prometheus est prêt !")
                break
            time.sleep(2)
        else:
            print("⚠️ Prometheus n'est pas encore prêt")

# Démarrer l'initialisation en arrière-plan
threading.Thread(target=init_prometheus, daemon=True).start()

@app.route('/')
def home():
    prometheus_status = "running" if check_prometheus_health() else "starting"
    return jsonify({
        'service': 'VIRIDA Prometheus Manager',
        'status': prometheus_status,
        'prometheus_url': f'http://localhost:{PROMETHEUS_PORT}',
        'prometheus_external': 'https://virida-prometheus-simple.cleverapps.io',
        'message': 'Prometheus installation and management service'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'prometheus_ready': check_prometheus_health(),
        'port': PORT
    })

@app.route('/prometheus/status')
def prometheus_status():
    if check_prometheus_health():
        return jsonify({
            'status': 'running',
            'url': f'http://localhost:{PROMETHEUS_PORT}',
            'external_url': 'https://virida-prometheus-simple.cleverapps.io'
        })
    else:
        return jsonify({
            'status': 'starting',
            'message': 'Prometheus is starting up, please wait...'
        })

@app.route('/metrics')
def metrics():
    """Endpoint de métriques pour Prometheus"""
    return jsonify({
        'virida_app_info{version="1.0.0",service="prometheus-manager"}': 1,
        'virida_app_uptime_seconds': time.time() - os.path.getctime('/proc/1'),
        'virida_app_requests_total': 1
    })

if __name__ == '__main__':
    print("🚀 Démarrage du gestionnaire Prometheus VIRIDA...")
    app.run(host='0.0.0.0', port=PORT, debug=False)
