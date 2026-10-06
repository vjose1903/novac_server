#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"
SOURCE_IMAGE="${SOURCE_IMAGE:-postgres:13.7}"
SOURCE_CONTAINER="${SOURCE_CONTAINER:-novac-postgres-source-staging}"
SOURCE_DATA_DIR="${SOURCE_DATA_DIR:-tmp/db-agrodemi-data}"
TARGET_IMAGE="${TARGET_IMAGE:-postgres:18.6}"
TARGET_CONTAINER="${TARGET_CONTAINER:-novac-postgres18-staging}"
TARGET_DATA_DIR="${TARGET_DATA_DIR:-tmp/db-agrodemi-data-pg18}"
BACKUP_DIR="${BACKUP_DIR:-tmp/postgres-upgrade-backups/$(date +%Y%m%d%H%M%S)-$$}"
POSTGRES_USER="${POSTGRES_USER:-novacSystem}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-N0v@cgu@rd}"
REQUIRED_DATABASE="${REQUIRED_DATABASE:-}"
RESTORE_CLIENT="${RESTORE_CLIENT:-unknown}"
FORCE_TARGET_RESET="${FORCE_TARGET_RESET:-0}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SOURCE_DATA_PATH="$ROOT_DIR/$SOURCE_DATA_DIR"
TARGET_DATA_PATH="$ROOT_DIR/$TARGET_DATA_DIR"
RESTORE_MARKER="${RESTORE_MARKER:-${TARGET_DATA_PATH}.restore-complete}"
ARCHIVED_TARGET=""

cleanup() {
  local exit_status=$?
  docker rm -f "$SOURCE_CONTAINER" >/dev/null 2>&1 || true
  docker rm -f "$TARGET_CONTAINER" >/dev/null 2>&1 || true

  if [ "$exit_status" -ne 0 ] && [ -n "$ARCHIVED_TARGET" ] && [ -d "$ARCHIVED_TARGET" ]; then
    if [ -e "$TARGET_DATA_PATH" ]; then
      failed_target="${TARGET_DATA_PATH}.failed-$(date +%Y%m%d%H%M%S)-$$"
      mv "$TARGET_DATA_PATH" "$failed_target"
      echo "Destino incompleto conservado en: ${failed_target#$ROOT_DIR/}"
    fi
    mv "$ARCHIVED_TARGET" "$TARGET_DATA_PATH"
    echo "Destino previo restaurado en: ${TARGET_DATA_DIR}"
  elif [ "$exit_status" -ne 0 ]; then
    rm -f "$RESTORE_MARKER"
  fi
  return "$exit_status"
}
trap cleanup EXIT

if [ ! -d "$SOURCE_DATA_PATH" ]; then
  echo "No existe SOURCE_DATA_DIR: $SOURCE_DATA_DIR"
  exit 1
fi

for path in "$SOURCE_DATA_PATH" "$TARGET_DATA_PATH"; do
  mounted_by="$(
    for id in $(docker ps -q); do
      name="$(docker inspect "$id" --format '{{.Name}}' | sed 's#^/##')"
      if docker inspect "$id" --format '{{range .Mounts}}{{println .Source}}{{end}}' | grep -Fx "$path" >/dev/null; then
        echo "$name"
      fi
    done || true
  )"

  if [ -n "$mounted_by" ]; then
    echo "El path esta montado por un contenedor activo: $path"
    echo "$mounted_by"
    echo "Deten los servicios antes de correr el upgrade para evitar corrupcion de datos."
    exit 1
  fi
done

mkdir -p "$BACKUP_DIR"

if [ -e "$TARGET_DATA_PATH" ] && [ "$(find "$TARGET_DATA_PATH" -mindepth 1 -maxdepth 1 2>/dev/null | head -n 1)" ]; then
  if [ "$FORCE_TARGET_RESET" = "1" ]; then
    ARCHIVED_TARGET="${TARGET_DATA_PATH}.bak-$(date +%Y%m%d%H%M%S)-$$"
    mv "$TARGET_DATA_PATH" "$ARCHIVED_TARGET"
    echo "Data destino existente archivada en: ${ARCHIVED_TARGET#$ROOT_DIR/}"
  else
    echo "El destino ya tiene data: $TARGET_DATA_DIR"
    echo "Usa otro TARGET_DATA_DIR o FORCE_TARGET_RESET=1 para archivarlo y reconstruirlo."
    exit 1
  fi
fi

mkdir -p "$TARGET_DATA_DIR"

NETWORK="$(docker compose -f "$COMPOSE_FILE" ls --format json >/dev/null 2>&1 && basename "$ROOT_DIR")_default"
if ! docker network inspect "$NETWORK" >/dev/null 2>&1; then
  NETWORK="bridge"
