#!/bin/sh

# Clever Cloud SonarQube Entrypoint Script
# SonarQube listens directly on PORT (set by Clever Cloud, default 8080)
# SONAR_WEB_PORT is set to $PORT so no proxy needed

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

# SonarQube listens directly on Clever Cloud's PORT (no nginx proxy)
export SONAR_WEB_PORT="${PORT:-9000}"
export SONAR_WEB_CONTEXT="${SONAR_WEB_CONTEXT:-/}"
export SONAR_ES_BOOTSTRAP_CHECKS_DISABLE="${SONAR_ES_BOOTSTRAP_CHECKS_DISABLE:-true}"
export SONAR_SEARCH_JAVAOPTS="${SONAR_SEARCH_JAVAOPTS:--Xms256m -Xmx512m}"

echo "SonarQube configuration:"
echo "  - DB: ${POSTGRES_DB} @ ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo "  - Web port: ${SONAR_WEB_PORT}"

exec /opt/sonarqube/docker/entrypoint.sh
