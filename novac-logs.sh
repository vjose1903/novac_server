#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"
RAILS_SERVICE="${RAILS_SERVICE:-}"
FULL_LOG_FLAG="tmp/novac-full-logs.enabled"
RAILS_LOG_FILE="log/production.log"
HEARTBEAT_INTERVAL="${HEARTBEAT_INTERVAL:-10}"
PARENT_PID="$$"

if [ -z "$RAILS_SERVICE" ]; then
  RAILS_SERVICE="$(docker compose -f "$COMPOSE_FILE" config --services | grep -Ev '^(db|db-prod|nginx|nginx-proxy|letsencrypt|fail2ban|dgii)' | head -n 1)"
fi

if [ -z "$RAILS_SERVICE" ]; then
  echo "No se pudo detectar el servicio Rails. Ejecuta: RAILS_SERVICE=nombre_servicio ./novac-logs.sh"
  exit 1
fi

cleanup() {
  if [ -n "${HEARTBEAT_PID:-}" ]; then
    kill "$HEARTBEAT_PID" >/dev/null 2>&1 || true
  fi
  docker compose -f "$COMPOSE_FILE" exec -T "$RAILS_SERVICE" sh -lc "rm -f '$FULL_LOG_FLAG'" >/dev/null 2>&1 || true
}

trap cleanup EXIT INT TERM

docker compose -f "$COMPOSE_FILE" exec -T "$RAILS_SERVICE" sh -lc "mkdir -p tmp log && touch '$FULL_LOG_FLAG' '$RAILS_LOG_FILE'"

(
  while kill -0 "$PARENT_PID" >/dev/null 2>&1; do
    docker compose -f "$COMPOSE_FILE" exec -T "$RAILS_SERVICE" sh -lc "touch '$FULL_LOG_FLAG'" >/dev/null 2>&1 || true
    sleep "$HEARTBEAT_INTERVAL"
  done
) &
HEARTBEAT_PID=$!

echo "Mostrando logs completos. Servicio Rails: $RAILS_SERVICE"
echo "Presiona Ctrl+C para desactivar los logs completos."
echo "Si la terminal se cierra abruptamente, Rails vuelve a logs minimos en maximo 30 segundos."

docker compose -f "$COMPOSE_FILE" logs -f &
DOCKER_LOGS_PID=$!

docker compose -f "$COMPOSE_FILE" exec -T "$RAILS_SERVICE" sh -lc "tail -n 200 -f '$RAILS_LOG_FILE'" &
RAILS_LOG_PID=$!

wait "$DOCKER_LOGS_PID" "$RAILS_LOG_PID"
