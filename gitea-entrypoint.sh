#!/bin/sh

# Gitea Entrypoint Script for Clever Cloud
# Configure Gitea to use PostgreSQL from Clever Cloud environment variables

echo "🚀 Starting Gitea on Clever Cloud..."

# Debug: Show available PostgreSQL variables
echo "🔍 Debug - PostgreSQL variables:"
echo "  - POSTGRESQL_ADDON_URI: ${POSTGRESQL_ADDON_URI:+SET}"
echo "  - POSTGRESQL_ADDON_HOST: ${POSTGRESQL_ADDON_HOST:+SET}"
echo "  - POSTGRESQL_ADDON_PORT: ${POSTGRESQL_ADDON_PORT:+SET}"
echo "  - POSTGRESQL_ADDON_DB: ${POSTGRESQL_ADDON_DB:+SET}"
echo "  - POSTGRESQL_ADDON_USER: ${POSTGRESQL_ADDON_USER:+SET}"

# Use POSTGRESQL_ADDON_URI if available (contains all connection info with proper SSL)
if [ -n "$POSTGRESQL_ADDON_URI" ]; then
  echo "✅ Using POSTGRESQL_ADDON_URI for database configuration"
  # Parse URI: postgresql://user:password@host:port/database
  # Extract components from URI
  DB_URI="$POSTGRESQL_ADDON_URI"
  
  # Remove postgresql:// prefix
  DB_URI="${DB_URI#postgresql://}"
  
  # Extract user:password@host:port/database
  if echo "$DB_URI" | grep -q "@"; then
    # Extract user and password
    USER_PASS="${DB_URI%%@*}"
    export GITEA__database__USER="${USER_PASS%%:*}"
    export GITEA__database__PASSWD="${USER_PASS#*:}"
    
    # Extract host:port/database
    HOST_PORT_DB="${DB_URI#*@}"
    HOST_PORT="${HOST_PORT_DB%%/*}"
    export GITEA__database__NAME="${HOST_PORT_DB#*/}"
    
    # Extract host and port
    if echo "$HOST_PORT" | grep -q ":"; then
      export GITEA__database__HOST="${HOST_PORT%%:*}"
      export GITEA__database__PORT="${HOST_PORT#*:}"
    else
      export GITEA__database__HOST="$HOST_PORT"
      export GITEA__database__PORT="5432"
    fi
  fi
else
  echo "⚠️  POSTGRESQL_ADDON_URI not found, using individual variables"
  # Fallback: Extract host and port from POSTGRESQL_ADDON_HOST if it contains a port
  if [ -n "$POSTGRESQL_ADDON_HOST" ]; then
    # Check if HOST contains a port (format: host:port)
    if echo "$POSTGRESQL_ADDON_HOST" | grep -q ":"; then
      export GITEA__database__HOST=$(echo "$POSTGRESQL_ADDON_HOST" | cut -d: -f1)
      export GITEA__database__PORT=$(echo "$POSTGRESQL_ADDON_HOST" | cut -d: -f2)
    else
      export GITEA__database__HOST="$POSTGRESQL_ADDON_HOST"
      export GITEA__database__PORT="${POSTGRESQL_ADDON_PORT:-5432}"
    fi
  fi
  
  # Set database configuration from Clever Cloud variables
  export GITEA__database__NAME="${POSTGRESQL_ADDON_DB:-${GITEA__database__NAME:-gitea}}"
  export GITEA__database__USER="${POSTGRESQL_ADDON_USER:-${GITEA__database__USER}}"
  export GITEA__database__PASSWD="${POSTGRESQL_ADDON_PASSWORD:-${GITEA__database__PASSWD}}"
  
  # Ensure PORT is set if not already configured
  if [ -z "$GITEA__database__PORT" ]; then
    export GITEA__database__PORT="${POSTGRESQL_ADDON_PORT:-5432}"
  fi
fi

# Set database type
export GITEA__database__DB_TYPE="${GITEA__database__DB_TYPE:-postgres}"

# Force SSL for PostgreSQL on Clever Cloud (required for Clever Cloud PostgreSQL)
# Gitea uses different SSL mode values: disable, require, verify-ca, verify-full
export GITEA__database__SSL_MODE="require"

# Also set SSLMODE for PostgreSQL driver (some versions need this)
export GITEA__database__SSLMODE="require"

# Log configuration (without sensitive data)
echo "📊 Gitea Database Configuration:"
echo "  - Type: ${GITEA__database__DB_TYPE}"
echo "  - Host: ${GITEA__database__HOST}"
echo "  - Port: ${GITEA__database__PORT}"
echo "  - Database: ${GITEA__database__NAME}"
echo "  - User: ${GITEA__database__USER}"
echo "  - SSL Mode: ${GITEA__database__SSL_MODE}"

# Execute original Gitea entrypoint
exec /usr/bin/entrypoint

