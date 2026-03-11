FROM sonarqube:10-community

# Install curl only (no nginx - SonarQube listens directly on PORT)
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Add Clever Cloud entrypoint
ADD clever-entrypoint.sh /opt/sonarqube/docker/
RUN chmod +x /opt/sonarqube/docker/clever-entrypoint.sh

# Run as sonarqube user (SonarQube refuses to start as root)
USER sonarqube
ENTRYPOINT ["/opt/sonarqube/docker/clever-entrypoint.sh"]
