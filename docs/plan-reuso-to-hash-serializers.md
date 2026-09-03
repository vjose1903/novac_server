# Plan de Reuso de `to_hash` en Serializers Dependientes

## Objetivo
Reducir duplicación de código: los serializers fast (`extend FastSerializer`) que serializan **dependencias anidadas** deben delegar en el `to_hash` / `collection_to_hash` del serializer de cada dependencia, en lugar de definir métodos-propios de serialización inline repetidos. **NO cambiar contratos del API**: todo JSON resultante debe ser idéntico byte a byte.

## Contexto
- Todos los serializers de `app/serializers/` ya son fast (implementan `self.to_hash(object, params={})` y `self.collection_to_hash`).
- Muchos serializers definen helpers inline del tipo `self.cliente_to_hash`, `serialize_accion`, `permiso_accion_to_hash`, `documentos_de_identidad_to_hash`, etc., que reproducen a mano el shape de la dependencia en vez de llamar `DepSerializer.to_hash(dep, params)`.
- Este plan inventaría esos métodos, clasifica si la delegación es posible con JSON idéntico, y define el orden de trabajo.

## Regla general de factibilidad
Un método inline es **reemplazable con JSON idéntico** si el serializer de la dependencia puede emitir **exactamente** el mismo set de claves, en el mismo orden, con los mismos valores/readers, vía `to_hash`/`collection_to_hash` con un conjunto de params dado.

Blocker frecuente: serializers cuya `to_hash` **ignora params y devuelve SIEMPRE todos** sus `default_fields` (p.ej. `AccionSerializer.to_hash` devuelve `[:id, :nombre, :descripcion, :metodo, :created_at, :updated_at, :mostrar_front]`). Cuando el método inline pide un **subconjunto** menor, la delegación cambiaría el JSON a menos que el serializer dependiente aprenda a filtrar por params.

---

## MÉTODO 1: Repetido exacto — se puede delegar tal cual (mayor prioridad)

Estos producen EXACTAMENTE lo mismo que el `collection_to_hash`/`to_hash` de la dependencia con `{all: true}` (o params fijos). La sustitución es de bajo riesgo y JSON idéntico.

| # | Serializer (archivo) | Método inline (líneas) | Dependencia | Sustitución exacta |
|---|---|---|---|---|
| 1 | `articulo_serializer.rb` | `serialize_contenido_articulos` (107-115) | ContenidoArticulo | `ContenidoArticuloSerializer.collection_to_hash(content, { all: true })` |
| 2 | `articulo_serializer.rb` | `serialize_formulas_productos_terminados` (117-129) | FormulaProductoTerminado | `FormulasProductosTerminadoSerializer.collection_to_hash(formulas, { all: true })` |
| 3 | `suplidor_serializer.rb` | `self.documentos_de_identidad_to_hash` (40-44) | DocumentoDeIdentidad | `DocumentoDeIdentidadSerializer.collection_to_hash(obj.documentos_de_identidad, { all: true })` |
| 4 | `cliente_serializer.rb` | `self.documentos_de_identidad_to_hash` (122-126) | DocumentoDeIdentidad | `DocumentoDeIdentidadSerializer.collection_to_hash(obj.documentos_de_identidad, { all: true })` |
| 5 | `user_serializer.rb` | `self.documentos_de_identidad_to_hash` (99-101) | DocumentoDeIdentidad | `DocumentoDeIdentidadSerializer.collection_to_hash(obj.documentos_de_identidad, { all: true })` |
| 6 | `cliente_serializer.rb` | `self.municipio_to_hash` (134-138) | Municipio | `MunicipioSerializer.to_hash(municipio, { all: true })` (ojo: no pasar params[:provincia]) |
| 7 | `role_serializer.rb` | `self.permiso_to_hash` (54-58) | Permiso | `PermisoSerializer.to_hash(permiso)` |
| 8 | `role_serializer.rb` | `self.permiso_accion_to_hash` (40-46) | PermisoAccion | `PermisoAccionSerializer.to_hash(permiso_accion)` |
| 9 | `permiso_serializer.rb` | `self.permiso_to_hash` (68-72) | Permiso | `PermisoSerializer.to_hash(permiso)` (autorreferencia) |
| 10 | `permiso_serializer.rb` | `self.permiso_accion_to_hash` (54-60) | PermisoAccion | `PermisoAccionSerializer.to_hash(permiso_accion)` (mismo shape; validar el caso `permiso` explícito de línea 38) |
| 11 | `permiso_accion_serializer.rb` | `self.serialize_permiso` (52-60, 76-84) | Permiso | `PermisoSerializer.to_hash(permiso)` (shape idéntico) |
| 12 | `municipio_serializer.rb` | `self.provincia_to_hash` (40-44) | Provincia | `ProvinciaSerializer.to_hash(prov, { id: true, nombre: true })` — OJO: normalizar params, NO pasar `all` (si no agrega `codigo`/`municipios`) |
| 13 | `cabecera_conduce_serializer.rb` | `self.cliente_to_hash` (35-44) | Cliente | `ClienteSerializer.to_hash(cliente, { nombre: true, apellido: true, telefono: true, direccion: true, nombre_completo: true, documentos_de_identidad: true })` (validar orden de claves) |
| 14 | `cuadre_caja_serializer.rb` | instancia `serialize_user` (108-110) | User | `UserSerializer.to_hash(user, { id: true, nombre: true, apellido: true, nombre_completo: true })` (solo vía clásica) |

