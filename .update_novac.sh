#!/usr/bin/env bash

set -Eeuo pipefail

# Puede sobrescribirse al ejecutar el script, por ejemplo:
# NOVAC_BRANCH=vasquez_services NOVAC_CLIENT=vasquez ./.update_novac.sh
PROJECT_DIR="${NOVAC_PROJECT_DIR:-$HOME/proyects/novac-server}"
BRANCH="${NOVAC_BRANCH:-ADM}"
CLIENT="${NOVAC_CLIENT:-agrodemi}"

printf '\n\033[95m===== INICIAR ACTUALIZACIÓN DE %s =====\033[0m\n' "$CLIENT"
printf 'Proyecto: %s\nRama: %s\n\n' "$PROJECT_DIR" "$BRANCH"

echo '[1/8] Entrando al proyecto...'
cd "$PROJECT_DIR"

echo '      OK'

echo

echo '[2/8] Consultando los últimos cambios de Git...'
git fetch origin "$BRANCH"
echo '      OK'
echo

echo '[3/8] Eliminando cambios locales rastreados...'
git reset --hard
echo '      OK'
echo

echo '[4/8] Eliminando archivos locales no ignorados...'
git clean -fd
echo '      OK'
echo

echo '[5/8] Cambiando a la rama publicada y alineándola con origin...'
git checkout -B "$BRANCH" "origin/$BRANCH"
echo '      OK'
echo

echo '[6/8] Deteniendo los contenedores actuales...'
node ./scripts/start.js -p -d
echo '      OK'
echo

echo '[7/8] Construyendo y levantando la versión actualizada...'
node ./scripts/start.js -p -c "$CLIENT" -b -t -u
echo '      OK'
echo

echo '[8/8] Verificando que el contenedor esté ejecutándose...'
container="${CLIENT}-prod"
if ! docker ps --format '{{.Names}}' | grep -Fxq "$container"; then
  echo "ERROR: el contenedor $container no quedó ejecutándose." >&2
  exit 1
fi
echo "      OK: $container está ejecutándose."
printf '\n\033[92m===== ACTUALIZACIÓN COMPLETADA =====\033[0m\n'
