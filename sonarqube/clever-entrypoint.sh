#!/bin/sh

# Clever Cloud SonarQube Entrypoint Script
# - SonarQube runs on 9000 (internal)
# - Nginx listens on PORT (8080), proxies to SonarQube, /health returns 200 immediately
# - Set CC_HEALTH_CHECK_PATH=/health in Clever Cloud so deployment succeeds while SonarQube starts

set -eu

echo "Starting SonarQube on Clever Cloud..."

# ---- PostgreSQL addon env vars (support multiple Clever Cloud naming styles) ----
POSTGRES_HOST="${POSTGRESQL_ADDON_HOST:-${CC_POSTGRESQL_ADDON_HOST:-}}"
POSTGRES_PORT="${POSTGRESQL_ADDON_PORT:-${CC_POSTGRESQL_ADDON_PORT:-}}"
POSTGRES_DB="${POSTGRESQL_ADDON_DB:-${CC_POSTGRESQL_ADDON_DB:-}}"
POSTGRES_USER="${POSTGRESQL_ADDON_USER:-${CC_POSTGRESQL_ADDON_USER:-}}"
POSTGRES_PASSWORD="${POSTGRESQL_ADDON_PASSWORD:-${CC_POSTGRESQL_ADDON_PASSWORD:-}}"

if [ -z "${POSTGRES_HOST}" ] || [ -z "${POSTGRES_PORT}" ] || [ -z "${POSTGRES_DB}" ] || [ -z "${POSTGRES_USER}" ] || [ -z "${POSTGRES_PASSWORD}" ]; then
  POSTGRES_URI="${POSTGRESQL_ADDON_URI:-${POSTGRESQL_ADDON_URL:-${CC_POSTGRESQL_ADDON_URI:-${CC_POSTGRESQL_ADDON_URL:-}}}}"
  if [ -n "${POSTGRES_URI}" ]; then
    _uri_no_proto="${POSTGRES_URI#postgresql://}"
    _uri_no_proto="${_uri_no_proto#postgres://}"
    _creds="${_uri_no_proto%%@*}"
    _hostpart="${_uri_no_proto#*@}"
    POSTGRES_USER="${_creds%%:*}"
    POSTGRES_PASSWORD="${_creds#*:}"
    POSTGRES_HOST="${_hostpart%%:*}"
    _port_and_db="${_hostpart#*:}"
    POSTGRES_PORT="${_port_and_db%%/*}"
    POSTGRES_DB="${_port_and_db#*/}"
  fi
fi

if [ -z "${POSTGRES_HOST}" ] || [ -z "${POSTGRES_PORT}" ] || [ -z "${POSTGRES_DB}" ] || [ -z "${POSTGRES_USER}" ] || [ -z "${POSTGRES_PASSWORD}" ]; then
  echo "[ERROR] Missing PostgreSQL addon env vars."
  exit 1
fi

export SONAR_JDBC_USERNAME="${POSTGRES_USER}"
export SONAR_JDBC_PASSWORD="${POSTGRES_PASSWORD}"
export SONAR_JDBC_URL="jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=require"

# SonarQube on 9000 (internal); nginx listens on PORT (8080) and proxies
export SONAR_WEB_PORT="9000"
export SONAR_WEB_CONTEXT="${SONAR_WEB_CONTEXT:-/}"

echo "SonarQube configuration:"
echo "  - DB: ${POSTGRES_DB} @ ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo "  - Web: internal port 9000, nginx proxy on ${PORT:-8080}"

# Start SonarQube in background (as sonarqube user, preserve env vars)
su -p sonarqube -c "/opt/sonarqube/docker/entrypoint.sh" &

# Give SonarQube a moment to begin startup
sleep 3

# Start nginx in foreground (listens on 8080, /health returns 200 immediately)
exec nginx -g "daemon off;"