---

## MÉTODO 2: Requiere que el serializer dependiente aprenda a filtrar por params (requiere tocar el serializer base)

Estos NO se pueden sustituir hoy porque el serializer de la dependencia devuelve **más campos de los que el inline necesita** y su `to_hash` ignora params. Solución: hacer que el serializer base filtre por params, y recién entonces delegar.

| # | Serializer (archivo) | Método inline | Dependencia | Inline emite | Def=s de la dependencia | Acción |
|---|---|---|---|---|---|---|
| 1 | `role_serializer.rb` | `self.accion_to_hash` (48-52) | Accion | `id, descripcion, nombre, mostrar_front` | `id, nombre, descripcion, metodo, created_at, updated_at, mostrar_front` | Hacer `AccionSerializer.to_hash` filtrar por params y delegar `AccionSerializer.to_hash(accion, { id: true, descripcion: true, nombre: true, mostrar_front: true })` |
| 2 | `permiso_serializer.rb` | `self.accion_to_hash` (62-66) | Accion | idem | idem | idem |
| 3 | `permiso_accion_serializer.rb` | `self.serialize_accion` (41-50, 65-74) | Accion | idem | idem | idem |
| 4 | `cliente_serializer.rb` | `self.provincia_to_hash` (128-132) | Provincia | `id, nombre, codigo` | `id, nombre, codigo, municipios` | `ProvinciaSerializer.to_hash(prov, { id: true, nombre: true, codigo: true })` (sin `all`; ya funciona sin tocar base) |
| 5 | `user_serializer.rb` | `self.roles_to_hash` (103-105) | Role | `id, descripcion, nombre` | `id, descripcion, nombre, ruta_defecto, estado` | Hacer `RoleSerializer.to_hash` filtrar por params, o delegar con selección post-keys |

---

## MÉTODO 3: NO reemplazables sin cambiar el contrato actual

Estos emiten un shape **derivado/sintético** o **compuesto** distinto de cualquier `to_hash` de una dependencia. No delegar; documentar por qué.

