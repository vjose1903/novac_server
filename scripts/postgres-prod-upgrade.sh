#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
case "$MODE" in
  dev)
    COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"
    RAILS_ENV="development"
    DB_SERVICE="${DB_SERVICE:-db-dev}"
    ;;
  prod)
    COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"
    RAILS_ENV="production"
    DB_SERVICE="${DB_SERVICE:-db-prod}"
    ;;
  *)
    echo "Uso: $0 dev|prod"
    exit 2
    ;;
esac
PROD_COMPOSE_FILE="${PROD_COMPOSE_FILE:-docker-compose.prod.yml}"
DEV_COMPOSE_FILE="${DEV_COMPOSE_FILE:-docker-compose.yml}"
PROD_DB_SERVICE="${PROD_DB_SERVICE:-db-prod}"
DEV_DB_SERVICE="${DEV_DB_SERVICE:-db-dev}"
SOURCE_IMAGE="${SOURCE_IMAGE:-postgres:13.7}"
TARGET_IMAGE="${TARGET_IMAGE:-postgres:18.6}"
HEALTH_TIMEOUT_SECONDS="${HEALTH_TIMEOUT_SECONDS:-120}"
FORCE_RESTORE="${FORCE_RESTORE:-0}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

CLIENT_FILE="$ROOT_DIR/config_setup/actual_cliente.txt"
SETUP_FILE="$ROOT_DIR/scripts/setup.js"

if [ ! -f "$CLIENT_FILE" ] || [ ! -f "$SETUP_FILE" ]; then
  echo "No se encontró config_setup/actual_cliente.txt o scripts/setup.js."
  exit 1
fi

CLIENT="$(tr -d '[:space:]' < "$CLIENT_FILE")"
if [ -z "$CLIENT" ]; then
  echo "config_setup/actual_cliente.txt está vacío."
  exit 1
fi

DB_PATH="$(node -e 'const { setup } = require(process.argv[1]); const client = process.argv[2]; if (!setup[client]?.DB_PATH) process.exit(2); process.stdout.write(setup[client].DB_PATH)' "$SETUP_FILE" "$CLIENT")" || {
  echo "El cliente '$CLIENT' no tiene DB_PATH definido en scripts/setup.js."
  exit 1
}
ALMACEN="$(node -e 'const { setup } = require(process.argv[1]); const client = process.argv[2]; if (!setup[client]?.ALMACEN) process.exit(2); process.stdout.write(setup[client].ALMACEN)' "$SETUP_FILE" "$CLIENT")" || {
  echo "El cliente '$CLIENT' no tiene ALMACEN definido en scripts/setup.js."
  exit 1
}
if [ "$MODE" = "prod" ]; then
  REQUIRED_DATABASE="${ALMACEN}_production"
else
  REQUIRED_DATABASE="${ALMACEN}_development"
fi

