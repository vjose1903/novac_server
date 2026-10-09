# Upgrade PostgreSQL Docker

El cambio de versión usa dump/restore. No se debe montar directamente el volumen PostgreSQL 13 con PostgreSQL 18.

## Producción

Desde la carpeta del proyecto, seleccionar la base que se quiere migrar:

```bash
./scripts/postgres-prod-upgrade.sh dev
./scripts/postgres-prod-upgrade.sh prod
```

`dev` exige la base `<ALMACEN>_development` y levanta los servicios de desarrollo; `prod` exige `<ALMACEN>_production` y levanta los servicios de producción. El script lee el cliente de `config_setup/actual_cliente.txt` y su `DB_PATH` y `ALMACEN` de `scripts/setup.js`. Con esos valores determina el volumen PostgreSQL 13 (`tmp/<DB_PATH>`) y el destino PostgreSQL 18 (`tmp/<DB_PATH>-pg18`).

El flujo registra las restauraciones completas en `<destino>.restore-complete`. Si el registro corresponde al cliente, origen, destino e imagen actuales, omite el dump/restore y continúa con las migraciones y las comprobaciones. Exige que la base del modo elegido exista en el destino. Si la restauración falla, conserva el destino incompleto y devuelve a su ubicación el destino previo archivado.

Para forzar una nueva copia desde PostgreSQL 13, por ejemplo si cambió el origen:

```bash
FORCE_RESTORE=1 ./scripts/postgres-prod-upgrade.sh dev
```

Conservar el volumen PostgreSQL 13 y los directorios `.bak-*` hasta verificar los flujos principales del cliente. El script no elimina el volumen de origen.

## Restauración de staging

Para ejecutar solamente el dump/restore sin actualizar los servicios de producción, el script standalone usa por defecto las rutas de Agrodemi. Para otro cliente hay que indicar sus carpetas origen y destino:

```bash
SOURCE_DATA_DIR=tmp/db-brendy-data TARGET_DATA_DIR=tmp/db-brendy-data-pg18 ./scripts/postgres-upgrade-staging.sh
```
