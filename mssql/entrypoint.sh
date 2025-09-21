#!/usr/bin/env bash
set -euo pipefail

# This entrypoint:
# 1) Start sqlservr in background
# 2) Wait until it is ready
# 3) Run idempotent init SQL to create DB/login/user/grants for Keycloak
# 4) Keep container in foreground

# Helper: resolve sqlcmd path
resolve_sqlcmd() {
  if [[ -x "/opt/mssql-tools18/bin/sqlcmd" ]]; then
    echo "/opt/mssql-tools18/bin/sqlcmd"
    return
  fi
  if [[ -x "/opt/mssql-tools/bin/sqlcmd" ]]; then
    echo "/opt/mssql-tools/bin/sqlcmd"
    return
  fi
  # Fallback: assume in PATH
  echo "sqlcmd"
}

SQLCMD_BIN="$(resolve_sqlcmd)"

# Start SQL Server
/opt/mssql/bin/sqlservr &

# Wait for ready
echo "Waiting for SQL Server to be available..."
TRIES=0
MAX_TRIES=60
SLEEP_SECS=2

EXTRA_ARG=""
if [[ "${DEV_TRUST_SQLCMD:-true}" == "true" ]]; then
  # -C: Trust server certificate (DEV only)
  EXTRA_ARG="-C"
fi

until "${SQLCMD_BIN}" -S localhost -U sa -P "${SA_PASSWORD}" -Q "SELECT 1" ${EXTRA_ARG} >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [[ "$TRIES" -ge "$MAX_TRIES" ]]; then
    echo "ERROR: SQL Server did not become ready in time."
    exit 1
  fi
  sleep "${SLEEP_SECS}"
done

echo "SQL Server is ready. Running init SQL..."

# Run init script with sqlcmd variables
# NOTE: pass KEYCLOAK_DB_PASSWORD as sqlcmd variable for secure quoting inside T-SQL
"${SQLCMD_BIN}" -S localhost -U sa -P "${SA_PASSWORD}" ${EXTRA_ARG} \
  -v KEYCLOAK_DB_PASSWORD="${KEYCLOAK_DB_PASSWORD}" \
  -b -i "/docker-init/01-create-db-and-user.sql"

echo "Init SQL completed."

# Foreground: wait on sqlservr
wait -n