fi

echo "Usando red Docker: $NETWORK"
echo "Data PostgreSQL origen: $SOURCE_DATA_DIR"
echo "Backup en: $BACKUP_DIR"
echo "Data PostgreSQL destino: $TARGET_DATA_DIR"

docker rm -f "$SOURCE_CONTAINER" >/dev/null 2>&1 || true
docker rm -f "$TARGET_CONTAINER" >/dev/null 2>&1 || true

docker run -d \
  --name "$SOURCE_CONTAINER" \
  --network "$NETWORK" \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -v "$SOURCE_DATA_PATH:/var/lib/postgresql/data" \
  "$SOURCE_IMAGE" >/dev/null

docker run -d \
  --name "$TARGET_CONTAINER" \
  --network "$NETWORK" \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -e PGDATA=/var/lib/postgresql/18/docker \
  -v "$ROOT_DIR/$TARGET_DATA_DIR:/var/lib/postgresql" \
  "$TARGET_IMAGE" >/dev/null

until docker exec "$SOURCE_CONTAINER" pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; do
  sleep 1
done

until docker exec "$TARGET_CONTAINER" pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; do
  sleep 1
done

DATABASES_FILE="$BACKUP_DIR/databases.txt"
docker exec "$SOURCE_CONTAINER" \
  psql -U "$POSTGRES_USER" -d postgres -Atc \
  "select datname from pg_database where datistemplate = false and datname <> 'postgres' order by datname" > "$DATABASES_FILE"

if [ -n "$REQUIRED_DATABASE" ] && ! grep -Fxq "$REQUIRED_DATABASE" "$DATABASES_FILE"; then
  echo "La base requerida '$REQUIRED_DATABASE' no existe en el origen PostgreSQL 13."
  echo "Bases encontradas:"
  cat "$DATABASES_FILE"
  echo "No se completará la migración; el destino previo se restaurará si existía."
  exit 1
fi

while IFS= read -r db <&3; do
  [ -z "$db" ] && continue
  echo "Respaldando $db"
  docker exec "$SOURCE_CONTAINER" \
    pg_dump -U "$POSTGRES_USER" -Fc "$db" > "$BACKUP_DIR/$db.dump"

  echo "Restaurando $db en $TARGET_IMAGE"
  docker exec "$TARGET_CONTAINER" createdb -U "$POSTGRES_USER" "$db" >/dev/null 2>&1 || true
  docker exec -i "$TARGET_CONTAINER" pg_restore \
    -U "$POSTGRES_USER" \
    -d "$db" \
    --clean \
    --if-exists \
    --no-owner \
    --no-acl < "$BACKUP_DIR/$db.dump"
done 3< "$DATABASES_FILE"

compare_counts() {
  local container="$1"
  local db="$2"

  docker exec "$container" psql -U "$POSTGRES_USER" -d "$db" -Atc "
    select table_schema || '.' || table_name
    from information_schema.tables
    where table_type = 'BASE TABLE'
      and table_schema not in ('pg_catalog', 'information_schema')
    order by 1
  " | while read -r table; do
    [ -z "$table" ] && continue
    count="$(docker exec "$container" psql -U "$POSTGRES_USER" -d "$db" -Atc "select count(*) from $table")"
    echo "$table=$count"
  done
}

while IFS= read -r db <&3; do
  [ -z "$db" ] && continue
  source_file="$BACKUP_DIR/$db.source-counts"
  target_file="$BACKUP_DIR/$db.target-counts"

  compare_counts "$SOURCE_CONTAINER" "$db" > "$source_file"
  compare_counts "$TARGET_CONTAINER" "$db" > "$target_file"

  if diff -u "$source_file" "$target_file" > "$BACKUP_DIR/$db.counts.diff"; then
    echo "Conteos OK: $db"
  else
    echo "Conteos diferentes en $db. Revisa $BACKUP_DIR/$db.counts.diff"
    exit 1
  fi
done 3< "$DATABASES_FILE"

docker exec "$TARGET_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -Atc "select version()"
echo "Upgrade staging completado."
marker_tmp="${RESTORE_MARKER}.tmp-$$"
{
  echo "status=complete"
  echo "client=$RESTORE_CLIENT"
  echo "source=$SOURCE_DATA_DIR"
  echo "target=$TARGET_DATA_DIR"
  echo "image=$TARGET_IMAGE"
  while IFS= read -r db; do
    [ -z "$db" ] || echo "database=$db"
  done < "$DATABASES_FILE"
} > "$marker_tmp"
mv "$marker_tmp" "$RESTORE_MARKER"
echo "Registro de restauración escrito: ${RESTORE_MARKER#$ROOT_DIR/}"
echo "Upgrade staging completado."
