# Upgrade PostgreSQL Docker

Este proyecto no debe subir PostgreSQL reemplazando directamente el volumen viejo.

## Flujo seguro

1. Ejecutar backup y restore de prueba:

   ```bash
   docker compose stop agrodemi-dev db-dev
   ./scripts/postgres-upgrade-staging.sh
   ```

2. Validar que el script termina con:

   ```text
   Upgrade staging completado.
   ```

3. Levantar la app contra el volumen restaurado:

   ```bash
   docker compose up -d db-dev agrodemi-dev
   ```

4. Validar salud y flujo principal:

   ```bash
   curl http://localhost:9090/up
   ```

## Produccion

Ejecutar el deploy seguro completo:

```bash
./scripts/postgres-prod-upgrade.sh
```

Para otro cliente, usar el path correspondiente:

```bash
SOURCE_DATA_DIR=tmp/db-brendy-data TARGET_DATA_DIR=tmp/db-brendy-data-pg18 ./scripts/postgres-prod-upgrade.sh
```

## Rollback

Si algo falla antes de borrar el volumen viejo, volver temporalmente a PostgreSQL 13.7 cambiando el compose al path anterior:

```yaml
image: postgres:13.7
volumes:
  - ./tmp/db-agrodemi-data:/var/lib/postgresql/data
```

No borrar `tmp/db-*-data` hasta completar varios smokes exitosos en PostgreSQL 18.6.
