#!/usr/bin/env bash

set -Eeuo pipefail

# Puede sobrescribirse al ejecutar el script, por ejemplo:
# NOVAC_BRANCH=vasquez_services NOVAC_CLIENT=vasquez ./.update_novac.sh
PROJECT_DIR="${NOVAC_PROJECT_DIR:-$HOME/proyects/novac-server}"
BRANCH="${NOVAC_BRANCH:-ADM}"
CLIENT="${NOVAC_CLIENT:-agrodemi}"

unlock_git_crypt_files() {
  command -v git-crypt >/dev/null 2>&1 || {
    echo 'ERROR: git-crypt no está instalado en el servidor.' >&2
    return 1
  }

  local key_path="${NOVAC_GIT_CRYPT_KEY:-$HOME/.config/novac/git-crypt.key}"
  local encrypted_files

  encrypted_files="$(git-crypt status | awk '$1 == "encrypted:" { print $2 }')"

  if [[ -z "$encrypted_files" ]]; then
    echo '      No hay archivos git-crypt cifrados pendientes.'
    return 0
  fi

  echo "      Se detectaron $(printf '%s\n' "$encrypted_files" | sed '/^$/d' | wc -l | tr -d ' ') archivos cifrados."

  if [[ ! -f "$key_path" ]]; then
    echo "ERROR: no existe la clave git-crypt: $key_path" >&2
    return 1
  fi

  git-crypt unlock "$key_path"

  encrypted_files="$(git-crypt status | awk '$1 == "encrypted:" { print $2 }')"
  if [[ -n "$encrypted_files" ]]; then
    echo 'ERROR: quedaron archivos git-crypt cifrados después del desbloqueo.' >&2
    printf '%s\n' "$encrypted_files" >&2
    return 1
  fi

  echo '      Credenciales git-crypt desbloqueadas y verificadas.'
}

printf '\n\033[95m===== INICIAR ACTUALIZACIÓN DE %s =====\033[0m\n' "$CLIENT"
printf 'Proyecto: %s\nRama: %s\n\n' "$PROJECT_DIR" "$BRANCH"

echo '[1/9] Entrando al proyecto...'
cd "$PROJECT_DIR"

echo '      OK'

echo

echo '[2/9] Consultando los últimos cambios de Git...'
git fetch origin "$BRANCH"
echo '      OK'
echo

echo '[3/9] Eliminando cambios locales rastreados...'
git reset --hard
echo '      OK'
echo

echo '[4/9] Eliminando archivos locales no ignorados...'
git clean -fd
echo '      OK'
echo

echo '[5/9] Cambiando forzosamente a la rama publicada...'
git checkout -f -B "$BRANCH" "origin/$BRANCH"
git reset --hard "origin/$BRANCH"
git clean -fd
echo '      OK'
echo

echo '[6/9] Verificando credenciales git-crypt...'
unlock_git_crypt_files
echo '      OK'
echo

echo '[7/9] Deteniendo los contenedores actuales...'
node ./scripts/start.js -p -d
echo '      OK'
echo

echo '[8/9] Construyendo y levantando la versión actualizada...'
node ./scripts/start.js -p -c "$CLIENT" -b -t -u
echo '      OK'
echo

echo '[9/9] Verificando que el contenedor esté ejecutándose...'
container="${CLIENT}-prod"
if ! docker ps --format '{{.Names}}' | grep -Fxq "$container"; then
  echo "ERROR: el contenedor $container no quedó ejecutándose." >&2
  exit 1
fi
echo "      OK: $container está ejecutándose."
printf '\n\033[92m===== ACTUALIZACIÓN COMPLETADA =====\033[0m\n'