| # | Serializer (archivo) | Método inline | Dependencia | Razón |
|---|---|---|---|---|
| 1 | `cliente_serializer.rb` | `self.vendedor_to_hash` (111-120) | User | Emite clave sintética `vendedor_id = user.id` que `UserSerializer` no produce (emite `id`); + capitalización en readers. |
| 2 | `municipio_serializer.rb` | `self.provincia_to_hash` (40-44) | Provincia | (ya está en MÉTODO 1 con normalización; si no se normaliza `all` agrega `codigo`/`municipios`). |
| 3 | `cabecera_factura_serializer.rb` | `self.cliente_to_hash` (231-249) | Cliente | Emite `{nombre, nombre_completo, direccion, telefono, rnc}` con `rnc` derivado (docs principales) y fallback `NoCliente_*`; `:nombre` = `nombre_completo`. `ClienteSerializer` tiene 19 campos, no `rnc`. |
| 4 | `cabecera_factura_serializer.rb` | `self.suplidor_to_hash` (251-262) | Suplidor | `{nombre_completo, direccion, telefono, rnc}` con `rnc` derivado; `SuplidorSerializer` emite `id/nombre/email/estado` y no `rnc`. |
| 5 | `cabecera_factura_serializer.rb` | `self.vendedor_to_hash` (264-269) | User (vendedor) | Devuelve un **string** (`nombre_completo`), no un hash. Shape distinto. |
| 6 | `cabecera_factura_serializer.rb` | `self.pagos_to_hash` (278-299) | DetalleRecibo + RecibosIngreso | Merge cross-model: `detalle_recibo.as_json` + sobrescrituras de `recibos_ingreso` (id, numero_recibo, recibo_creado_por, fecha_equivalente). Ningún serializer único cubre el shape. |
| 7 | `articulo_serializer.rb` | `tipo_articulo` (79-81) | TipoArticulo | Emite `record.attributes` (todas las columnas, keys string); `TipoArticuloSerializer` emite 6 campos con keys symbol. |
| 8 | `vehiculo_serializer.rb` | `self.propietario_to_hash` branch `elsif` (nombre_no_empleado) | sintético | Datos no-empleado no mapdean a un modelo/serializer. (El branch `user` ya delega.) |

---

## MÉTODO 4: Ya delegan correctamente (NO tocar, referencia)

Estos ya usan `DepSerializer.to_hash`/`collection_to_hash` del dependiente. Son el patrón a imitar.

- `cabecera_conduce_serializer.rb`: `user` reader → `UserSerializer.to_hash(..., {nombre, apellido, nombre_completo})`
- `documento_de_identidad_serializer.rb`: `self.persona_to_hash` → lookup dinámico `"#{origen_type}Serializer".to_hash(...)`
- `provincia_serializer.rb`: `self.municipios_to_hash` → `MunicipioSerializer.collection_to_hash(...)`
- `produccion_serializer.rb`: `self.user_to_hash` → `UserSerializer.to_hash(user, {nombre, apellido})`
- `vehiculo_serializer.rb`: `self.propietario_to_hash` branch user → `UserSerializer.to_hash(...)`
- `commertial_approval_reception_serializer.rb`: `self.cabecera_factura_to_hash`, `self.suplidor_to_hash` → delegan
- `ecf_reception_serializer.rb`: `self.suplidor_to_hash` → delega
- `document_reference_serializer.rb`: `self.document_to_hash` (dispatch CabeceraFactura/Nota), `self.referenced_by_to_hash` → delegan
- `calendar_event_serializer.rb`: `self.links_to_hash` → `CalendarEventLinkSerializer.collection_to_hash`; `calendar_event_type` → `CalendarEventTypeSerializer.to_hash`
- `cuadre_caja_serializer.rb`: fast path ya delega vía `self.serialize_user_hash` (162-165) → `UserSerializer.to_hash`
- `cabecera_factura_serializer.rb`: `self.notas_to_hash` → `FacturaAplicadaSerializer.collection_to_hash`; `self.document_reference_to_hash` → `DocumentReferenceSerializer.to_hash`

---

## Orden de trabajo propuesto (por prioridad / riesgo)

### Fase A — MÉTODO 1 (delegación exacta, bajo riesgo)
1. `articulo_serializer.rb`: `serialize_contenido_articulos` → `ContenidoArticuloSerializer.collection_to_hash(..., {all:true})`
2. `articulo_serializer.rb`: `serialize_formulas_productos_terminados` → `FormulasProductosTerminadoSerializer.collection_to_hash(..., {all:true})`
3. `suplidor_serializer.rb`: `documentos_de_identidad` → `DocumentoDeIdentidadSerializer.collection_to_hash(..., {all:true})`
4. `cliente_serializer.rb`: `documentos_de_identidad` idem
5. `user_serializer.rb`: `documentos_de_identidad` idem
6. `cliente_serializer.rb`: `municipio_to_hash` → `MunicipioSerializer.to_hash(m, {all:true})`
7. `role_serializer.rb`: `permiso_to_hash` + `permiso_accion_to_hash` → delegar en `PermisoSerializer` / `PermisoAccionSerializer`
8. `permiso_serializer.rb`: `permiso_to_hash` + `permiso_accion_to_hash` → delegar (validar caso línea 38 con permiso explícito)
9. `permiso_accion_serializer.rb`: `serialize_permiso` → `PermisoSerializer.to_hash(permiso)`
10. `municipio_serializer.rb`: `provincia_to_hash` → `ProvinciaSerializer.to_hash(prov, {id:true, nombre:true})` (normalizar params)
11. `cabecera_conduce_serializer.rb`: `cliente_to_hash` → `ClienteSerializer.to_hash(cliente, {...})` (validar orden)
12. `cuadre_caja_serializer.rb`: instancia `serialize_user` → `UserSerializer.to_hash(...)` (solo camino clásico)

