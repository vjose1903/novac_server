# Alta de un nuevo cliente

Guía para configurar un cliente nuevo sin exponer credenciales de Firebase, Google ni DGII.

## 1. Crear la configuración del cliente

En la computadora de desarrollo, agrega el cliente en `scripts/setup.js`:

- Incluye el nombre en `clientes`.
- Agrega sus valores en `setup_` (`PORT_APP`, `DB_PORT`, `CUSTOMER_NAME`, `DOCKER_NAME`, etc.).
- Crea los archivos específicos que el setup deba copiar bajo `config_setup/`.
- Mantén los marcadores `$$NOMBRE_DE_VARIABLE$$` en las plantillas.

Para generar la configuración de desarrollo:

```bash
node scripts/start.js -c NOMBRE_CLIENTE
```

Para generar la configuración de producción, `-p` debe ir antes de `-c`:

```bash
node scripts/start.js -p -c NOMBRE_CLIENTE
```

En la entrada del cliente define `USE_DGII_MICROSERVICE` como `true` o `false`. Cuando es `false`, el setup deja el backend configurado sin el perfil `dgii` y `scripts/start.js` no levanta ese contenedor. Cuando es `true`, el script activa automáticamente el perfil. Si ejecutas Compose manualmente para un cliente que usa DGII, utiliza `COMPOSE_PROFILES=dgii docker compose up -d`.

## 2. Preparar los secretos

Los secretos se guardan en el repositorio únicamente cifrados con `git-crypt`.

Archivos protegidos actualmente:

```text
secrets/firebase-service-account.json
config/google_api_credentials.json
config/initializers/google/google_api_credentials.json
dgii_signature_microservice/src/utils/google_api_credentials.json
dgii_signature_microservice/src/utils/firma-digital.p12
```

Si se agrega otro secreto, primero añádelo a `.gitattributes`:

```gitattributes
ruta/al/secreto filter=git-crypt diff=git-crypt
```

Los archivos `.env` permanecen fuera de Git y deben existir en cada servidor. Nunca subas un `.env` con credenciales reales.

## 3. Cifrar un secreto nuevo

Verifica que `git-crypt` esté instalado y desbloqueado:

```bash
git-crypt status
```

Después aplica el filtro al archivo nuevo:

```bash
git add --renormalize -- ruta/al/secreto
```

Comprueba que el contenido del índice comienza con la cabecera cifrada:

```bash
git show :ruta/al/secreto | head -c 8 | od -An -tc
```

Debe aparecer `GITCRYPT`.

## 4. Registrar el secreto en Git

Si `.gitattributes` acaba de recibir una ruta nueva, primero haz un commit de `.gitattributes` y súbelo. Luego ejecuta `git add --renormalize` para cifrar los archivos que ya estaban rastreados.

Revisa siempre los archivos preparados:

```bash
GIT_PAGER=cat git diff --cached --name-status
```

Haz el commit de los secretos sin usar `git add .`:

```bash
git commit -m "chore: cifrar secretos del cliente NOMBRE_CLIENTE"
git push origin NOMBRE_RAMA
```

## 5. Preparar un servidor nuevo

En el servidor Ubuntu, instala Git, `git-crypt`, Docker Compose v2 y configura una clave SSH de solo lectura para GitHub.

La clave privada de GitHub debe quedar en:

```text
~/.ssh/github_novac_server
```

La clave de `git-crypt` debe quedar fuera del repositorio:

```text
~/.config/novac/git-crypt.key
```

Protege ambas:

```bash
chmod 600 ~/.ssh/github_novac_server
chmod 600 ~/.config/novac/git-crypt.key
```

Clona o actualiza el proyecto:

```bash
cd /home/novac/proyects/novac-server
git pull
git-crypt unlock ~/.config/novac/git-crypt.key
```

## 6. Crear los archivos locales del servidor

El archivo del microservicio DGII no se distribuye por Git:

```bash
cp dgii_signature_microservice/env.example dgii_signature_microservice/.env
chmod 600 dgii_signature_microservice/.env
```

Completa `.env` con los valores reales de producción del cliente.

## 7. Verificar la credencial Firebase

El JSON descifrado debe comenzar con `{`:

```bash
head -c 1 secrets/firebase-service-account.json
```

La autenticación desde Rails se valida dentro del contenedor:

```bash
docker compose -f docker-compose.prod.yml exec NOMBRE_SERVICIO \
  ruby -rgoogleauth -e '
credentials = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open("/run/secrets/firebase-service-account.json"),
  scope: "https://www.googleapis.com/auth/datastore"
)
credentials.fetch_access_token!
puts "Token Firebase obtenido correctamente"
'
```

## 8. Levantar el cliente

En producción usa siempre este orden:

```bash
node scripts/start.js -p -c NOMBRE_CLIENTE -b -t -u
```

El orden evita que el setup genere archivos de desarrollo cuando se esperaba producción.

## 9. Validar el flujo completo

Comprueba que:

1. El contenedor Rails aparece como `Up`.
2. El microservicio DGII inicia sin errores de `.env`.
3. Nginx permite las peticiones de logos (`client_max_body_size 20m`).
4. Electron envía `empresa_id`; Rails no tiene una empresa fija.
5. El formulario de configuración guarda logos y configuración en Firebase.
6. Si una empresa aún no tiene logos, Electron conserva el logo local de fallback.

Para actualizar un servidor ya preparado:

```bash
git pull
sh .update_novac.sh
```

`scripts/start.js` desbloquea automáticamente los archivos `git-crypt` usando `~/.config/novac/git-crypt.key`.

## Reglas de seguridad

- Nunca publiques una clave privada, un `.env` ni el contenido de un JSON de servicio.
- No uses `git add .` para registrar secretos.
- No ejecutes `git clean -fd` en un servidor sin respaldar primero los secretos locales.
- Si una credencial ya estuvo publicada sin cifrar, rótala en Google/Firebase aunque ahora esté protegida con `git-crypt`.
