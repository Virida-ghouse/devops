#!/bin/sh

# Clever Cloud SonarQube Entrypoint Script
# This script configures SonarQube to work with Clever Cloud PostgreSQL addon

set -eu

echo "Starting SonarQube on Clever Cloud..."

# ---- PostgreSQL addon env vars (support multiple Clever Cloud naming styles) ----
# Preferred (documented in this repo): POSTGRESQL_ADDON_HOST/PORT/DB/USER/PASSWORD
# Fallbacks: CC_POSTGRESQL_ADDON_* and URI-style variables when present.
POSTGRES_HOST="${POSTGRESQL_ADDON_HOST:-${CC_POSTGRESQL_ADDON_HOST:-}}"
POSTGRES_PORT="${POSTGRESQL_ADDON_PORT:-${CC_POSTGRESQL_ADDON_PORT:-}}"
POSTGRES_DB="${POSTGRESQL_ADDON_DB:-${CC_POSTGRESQL_ADDON_DB:-}}"
POSTGRES_USER="${POSTGRESQL_ADDON_USER:-${CC_POSTGRESQL_ADDON_USER:-}}"
POSTGRES_PASSWORD="${POSTGRESQL_ADDON_PASSWORD:-${CC_POSTGRESQL_ADDON_PASSWORD:-}}"

if [ -z "${POSTGRES_HOST}" ] || [ -z "${POSTGRES_PORT}" ] || [ -z "${POSTGRES_DB}" ] || [ -z "${POSTGRES_USER}" ] || [ -z "${POSTGRES_PASSWORD}" ]; then
  # Try URI variables (best-effort) only if the classic vars are missing
  POSTGRES_URI="${POSTGRESQL_ADDON_URI:-${POSTGRESQL_ADDON_URL:-${CC_POSTGRESQL_ADDON_URI:-${CC_POSTGRESQL_ADDON_URL:-}}}}"
  if [ -n "${POSTGRES_URI}" ]; then
    # Expected formats:
    # - postgres://user:pass@host:port/db
    # - postgresql://user:pass@host:port/db
    # Note: shell parsing is intentionally simple and assumes no special characters needing URL decoding.
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
  echo "        Expected: POSTGRESQL_ADDON_HOST/PORT/DB/USER/PASSWORD (or CC_POSTGRESQL_ADDON_*)."
  echo "        Optional fallback: POSTGRESQL_ADDON_URI / POSTGRESQL_ADDON_URL."
  exit 1
fi

export SONAR_JDBC_USERNAME="${POSTGRES_USER}"
export SONAR_JDBC_PASSWORD="${POSTGRES_PASSWORD}"
export SONAR_JDBC_URL="jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

# Set additional SonarQube configuration
# IMPORTANT: Prefer SONAR_WEB_PORT (repo config uses 9000). Only fall back to PORT when SONAR_WEB_PORT
# isn't provided, for compatibility with platforms enforcing a dynamic bind port.
export SONAR_WEB_PORT="${SONAR_WEB_PORT:-${PORT:-9000}}"
export SONAR_WEB_CONTEXT="${SONAR_WEB_CONTEXT:-/}"

# Log configuration
echo "SonarQube configuration:"
echo "  - DB: ${POSTGRES_DB}"
echo "  - Host: ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo "  - User: ${POSTGRES_USER}"
echo "  - Web port: ${SONAR_WEB_PORT}"

# Execute original SonarQube entrypoint
exec /opt/sonarqube/docker/entrypoint.sh
