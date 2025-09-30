#!/bin/bash

# PostgreSQL Environment Variables Export Script
# This script exports the PostgreSQL connection variables for Clever Cloud

echo "Exporting PostgreSQL environment variables..."

# Export PostgreSQL environment variables
export POSTGRESQL_ADDON_HOST="bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com"
export POSTGRESQL_ADDON_DB="bjduvaldxkbwljy3uuel"
export POSTGRESQL_ADDON_USER="uncer3i7fyqs2zeult6r"
export POSTGRESQL_ADDON_PORT="50013"
export POSTGRESQL_ADDON_PASSWORD="WuobPl6Nyk9X0Z4DKF7BlxE55z2buu"
export POSTGRESQL_ADDON_URI="postgresql://uncer3i7fyqs2zeult6r:WuobPl6Nyk9X0Z4DKF7BlxE55z2buu@bjduvaldxkbwljy3uuel-postgresql.services.clever-cloud.com:5432/bjduvaldxkbwljy3uuel"

echo "PostgreSQL environment variables exported successfully!"
echo ""
echo "Current PostgreSQL configuration:"
echo "Host: $POSTGRESQL_ADDON_HOST"
echo "Database: $POSTGRESQL_ADDON_DB"
echo "User: $POSTGRESQL_ADDON_USER"
echo "Port: $POSTGRESQL_ADDON_PORT"
echo "URI: $POSTGRESQL_ADDON_URI"
echo ""
echo "To make these variables persistent, add them to your ~/.bashrc or ~/.zshrc file"
echo "Or source this script: source scripts/export-postgres-env.sh"



