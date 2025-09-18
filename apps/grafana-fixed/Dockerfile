FROM grafana/grafana:10.2.0

# Configuration Grafana
COPY grafana.ini /etc/grafana/grafana.ini

# Créer les répertoires nécessaires
RUN mkdir -p /var/lib/grafana/dashboards
RUN mkdir -p /var/lib/grafana/provisioning/dashboards
RUN mkdir -p /var/lib/grafana/provisioning/datasources

# Exposer le port
EXPOSE 3000

# Variables d'environnement
ENV GF_SECURITY_ADMIN_PASSWORD=admin
ENV GF_SERVER_HTTP_PORT=3000
ENV GF_SERVER_ROOT_URL=https://virida-grafana.cleverapps.io

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Démarrer Grafana
CMD ["grafana-server", "--config=/etc/grafana/grafana.ini"]
