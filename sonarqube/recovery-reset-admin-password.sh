#!/bin/sh
set -eu

echo "SonarQube admin one-shot recovery"
echo "================================="

POSTGRES_HOST="${POSTGRESQL_ADDON_HOST:-${CC_POSTGRESQL_ADDON_HOST:-}}"
POSTGRES_PORT="${POSTGRESQL_ADDON_PORT:-${CC_POSTGRESQL_ADDON_PORT:-}}"
POSTGRES_DB="${POSTGRESQL_ADDON_DB:-${CC_POSTGRESQL_ADDON_DB:-}}"
POSTGRES_USER="${POSTGRESQL_ADDON_USER:-${CC_POSTGRESQL_ADDON_USER:-}}"
POSTGRES_PASSWORD="${POSTGRESQL_ADDON_PASSWORD:-${CC_POSTGRESQL_ADDON_PASSWORD:-}}"

if [ -z "${POSTGRES_HOST}" ] || [ -z "${POSTGRES_PORT}" ] || [ -z "${POSTGRES_DB}" ] || [ -z "${POSTGRES_USER}" ] || [ -z "${POSTGRES_PASSWORD}" ]; then
  echo "[ERROR] Missing PostgreSQL addon env vars."
  exit 1
fi

# Default keeps backward compatibility with previous emergency hash.
# Override with SONAR_ADMIN_BCRYPT_HASH to enforce your own secret.
ADMIN_BCRYPT_HASH="${SONAR_ADMIN_BCRYPT_HASH:-\$2a\$10\$6Zy6r6fWk1P42VvJpW1VcOLz93P.IYqSmcGjpFSr1g9FRuyfcQiKW}"

export PGPASSWORD="${POSTGRES_PASSWORD}"
psql \
  --host="${POSTGRES_HOST}" \
  --port="${POSTGRES_PORT}" \
  --username="${POSTGRES_USER}" \
  --dbname="${POSTGRES_DB}" \
  --set=ON_ERROR_STOP=1 \
  --set=admin_hash="${ADMIN_BCRYPT_HASH}" <<'SQL'
UPDATE users
SET crypted_password = :'admin_hash',
    salt = NULL,
    hash_method = 'BCRYPT',
    reset_password = true
WHERE login = 'admin';
SQL
unset PGPASSWORD

echo "[OK] Admin password reset flag applied."
echo "[INFO] Log in as admin and change password immediately."
