#!/usr/bin/env bash
set -euo pipefail

if ! command -v git-crypt >/dev/null 2>&1; then
  echo "git-crypt no está instalado. Instálalo y vuelve a ejecutar este script." >&2
  exit 1
fi

if [ ! -d .git ]; then
  echo "Ejecuta este script desde la raíz de novac-server." >&2
  exit 1
fi

if [ ! -d .git/git-crypt ]; then
  git-crypt init
  echo "Repositorio preparado. Exporta la clave maestra y guárdala fuera de Git:" >&2
  echo "  git-crypt export-key ~/novac-server-git-crypt.key" >&2
fi

if [ ! -f secrets/firebase-service-account.json ]; then
  echo "Falta secrets/firebase-service-account.json. Coloca la credencial y vuelve a ejecutar git add." >&2
  exit 1
fi

git add .gitattributes secrets/firebase-service-account.json
echo "Credencial preparada para quedar cifrada al hacer commit." >&2
echo "Comprueba el cambio y realiza el commit manualmente." >&2