### Fase B — MÉTODO 2 (requiere tocar el serializer base para filtrar por params)
1. `AccionSerializer`: hacer `to_hash` filtrar por `params` (hoy ignora params y devuelve 7 campos). Luego reemplazar en `role_serializer`, `permiso_serializer`, `permiso_accion_serializer` los `serialize_accion`/`accion_to_hash` inline por `AccionSerializer.to_hash(accion, {id:true, descripcion:true, nombre:true, mostrar_front:true})`.
2. `cliente_serializer.rb`: `provincia_to_hash` ya factible sin tocar base (params fijos `{id, nombre, codigo}`).
3. `RoleSerializer`: hacer `to_hash` filtrar por params (hoy siempre devuelve `id, descripcion, nombre, ruta_defecto, estado`). Luego `user_serializer.rb: roles_to_hash` → `RoleSerializer.collection_to_hash(roles, {id:true, descripcion:true, nombre:true})`.

### Fase C — MÉTODO 3 (documentar, no tocar salvo decisión explícita)
- `cliente_serializer.vendedor_to_hash`, `cabecera_factura.{cliente,suplidor,vendedor,pagos}_to_hash`, `articulo.tipo_articulo`, `vehiculo.propietario_to_hash` branch no-empleado.

---

## Lista de entidades a modificar, en orden (una a una)

Trabajar **una sola entidad por turno**, en este orden. Cada turno completa el flujo obligatorio de abajo y se valida antes de pasar a la siguiente. NO avanzar a la siguiente entidad en el mismo turno.

### Fase A — Delegación exacta (bajo riesgo, JSON idéntico)

| # | Entidad (archivo) | Método(s) inline a sustituir | Sustitución |
|---|---|---|---|
| 1 | `articulo_serializer.rb` | `serialize_contenido_articulos` | `ContenidoArticuloSerializer.collection_to_hash(content, { all: true })` |
| 2 | `articulo_serializer.rb` | `serialize_formulas_productos_terminados` | `FormulasProductosTerminadoSerializer.collection_to_hash(formulas, { all: true })` |
| 3 | `suplidor_serializer.rb` | `self.documentos_de_identidad_to_hash` | `DocumentoDeIdentidadSerializer.collection_to_hash(obj.documentos_de_identidad, { all: true })` |
| 4 | `cliente_serializer.rb` | `self.documentos_de_identidad_to_hash` | `DocumentoDeIdentidadSerializer.collection_to_hash(obj.documentos_de_identidad, { all: true })` |
| 5 | `user_serializer.rb` | `self.documentos_de_identidad_to_hash` | `DocumentoDeIdentidadSerializer.collection_to_hash(obj.documentos_de_identidad, { all: true })` |
| 6 | `cliente_serializer.rb` | `self.municipio_to_hash` | `MunicipioSerializer.to_hash(municipio, { all: true })` (no pasar `params[:provincia]`) |
| 7 | `role_serializer.rb` | `self.permiso_to_hash` + `self.permiso_accion_to_hash` | `PermisoSerializer.to_hash(permiso)` / `PermisoAccionSerializer.to_hash(permiso_accion)` |
| 8 | `permiso_serializer.rb` | `self.permiso_to_hash` + `self.permiso_accion_to_hash` | delegar; validar caso línea 38 (permiso explícito) |
| 9 | `permiso_accion_serializer.rb` | `self.serialize_permiso` | `PermisoSerializer.to_hash(permiso)` |
| 10 | `municipio_serializer.rb` | `self.provincia_to_hash` | `ProvinciaSerializer.to_hash(prov, { id: true, nombre: true })` (normalizar params, NO `all`) |
| 11 | `cabecera_conduce_serializer.rb` | `self.cliente_to_hash` | `ClienteSerializer.to_hash(cliente, { nombre: true, apellido: true, telefono: true, direccion: true, nombre_completo: true, documentos_de_identidad: true })` (validar orden) |
| 12 | `cuadre_caja_serializer.rb` | instancia `serialize_user` | `UserSerializer.to_hash(user, { id: true, nombre: true, apellido: true, nombre_completo: true })` (solo camino clásico) |

