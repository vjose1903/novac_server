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

secret_files=(
  secrets/firebase-service-account.json
  config/google_api_credentials.json
  config/initializers/google/google_api_credentials.json
  dgii_signature_microservice/src/utils/google_api_credentials.json
  dgii_signature_microservice/src/utils/firma-digital.p12
)

for secret_file in "${secret_files[@]}"; do
  if [ ! -f "$secret_file" ]; then
    echo "Falta el archivo secreto: $secret_file" >&2
    exit 1
  fi
done

git add .gitattributes "${secret_files[@]}"
echo "Credenciales Firebase/Google y certificado DGII preparados para quedar cifrados al hacer commit." >&2
echo "Comprueba el cambio y realiza el commit manualmente." >&2
