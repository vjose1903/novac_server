# Instrucciones para agentes

## Configuración de empresa, equipo y Firebase

Antes de agregar, modificar o eliminar parámetros de configuración, o cambiar su lectura, validación, guardado o caché, leer [docs/ai/configuration-contract.md](docs/ai/configuration-contract.md).

- Ejecutar `git status --short` antes de editar y conservar cambios locales existentes.
- El contrato canónico es `config/configuration_schema.json`. Derivar los campos de ese contrato; no recrear listas manuales en servicios o controladores.
- Coordinar los cambios con novac-system y sincronizar allí la copia del contrato siguiendo la guía.
- No omitir autenticación, validación de tipos, comprobación de versiones ni control de concurrencia para hacer pasar un parámetro nuevo.
- No ejecutar pruebas, builds, instalaciones ni despliegues sin la autorización aplicable. En la entrega indicar los cambios, compatibilidad requerida y validaciones no ejecutadas.
