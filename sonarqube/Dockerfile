FROM sonarqube:10-community

# Install nginx (reverse proxy) + curl
USER root
RUN apt-get update && apt-get install -y nginx curl && rm -rf /var/lib/apt/lists/*

# Add Clever Cloud entrypoint and nginx config
ADD clever-entrypoint.sh /opt/sonarqube/docker/
ADD nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /opt/sonarqube/docker/clever-entrypoint.sh

# Entrypoint runs as root to start nginx; it starts SonarQube as sonarqube user
# Set entrypoint
ENTRYPOINT ["/opt/sonarqube/docker/clever-entrypoint.sh"]

