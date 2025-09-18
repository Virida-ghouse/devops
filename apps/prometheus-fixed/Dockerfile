FROM prom/prometheus:v2.45.0

# Configuration Prometheus
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY rules.yml /etc/prometheus/rules.yml

# Créer les répertoires nécessaires
RUN mkdir -p /prometheus/data
RUN chown -R prometheus:prometheus /prometheus

# Exposer le port
EXPOSE 9090

# Variables d'environnement
ENV PROMETHEUS_CONFIG_FILE=/etc/prometheus/prometheus.yml
ENV PROMETHEUS_STORAGE_TSDB_PATH=/prometheus/data
ENV PROMETHEUS_WEB_LISTEN_ADDRESS=0.0.0.0:9090

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:9090/-/healthy || exit 1

# Démarrer Prometheus
CMD ["prometheus", "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus/data", "--web.console.libraries=/etc/prometheus/console_libraries", "--web.console.templates=/etc/prometheus/consoles", "--web.enable-lifecycle"]
