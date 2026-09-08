#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"
RAILS_SERVICE="${RAILS_SERVICE:-}"
DB_SERVICE="${DB_SERVICE:-db-prod}"
SOURCE_DATA_DIR="${SOURCE_DATA_DIR:-tmp/db-agrodemi-data}"
TARGET_DATA_DIR="${TARGET_DATA_DIR:-${SOURCE_DATA_DIR}-pg18}"
FORCE_TARGET_RESET="${FORCE_TARGET_RESET:-0}"
HEALTH_URL="${HEALTH_URL:-}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -z "$RAILS_SERVICE" ]; then
  RAILS_SERVICE="$(docker compose -f "$COMPOSE_FILE" config --services | grep -Ev '^(db|db-prod|nginx|nginx-proxy|letsencrypt|fail2ban|dgii)' | head -n 1)"
fi

if [ -z "$RAILS_SERVICE" ]; then
  echo "No se pudo detectar el servicio Rails. Ejecuta: RAILS_SERVICE=nombre_servicio $0"
  exit 1
fi

echo "Servicio Rails: $RAILS_SERVICE"
echo "Servicio DB: $DB_SERVICE"
echo "Origen: $SOURCE_DATA_DIR"
echo "Destino: $TARGET_DATA_DIR"

docker compose -f "$COMPOSE_FILE" stop "$RAILS_SERVICE" "$DB_SERVICE"

if [ ! -d "$TARGET_DATA_DIR" ] || [ -z "$(find "$TARGET_DATA_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | head -n 1)" ]; then
  COMPOSE_FILE="$COMPOSE_FILE" \
  SOURCE_DATA_DIR="$SOURCE_DATA_DIR" \
  TARGET_DATA_DIR="$TARGET_DATA_DIR" \
  FORCE_TARGET_RESET="$FORCE_TARGET_RESET" \
    ./scripts/postgres-upgrade-staging.sh
else
  echo "El volumen destino ya existe. No se reconstruye: $TARGET_DATA_DIR"
fi

docker compose -f "$COMPOSE_FILE" up -d "$DB_SERVICE"

until docker compose -f "$COMPOSE_FILE" exec -T "$DB_SERVICE" pg_isready -U novacSystem >/dev/null 2>&1; do
  sleep 1
done

docker compose -f "$COMPOSE_FILE" up -d "$RAILS_SERVICE"
sleep 10

if [ -z "$HEALTH_URL" ]; then
  docker compose -f "$COMPOSE_FILE" exec -T "$RAILS_SERVICE" sh -lc 'curl -s -o /tmp/novac-prod-upgrade-health.out -w "%{http_code}" http://127.0.0.1:${PORT:-3000}/up' > /tmp/novac-prod-upgrade-status.out || true
  status="$(cat /tmp/novac-prod-upgrade-status.out)"
  docker compose -f "$COMPOSE_FILE" exec -T "$RAILS_SERVICE" cat /tmp/novac-prod-upgrade-health.out > /tmp/novac-prod-upgrade-health.out || true
else
  status="$(curl -s -o /tmp/novac-prod-upgrade-health.out -w "%{http_code}" "$HEALTH_URL" || true)"
fi

if [ "$status" != "200" ]; then
  echo "Health check fallo con HTTP $status"
  cat /tmp/novac-prod-upgrade-health.out 2>/dev/null || true
  echo
  echo "Rollback manual:"
  echo "  Cambia temporalmente $COMPOSE_FILE a postgres:13.7 y volumen $SOURCE_DATA_DIR:/var/lib/postgresql/data"
  echo "  Luego ejecuta: docker compose -f $COMPOSE_FILE up -d $DB_SERVICE $RAILS_SERVICE"
  exit 1
fi

cat /tmp/novac-prod-upgrade-health.out
echo
docker compose -f "$COMPOSE_FILE" exec -T "$RAILS_SERVICE" sh -lc 'DISABLE_SPRING=1 bundle exec rails db:migrate:status | tail -n 8'
echo "Upgrade PostgreSQL de produccion completado."
