# Plan de Optimización de Entidades Pendientes

## Contexto general
- Proyecto Rails API dockerizado (contenedor `agrodemi-dev`, proxy `localhost:9090`, BD `db-dev`)
- Meta: optimizar serializers eliminando `ActiveModel::Serializer` overhead, N+1 queries, paginación en memoria y logs innecesarios de AMS
- **NO cambiar contratos del API**: cada endpoint debe responder exactamente el mismo JSON

## Helper global disponible
- `app/serializers/fast_serializer.rb` con funciones: `serialize_record`, `serialize_collection`, `show_serialized_field?`, `selected_serialized_fields`, `serialize_selected_record`, `read_serialized_value`
- `Response` en `config/initializers/global/functions.rb` usa fast serializers automáticamente si el serializer implementa `self.to_hash` y `self.collection_to_hash`

## Flujo obligatorio por entidad
1. `git status --short` antes de editar
2. Leer controller, modelo, serializer y rutas de la entidad
3. Identificar todos los endpoints (REST, filtros, custom, collection/member)
4. Capturar baseline con `curl` contra Docker
5. Revisar JSON baseline: estructura raiz, data, msg, paginación, atributos, dependencias anidadas
6. Implementar optimización manteniendo mismas propiedades, orden, estructura
7. Validar sintaxis con `docker compose exec -T agrodemi-dev ruby -c <archivo>`
8. Volver a llamar endpoints con `curl`
9. Comparar baseline vs nueva respuesta con JSON parseado
10. Si hay diferencia, revisar campo por campo
11. Revisar logs que no aparezcan nuevos `active_model_serializers`
12. Revisar setup multi-cliente con `rg` en `scripts` y `config_setup`
13. Reportar resumen y esperar validación del usuario

## Plan COMPLETO (31-08-2026)
Se agotó la lista de prioridad con `permiso_acciones`. Todos los serializers de la app son fast (`extend FastSerializer`) salvo el módulo `fast_serializer.rb` y `tipo_recibos` (sin tabla). Si se agrega una entidad nueva, optimizarla siguiendo el flujo.

## Entidades ya optimizadas (NO repetir)
acciones, articulos, cabecera_conduces, cabecera_facturas, calendar_event_links, calendar_event_types, calendar_events, clientes, commertial_approval_receptions, config_articulos, configuracion_cuadres, contenido_articulos, costo_fletes, cuadre_caja_denominaciones, cuadre_caja_eventos, cuadre_caja_movimientos, cuadre_cajas, detalle_conduces, detalle_facturas, detalle_recibos, detalles_facturas_notas, detalles_produccion, divisas, document_references, documentos_de_identidad, ecf_receptions, facturas_aplicadas, formulas_productos_terminados, global_holidays, incidencias, marcas, modelos, movimiento_viajes, municipios, notas, permisos, permiso_acciones, producciones, provincias, recibos_ingresos, roles, suplidores, tasas_de_cambio, tipo_articulos, tipo_facturas, users/empleados, vehiculos

## Lista de prioridad pendiente (en orden)
_Completa._ Agotada con `permiso_acciones` (31-08-2026).

## Nota sobre tipo_recibos
Saltada el 2026-08-29: no tiene tabla en BD. Endpoint devuelve 500 PG::UndefinedTable. Solo existen routes, controller (scaffold render json:) y modelo; no hay migración, schema, datos ni serializer. Pendiente de aclarar si sigue viva.

## Patrón para serializers
- Conservar `attribute` existentes, agregar `FastSerializer`
- `to_hash` y `collection_to_hash` para que `Response` los detecte
- Si serializer viejo devolvía siempre todos los campos → `to_hash` retorna todos
- Si usaba `get_param('all') || has_to_show(...)` → filtrar con `show_serialized_field?`
- Campos calculados van por `readers: {}`
- Entidades anidadas no optimizadas: mantener `serialize_parser` temporalmente

## Situaciones especiales documentadas
- Controller con `Response`: mantener, pasar `models_includes` si hay asociaciones
- Controller con `render json:`: usar `render body: ... .to_json`
- `serialize_parser` en modelo: preferir `res.set_data` si no cambia contrato
- `.to_a` antes de paginar: evitar, mantener paginación en SQL
- SQL interpolado: cambiar a bind params
- Campos virtuales de SELECT: preservar con `has_attribute?`
- Timestamps: preservar formato ISO exacto
- `msg: nil`: no cambiar

## Validaciones multi-cliente
```bash
rg -n "nombre_serializer|NombreController|app/models/nombre|nombre_controller" scripts config_setup config app -g '!log/**' -g '!tmp/**'
```
Si hay template en `config_setup`, aplicar cambio también ahí.

## Criterio de completado
- Status HTTP igual
- JSON parseado antes/después igual
- Sin perder ni agregar propiedades
- Includes eliminan N+1 sin cargar innecesarias
- Logs sin render de AMS para esa entidad
- Revisado setup multi-cliente
- Usuario probó y autorizó commit