### Fase B — Requiere tocar el serializer base (filtrar por params)

| # | Entidad (archivo) | Cambio |
|---|---|---|
| 13 | `AccionSerializer` | Hacer `to_hash` filtrar por `params` (hoy ignora params y devuelve siempre 7 campos). **Conservar el contrato actual** (sin params debe seguir devolviendo los 7 campos / 5 si así se consume). |
| 14 | `role_serializer.rb` | Tras #13: sustituir `accion_to_hash` por `AccionSerializer.to_hash(accion, {id:true, descripcion:true, nombre:true, mostrar_front:true})` |
| 15 | `permiso_serializer.rb` | Tras #13: sustituir `accion_to_hash` idem |
| 16 | `permiso_accion_serializer.rb` | Tras #13: sustituir `serialize_accion` idem |
| 17 | `cliente_serializer.rb` | `self.provincia_to_hash` → `ProvinciaSerializer.to_hash(prov, { id: true, nombre: true, codigo: true })` |
| 18 | `RoleSerializer` | Hacer `to_hash` filtrar por `params` (hoy siempre devuelve `id, descripcion, nombre, ruta_defecto, estado`). **Conservar el contrato actual** sin params. |
| 19 | `user_serializer.rb` | Tras #18: `roles_to_hash` → `RoleSerializer.collection_to_hash(roles, {id:true, descripcion:true, nombre:true})` |

### Fase C — Documentación / decisión (NO tocar salvo decisión explícita)

- `cliente_serializer.vendedor_to_hash`, `cabecera_factura.{cliente,suplidor,vendedor,pagos}_to_hash`, `articulo.tipo_articulo`, `vehiculo.propietario_to_hash` (branch no-empleado).

### Entidad actual
Hechas y validadas: la **#1 `articulo_serializer.rb` → `contenido_articulos`**, la **#2 → `formulas_productos_terminados`**, la **#3 `suplidor_serializer.rb` → `documentos_de_identidad`**, la **#4 `cliente_serializer.rb` → `documentos_de_identidad`**, la **#5 `user_serializer.rb` → `documentos_de_identidad`**, la **#6 `cliente_serializer.rb` → `municipio`**, la **#7 `role_serializer.rb` → `permiso` / `permiso_accion`**, la **#8 `permiso_serializer.rb` → `permiso` / `permiso_accion`**, la **#9 `permiso_accion_serializer.rb` → `serialize_permiso`** y la **#10 `municipio_serializer.rb` → `provincia_to_hash`**. Avanzar a la **#11 `cabecera_conduce_serializer.rb` → `cliente_to_hash`** (`ClienteSerializer.to_hash(cliente, {...})`, validar orden de claves). Al terminar y validar cada una, marcar la casilla correspondiente abajo y avanzar a la siguiente.

---

## Flujo obligatorio por entidad (por cada modificación)

1. `git status --short` antes de editar.
2. **Capturar baseline** del endpoint(s) que serializan la entidad **antes** de tocar nada:
   - Identificar el/los controller/ruta(s) o el punto de serialización con `rg "Serializer|serialize_parser\\(|render json:" app`.
   - Si hay endpoint HTTP real → `curl` contra el proxy `localhost:9090`.
   - Si no hay endpoint HTTP (solo Rake task / nested / runner) → preparar runner en transacción con rollback.