if [[ ! "$DB_PATH" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "DB_PATH inválido para el cliente '$CLIENT': $DB_PATH"
  exit 1
fi
if [[ ! "$REQUIRED_DATABASE" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Nombre de base inválido para el cliente '$CLIENT': $REQUIRED_DATABASE"
  exit 1
fi

SOURCE_DATA_DIR="${SOURCE_DATA_DIR:-tmp/$DB_PATH}"
TARGET_DATA_DIR="${TARGET_DATA_DIR:-${SOURCE_DATA_DIR}-pg18}"
RESTORE_MARKER="$ROOT_DIR/${TARGET_DATA_DIR}.restore-complete"
POSTGRES_USER="${POSTGRES_USER:-novacSystem}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-N0v@cgu@rd}"

if [ "$FORCE_RESTORE" != "0" ] && [ "$FORCE_RESTORE" != "1" ]; then
  echo "FORCE_RESTORE solo admite 0 o 1."
  exit 1
fi

if [ "$SOURCE_DATA_DIR" = "$TARGET_DATA_DIR" ]; then
  echo "El origen y el destino no pueden ser la misma carpeta."
  exit 1
fi
if [ ! -d "$ROOT_DIR/$SOURCE_DATA_DIR" ]; then
  echo "No existe la base de datos origen: $SOURCE_DATA_DIR"
  exit 1
fi

find_rails_service() {
  local compose_file="$1"
  local db_service="$2"
  local rails_env="$3"
  local client_almacen="$4"

  docker compose -f "$compose_file" config --format json | node -e '
let raw = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", chunk => raw += chunk);
process.stdin.on("end", () => {
  const services = JSON.parse(raw).services || {};
  const matches = Object.entries(services).filter(([, service]) => {
    const dependencies = service.depends_on || {};
    const names = Array.isArray(dependencies) ? dependencies : Object.keys(dependencies);
    const environment = service.environment || {};
    return names.includes(process.argv[1]) &&
      environment.RAILS_ENV === process.argv[2] &&
      environment.ALMACEN === process.argv[3] &&
      !(service.profiles || []).length;
  }).map(([name]) => name);
  if (matches.length !== 1) {
    console.error(`No se encontró un servicio Rails ${process.argv[2]} para ALMACEN=${process.argv[3]} dependiente de ${process.argv[1]}; encontrados: ${matches.join(", ") || "ninguno"}`);
    process.exit(2);
  }
  process.stdout.write(matches[0]);
});
' "$db_service" "$rails_env" "$client_almacen"
}

RAILS_SERVICE="$(find_rails_service "$COMPOSE_FILE" "$DB_SERVICE" "$RAILS_ENV" "$ALMACEN")" || exit 1
PROD_RAILS_SERVICE="$(find_rails_service "$PROD_COMPOSE_FILE" "$PROD_DB_SERVICE" production "$ALMACEN")" || exit 1
DEV_RAILS_SERVICE="$(find_rails_service "$DEV_COMPOSE_FILE" "$DEV_DB_SERVICE" development "$ALMACEN")" || exit 1

if ! docker compose -f "$COMPOSE_FILE" config --services | grep -Fxq "$DB_SERVICE"; then
  echo "No existe el servicio de base de datos '$DB_SERVICE' en $COMPOSE_FILE."
  exit 1
fi

echo "Cliente: $CLIENT ($MODE)"
echo "Servicio Rails: $RAILS_SERVICE"
echo "Servicio DB: $DB_SERVICE"
echo "Base requerida: $REQUIRED_DATABASE"
echo "Origen PostgreSQL 13: $SOURCE_DATA_DIR"
echo "Destino PostgreSQL 18: $TARGET_DATA_DIR"

RESTORE_COMPLETE=0
if [ -f "$RESTORE_MARKER" ] && [ -d "$ROOT_DIR/$TARGET_DATA_DIR" ]; then
  if grep -Fxq "status=complete" "$RESTORE_MARKER" && \
    grep -Fxq "client=$CLIENT" "$RESTORE_MARKER" && \
    grep -Fxq "source=$SOURCE_DATA_DIR" "$RESTORE_MARKER" && \
    grep -Fxq "target=$TARGET_DATA_DIR" "$RESTORE_MARKER" && \
    grep -Fxq "image=$TARGET_IMAGE" "$RESTORE_MARKER"; then
    if grep -Fxq "database=$REQUIRED_DATABASE" "$RESTORE_MARKER"; then
      RESTORE_COMPLETE=1
    elif [ "$FORCE_RESTORE" != "1" ]; then
      echo "El destino ya tiene una restauración registrada, pero no incluye '$REQUIRED_DATABASE'."
      echo "No se reemplazará automáticamente; confirma el origen correcto o usa FORCE_RESTORE=1 para intentar restaurarlo de nuevo."
      exit 1
    fi
  fi
fi

if [ "$RESTORE_COMPLETE" = "1" ] && [ "$FORCE_RESTORE" != "1" ]; then
  echo "Restauración previa verificada; se omitirá el dump/restore."
fi

# Desarrollo y producción comparten el puerto local, el volumen PostgreSQL 18 y
# el nombre del contenedor Rails; detener ambos modos antes de restaurar.
docker compose -f "$PROD_COMPOSE_FILE" stop "$PROD_RAILS_SERVICE" "$PROD_DB_SERVICE"
docker compose -f "$DEV_COMPOSE_FILE" stop "$DEV_RAILS_SERVICE" "$DEV_DB_SERVICE"

# Siempre reconstruye el destino desde el origen. El script de staging archiva
# primero cualquier volumen destino existente y lo restaura si el proceso falla.
if [ "$RESTORE_COMPLETE" != "1" ] || [ "$FORCE_RESTORE" = "1" ]; then
  COMPOSE_FILE="$COMPOSE_FILE" \
  SOURCE_IMAGE="$SOURCE_IMAGE" \
  TARGET_IMAGE="$TARGET_IMAGE" \
  SOURCE_DATA_DIR="$SOURCE_DATA_DIR" \
  TARGET_DATA_DIR="$TARGET_DATA_DIR" \
  POSTGRES_USER="$POSTGRES_USER" \
  POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  REQUIRED_DATABASE="$REQUIRED_DATABASE" \
  RESTORE_CLIENT="$CLIENT" \
  RESTORE_MARKER="$RESTORE_MARKER" \
  FORCE_TARGET_RESET=1 \
    ./scripts/postgres-upgrade-staging.sh
fi

# Recrea el servicio para que quede conectado a la red Compose activa. Un
# contenedor antiguo puede quedar arrancado pero sin DNS para el servicio DB.
docker compose -f "$COMPOSE_FILE" up -d --force-recreate "$DB_SERVICE"

ready=0
for ((attempt = 1; attempt <= HEALTH_TIMEOUT_SECONDS; attempt++)); do
  if docker compose -f "$COMPOSE_FILE" exec -T "$DB_SERVICE" pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
if [ "$ready" -ne 1 ]; then
  echo "PostgreSQL no quedó listo en ${HEALTH_TIMEOUT_SECONDS}s. La aplicación permanece detenida."
  exit 1
fi

if ! docker compose -f "$COMPOSE_FILE" exec -T "$DB_SERVICE" psql -U "$POSTGRES_USER" -d postgres -Atc \
  "select datname from pg_database where datname = '$REQUIRED_DATABASE'" | grep -Fxq "$REQUIRED_DATABASE"; then
  echo "La base '$REQUIRED_DATABASE' no está presente en el destino PostgreSQL 18."
  echo "No se ejecutarán migraciones ni se iniciará Rails. Revisa el registro de restauración o usa FORCE_RESTORE=1 para volver a copiar desde el origen."
  exit 1
fi

# Ejecuta las migraciones Rails antes de exponer la aplicación restaurada.
MIGRATION_CONTAINER="novac-db-migrate-${CLIENT}-${MODE}-$$"
docker compose -f "$COMPOSE_FILE" run --rm --no-deps --name "$MIGRATION_CONTAINER" \
  "$RAILS_SERVICE" bundle exec rails db:migrate

docker compose -f "$COMPOSE_FILE" up -d --force-recreate "$RAILS_SERVICE"

HEALTH_STATUS="000"
HEALTH_BODY=""
for ((attempt = 1; attempt <= HEALTH_TIMEOUT_SECONDS; attempt++)); do
  HEALTH_OUTPUT="$(docker compose -f "$COMPOSE_FILE" exec -T "$RAILS_SERVICE" sh -lc 'curl -sS -w "\n%{http_code}" -H "Host: localhost" "http://127.0.0.1:${PORT:-3000}/up"' 2>/dev/null || true)"
  if [[ "$HEALTH_OUTPUT" == *$'\n'* ]]; then
    HEALTH_STATUS="${HEALTH_OUTPUT##*$'\n'}"
    HEALTH_BODY="${HEALTH_OUTPUT%$'\n'*}"
    [ "$HEALTH_STATUS" = "200" ] && break
  fi
  sleep 1
done
if [ "$HEALTH_STATUS" != "200" ]; then
  echo "Health check falló con HTTP $HEALTH_STATUS después de ${HEALTH_TIMEOUT_SECONDS}s:"
  printf '%s\n' "$HEALTH_BODY"
  echo "Revisa la base restaurada y conserva el volumen PostgreSQL 13 para rollback."
  exit 1
fi

echo "$HEALTH_BODY"
echo "Upgrade PostgreSQL completado para $CLIENT ($MODE)."
