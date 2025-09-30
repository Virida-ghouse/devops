#!/bin/sh

# Clever Cloud SonarQube Entrypoint Script
# This script configures SonarQube to work with Clever Cloud PostgreSQL addon

echo "🚀 Starting SonarQube on Clever Cloud..."

# Export PostgreSQL environment variables for SonarQube
export SONAR_JDBC_USERNAME=$POSTGRESQL_ADDON_USER
export SONAR_JDBC_PASSWORD=$POSTGRESQL_ADDON_PASSWORD
export SONAR_JDBC_URL="jdbc:postgresql://${POSTGRESQL_ADDON_HOST}:${POSTGRESQL_ADDON_PORT}/${POSTGRESQL_ADDON_DB}"

# Set additional SonarQube configuration
export SONAR_WEB_PORT=8080
export SONAR_WEB_CONTEXT=/

# Log configuration
echo "📊 SonarQube Configuration:"
echo "  - Database: ${POSTGRESQL_ADDON_DB}"
echo "  - Host: ${POSTGRESQL_ADDON_HOST}:${POSTGRESQL_ADDON_PORT}"
echo "  - User: ${POSTGRESQL_ADDON_USER}"
echo "  - Web Port: ${SONAR_WEB_PORT}"

# Execute original SonarQube entrypoint
exec /opt/sonarqube/docker/entrypoint.sh