3. **Revisar el JSON baseline**: estructura raiz, `data`, `msg`, paginación, atributos, orden de claves y dependencias anidadas.
4. Implementar la sustitución por el `to_hash`/`collection_to_hash` de la dependencia (Fase A/B).
5. Validar sintaxis con `docker compose exec -T agrodemi-dev ruby -c app/serializers/<archivo>`.
6. Volver a llamar el/los mismos endpoint(s) con `curl` (o correr el runner).
7. **Comparar baseline vs nueva respuesta con JSON parseado** (ver "Comparación" abajo).
8. Si hay diferencia, revisar campo por campo (claves, orden, valores, nil vs faltante).
9. Revisar logs que NO aparezcan nuevos `[active_model_serializers] Rendered ...Serializer` (no reintroducir overhead de AMS).
10. Revisar setup multi-cliente con `rg` en `scripts` y `config_setup`.
11. Reportar resumen y esperar validación del usuario.

## Criterio de completado (por entidad)
- Respuesta del API **exactamente igual** antes y después de la modificación (JSON parseado idéntico, mismo orden de claves).
- Status HTTP igual.
- Sin perder ni agregar propiedades en el JSON.
- La dependencia anidada se resuelve con su `to_hash`/`collection_to_hash` (sin método inline repetido).
- Logs sin render adicional de AMS para esa entidad.
- Revisado setup multi-cliente.
- Usuario probó y validó; recién entonces marcar y pasar a la siguiente.

## Comparación del JSON (obligatorio)
- **NO** usar `serializable_hash` + `JSON.generate` (no resuelve adapters anidados ni formatea Time en ISO).
- Replicar el render de producción con el `@res.to_json`:
  `JSON.parse(ActiveModelSerializers::SerializableResource.new(obj, params).as_json.to_json)`
- La diferencia símbolos vs strings de keys se resuelve normalizando por JSON.
- Para dependencias anidadas dentro de `to_hash`, replicar el nested como hash/array plano o delegar al serializer fast (`to_hash`/`collection_to_hash`).

## Validaciones Docker (igual que el plan anterior, aplicadas al nuevo alcance)
- Sintaxis: `docker compose exec -T agrodemi-dev ruby -c app/serializers/<archivo>`.
- Runner (cuando no haya endpoint): copiar a `/tmp` con `docker compose cp /tmp/x.rb agrodemi-dev:/tmp/x.rb`, luego `docker compose exec -T agrodemi-dev rails runner "/tmp/x.rb"`, en transacción con rollback para no ensuciar la BD.
- HTTP (cuando haya endpoint): `curl` contra el proxy `localhost:9090`, comparando el JSON parseado antes/después.
- Contenedor: `agrodemi-dev`, BD: `db-dev`.

## Notas importantes
- **Guardar el fix en todos los callers**: si el serializer base cambia su contrato de filtrado (Fase B), revisar y probar TODOS los callers que lo usan con `serialize_parser` o `to_hash` directo.
- **No usar `serialize_parser` como valor anidado** dentro de un hash plano de `to_hash` (no se resuelve bien en `to_json`). Delegar con `to_hash`/`collection_to_hash`.
- Si una entidad anidada NO tiene serializer fast (`to_hash`), NO delegar: dejarlo con método inline hasta que exista (o documentarlo).
- Timestamps/date en readers: `&.as_json` (formato ISO).

## Estado de avance (marcar al validar cada una)
- [x] A1 `articulo_serializer` (contenido_articulos)
- [x] A2 `articulo_serializer` (formulas_productos_terminados)
- [x] A3 `suplidor_serializer` (documentos_de_identidad)
- [x] A4 `cliente_serializer` (documentos_de_identidad)
- [x] A5 `user_serializer` (documentos_de_identidad)
- [x] A6 `cliente_serializer` (municipio)
- [x] A7 `role_serializer` (permiso / permiso_accion)
- [x] A8 `permiso_serializer` (permiso / permiso_accion)
- [x] A9 `permiso_accion_serializer` (permiso)
- [x] A10 `municipio_serializer` (provincia)
- [ ] A11 `cabecera_conduce_serializer` (cliente)
- [ ] A12 `cuadre_caja_serializer` (serialize_user)
- [ ] B13 `AccionSerializer` (filtrar por params)
- [ ] B14 `role_serializer` (accion)
- [ ] B15 `permiso_serializer` (accion)
- [ ] B16 `permiso_accion_serializer` (accion)
- [ ] B17 `cliente_serializer` (provincia)
- [ ] B18 `RoleSerializer` (filtrar por params)
- [ ] B19 `user_serializer` (roles)
- [ ] C (documentar, no tocar salvo decisión)
