# Plan de upgrade del stack base

Alcance: issue #2. Este documento deja definido el orden seguro para actualizar Ruby, Rails, PostgreSQL y Node base sin mezclarlo con secretos ni validaciones de permisos/acciones.

## Estado actual del proyecto

- Backend Rails: `Gemfile` fija `ruby '3.0.4'`.
- Rails instalado por `Gemfile.lock`: `7.0.4`.
- Defaults de Rails: `config.load_defaults 5.2`, aunque la gema activa es Rails 7.
- Imagen backend: `docker/Dockerfile` usa `ruby:3.0.4`.
- PostgreSQL: `docker-compose.yml` y `docker-compose.prod.yml` usan `postgres:13.7`.
- DGII microservice: `dgii_signature_microservice/Dockerfile` y `Dockerfile.dev` usan `node:20.19.2-alpine`.
- Node dependencies pendientes: `googleapis@148` queda como riesgo moderado en `npm audit` y su salto correctivo requiere major hacia `googleapis@176`.

## Referencias vigentes al 2026-08-24

- Ruby oficial publica como estable actual `4.0.6`; Ruby 3.0 esta EOL desde 2024-04-23.
- Rails publico actual: `8.1.3`; hay parches de seguridad publicados para `7.2.3.2`, `8.0.5.1` y `8.1.3.1`.
- Rails 7.2 requiere Ruby >= 3.1.
- Rails 8.1 requiere Ruby >= 3.2.
- PostgreSQL tiene releases soportados `18.6`, `17.11`, `16.15`, `15.19`, `14.24`; PostgreSQL 13 ya no aparece en la lista de releases soportados publicada.
- Node actual: `24.19.0` como Latest LTS y `26.7.0` como Latest Release; Node 20 aparece fuera de soporte comunitario regular.

## Riesgos principales

- `active_model_serializers 0.10.13` restringe `actionpack` y `activemodel` a `< 7.1`, por lo que bloquea Rails 7.1+ mientras no se actualice o se remplace.
- `devise_token_auth 1.2.1` restringe Rails a `< 7.1`, por lo que tambien bloquea Rails 7.1+.
- `config.load_defaults 5.2` puede conservar comportamientos antiguos aunque la gema suba. Cambiar defaults debe hacerse despues de tener pruebas de endpoints criticos.
- PostgreSQL no debe subirse con reemplazo directo del volumen. Requiere dump/restore o `pg_upgrade` en ambiente staging.
- `googleapis@176` requiere Node >= 18, compatible con las imagenes actuales Node 20, pero puede cambiar APIs internas usadas por integraciones de Drive/Google.

## Ruta recomendada

### Fase 2.1: cerrar deuda Node sin tocar Rails

Objetivo: eliminar el riesgo moderado restante de `npm audit`.

Cambios:

- Subir `googleapis` de `^148.0.0` a `^176.0.0` en `package.json`.
- Subir `googleapis` de `^148.0.0` a `^176.0.0` en `dgii_signature_microservice/package.json`.
- Regenerar `package-lock.json`.

Validaciones para completar:

- `npm audit --omit=dev` debe quedar sin vulnerabilidades high/critical y sin el warning moderado de `googleapis`.
- `npm run build --workspace=dgii_signature_microservice`.
- Smoke de utilidades Google/Drive si hay credenciales disponibles en Docker.
- Smoke DGII real solo si estan disponibles certificados, variables y servicios externos.

### Fase 2.2: subir Ruby antes que Rails

Objetivo: salir de Ruby 3.0 EOL sin introducir el cambio funcional fuerte de Rails.

Cambios:

- Crear rama dedicada para Ruby.
- Subir `ruby '3.0.4'` y `docker/Dockerfile` a una version soportada compatible con Rails 7.0.
- Ruta conservadora: probar primero Ruby 3.2.x o 3.3.x antes de evaluar Ruby 4.0.x.
- Regenerar `Gemfile.lock` dentro del contenedor Docker, no en host local.

Validaciones para completar:

- `docker compose build server-ra`.
- `docker compose up` con backend, Postgres y microservicio.
- Smoke de login/autenticacion.
- Smoke de facturacion con y sin DGII, si el ambiente lo permite.
- Smoke de reportes y dashboard.

### Fase 2.3: limpiar bloqueadores de Rails 7.1+

Objetivo: preparar el upgrade de Rails sin romper serializacion ni auth.

Cambios:

- Evaluar upgrade de `active_model_serializers` a `0.10.16`.
- Evaluar upgrade de `devise_token_auth` a una version compatible con Rails 7.1+.
- Revisar serializers criticos: facturas, notas, recibos, reportes, dashboard y usuarios.
- Mantener la forma actual del JSON hasta tener aprobacion del frontend.

Validaciones para completar:

- Contratos JSON de endpoints criticos comparados antes/despues.
- Login, refresh/token auth y endpoints protegidos.
- Serializacion de respuestas paginadas y respuestas con `Response`.

### Fase 2.4: Rails incremental

Objetivo: llegar a una version Rails soportada sin salto brusco.

Orden:

1. Rails 7.0.4 -> ultimo patch Rails 7.0.x disponible.
2. Rails 7.0.x -> Rails 7.1.x, solo despues de resolver AMS/devise_token_auth.
3. Rails 7.1.x -> Rails 7.2.x.
4. Rails 8.x solo como fase posterior, despues de estabilizar Rails 7.2 y Ruby >= 3.2.

Validaciones para completar:

- Ejecutar `rails app:update` de forma controlada y revisar diffs manualmente.
- No aceptar cambios generados en initializers/config sin revision.
- Smoke completo de endpoints de usuario, facturacion, DGII, reportes, dashboard y catalogos.
- Revisar `config.load_defaults` por version y subirlo de forma incremental.

### Fase 2.5: PostgreSQL

Objetivo: salir de PostgreSQL 13 sin riesgo de perdida de data.

Ruta:

- Primero subir a una version soportada estable en staging, recomendada `postgres:16` o `postgres:17` antes de considerar 18.
- Preparar backup con `pg_dump`.
- Restaurar en volumen nuevo, no reutilizar el volumen `tmp/db-agrodemi-data` directamente.
- Ejecutar migraciones y endpoints criticos contra la base restaurada.

Validaciones para completar:

- Conteo de tablas criticas antes/despues.
- Migraciones Rails completas.
- Consultas pesadas de reportes y dashboard.
- Facturacion, pagos, recibos, notas y DGII en ambiente controlado.

### Fase 2.6: Node base image

Objetivo: subir las imagenes DGII a Node LTS vigente.

Cambios:

- Cambiar `node:20.19.2-alpine` a `node:24.19.0-alpine` o patch LTS vigente al momento de ejecutar la fase.
- Sincronizar `dgii_signature_microservice/Dockerfile` y `Dockerfile.dev`.

Validaciones para completar:

- Build dev y prod del microservicio.
- Smoke de firma XML.
- Smoke de envio DGII si el ambiente externo esta disponible.
- Confirmar que `node-forge`, `dgii-ecf`, `ts-node-dev` y TypeScript no emiten errores runtime.

## Criterio de cierre del issue #2

El issue #2 queda completo con este plan porque no aplica cambios runtime directos. Los upgrades quedan separados en fases ejecutables, con orden de menor a mayor riesgo, dependencias bloqueantes identificadas y validaciones concretas para cerrar cada fase posterior.

Fuentes consultadas: Ruby downloads, Ruby maintenance branches, Rails releases, Rails 7.2 release notes, Rails 8.1 RubyGems, PostgreSQL downloads y Node.js downloads/releases.
