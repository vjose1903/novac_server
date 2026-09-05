# Plan de Migración de `serialize_parser` / `render json:` a Fast Path

## Objetivo
Migrar **todas** las llamadas a `serialize_parser(modelo, params)` y `render json: @modelo` que aún activan la vía AMS clásica (los `attribute :X, if: Proc.new { self.get_param('X') }`) para que pasen por la vía fast (`Response` → `to_hash`/`collection_to_hash`). Una vez completada la migración, todos los atributos AMS clásicos con `get_param` serán **código muerto** y se podrán retirar de forma segura.

## Contexto
- Todos los serializers de `app/serializers/` ya implementan `self.to_hash(object, params={})` y `self.collection_to_hash` (vía fast).
- `Response#serialize_response_data` usa SIEMPRE la vía fast si el serializer responde a `to_hash` + `collection_to_hash`.
- **Problema**: aún existen puntos en `app/models/` y `app/controllers/` que llaman `serialize_parser(modelo, params)` o `render json: @modelo` directamente, lo que activa la vía AMS clásica y obliga a mantener los atributos `attribute :X, if: Proc.new { get_param }` en los serializers.
- `serialize_parser(modelo, params)` devuelve `ActiveModelSerializers::SerializableResource.new(modelo, params)` → usa la vía AMS clásica.
- `res.set_data(modelo, {all: true})` → pasa por `serialize_response_data` → usa la vía fast si el serializer responde a `to_hash` + `collection_to_hash`.
- **Meta final**: eliminar todos los `attribute ... if: Proc.new { self.get_param(...) }` y los métodos de instancia muertos (dead code) de los serializers.

## Regla general de factibilidad
Una llamada a `serialize_parser(modelo, params)` es **reemplazable con JSON idéntico** si:
1. El serializer del modelo ya responde a `to_hash` + `collection_to_hash` (ya es fast).
2. El `to_hash` con los mismos params produce **exactamente** el mismo JSON que `ActiveModelSerializers::SerializableResource`.
3. El resultado se almacena en `res.set_data(...)` con `parametros_opcionales` para que `Response` use la vía fast.

**Cambio mínimo**: reemplazar `res.set_data(serialize_parser(modelo, params))` por `res.set_data(modelo, params)`. Esto hace que `Response` use `ModelSerializer.to_hash(modelo, params)` en lugar de AMS clásico.

---

## Entidades a migrar (por fase)

### Fase A — Modelos con `serialize_parser(self, ...)` directo (bajo riesgo)

Estos modelos envuelven a sí mismos en `serialize_parser` dentro de `res.set_data`. El cambio es reemplazar `serialize_parser(self, params)` por el modelo directo con `parametros_opcionales`, para que `Response` use la vía fast.

| # | Archivo | Línea | Línea actual | Sustitución |
|---|---|---|---|---|
| 1 | `suplidor.rb` | 78 | `res.set_data(serialize_parser(suplidor, {all:true}))` | `res.set_data(suplidor, {all:true})` |
| 2 | `user.rb` | 123 | `res.set_data(serialize_parser(user, {all: true}))` | `res.set_data(user, {all: true})` |
| 3 | `divisa.rb` | 42 | `res.set_data(serialize_parser(divisa, { all: true }))` | `res.set_data(divisa, { all: true })` |
| 4 | `cliente.rb` | 91 | `res.set_data(serialize_parser(cliente, {all: true}))` | `res.set_data(cliente, {all: true})` |
| 5 | `cabecera_conduce.rb` | 54 | `res.set_data(serialize_parser(conduce, {all: true}))` | `res.set_data(conduce, {all: true})` |

### Fase B — Controllers con `render json:` directo (bajo riesgo)

Estos controllers usan `render json: @modelo` en lugar de `Response.new(...).send_response`. El cambio es migrarlos al patrón `Response` con `parametros_opcionales` para que usen la vía fast.

| # | Archivo | Líneas | Líneas actuales | Sustitución |
|---|---|---|---|---|
| 6 | `facturas_aplicadas_controller.rb` | 13 | `render json: @facturas_aplicadas` | `Response.new(params, HTTP_STATUS_CODE[:ok], @facturas_aplicadas, nil, {all: true}).send_response self` |
| 7 | `facturas_aplicadas_controller.rb` | 18 | `render json: @factura_aplicada` | `Response.new(params, nil, @factura_aplicada, nil, {all: true}).send_response self` |
| 8 | `facturas_aplicadas_controller.rb` | 26 | `render json: @factura_aplicada, status: :created, location: @factura_aplicada` | `Response.new(params, HTTP_STATUS_CODE[:created], @factura_aplicada, nil, {all: true}).send_response self` |
| 9 | `facturas_aplicadas_controller.rb` | 35 | `render json: @factura_aplicada` | `Response.new(params, nil, @factura_aplicada, nil, {all: true}).send_response self` |

**NOTA**: los `render json: @factura_aplicada.errors` (líneas 28, 37) NO se migran — son errores de validación, no serialización de entidad.

### Fase C — Modelos con `serialize_parser(otro_modelo, ...)` activo (requiere validación cuidadosa)

Estos modelos serializan **otra entidad** anidada usando `serialize_parser`. El cambio es reemplazar por `ModelSerializer.to_hash(modelo, params)` directo.

| # | Archivo | Línea | Línea actual | Sustitución |
|---|---|---|---|---|
| 10 | `cabecera_factura.rb` | 317 | `serialize_parser(Cliente.find_by_id(cliente_id), { nombre_completo: true })` | `ClienteSerializer.to_hash(Cliente.find_by_id(cliente_id), { nombre_completo: true })` |
| 11 | `cabecera_factura.rb` | 320 | `serialize_parser(User.find_by_id(user_id), { nombre_completo: true })` | `UserSerializer.to_hash(User.find_by_id(user_id), { nombre_completo: true })` |
| 12 | `cliente.rb` | 197 | `serialize_parser(paginate_class.get_data, { all: true, movimientos_viaje: true })` | `CabeceraFacturaSerializer.collection_to_hash(paginate_class.get_data, { all: true, movimientos_viaje: true })` |
| 13 | `cuadre_caja.rb` | 218 | `res.set_data(serialize_parser(self, { all: true }))` | `res.set_data(self, { all: true })` |
| 14 | `cuadre_caja.rb` | 301 | `serialize_parser(prepared_by, { id: true, nombre: true, apellido: true, nombre_completo: true })` | `UserSerializer.to_hash(prepared_by, { id: true, nombre: true, apellido: true, nombre_completo: true })` |
| 15 | `cuadre_caja.rb` | 329 | `serialize_parser(closing_user, { id: true, nombre: true, apellido: true, nombre_completo: true })` | `UserSerializer.to_hash(closing_user, { id: true, nombre: true, apellido: true, nombre_completo: true })` |
| 16 | `cuadre_caja.rb` | 350 | `return serialize_parser(self, { all: true }) if detailed?` | `return self.class.to_hash(self, { all: true }) if detailed?` |
| 17 | `cuadre_caja.rb` | 451 | `res.set_data(serialize_parser(cuadre_caja.reload, { all: true }))` | `res.set_data(cuadre_caja.reload, { all: true })` |

### Fase D — Serializers con `serialize_parser` en métodos de instancia (dead code que se activa al migrar padre)

Estos serializers tienen métodos de instancia que llaman `serialize_parser` para serializar dependencias anidadas. Actualmente son **código muerto** (porque el padre siempre va por fast), pero al migrar los modelos de la Fase C, algunos podrían activarse. Se migran por seguridad y para eliminar la dependencia de AMS clásico.

| # | Archivo | Método | Línea(s) | Sustitución |
|---|---|---|---|---|
| 18 | `cuadre_caja_serializer.rb` | `denominations` | 52-54 | `CuadreCajaDenominacionSerializer.collection_to_hash(..., { all: true })` |
| 19 | `cuadre_caja_serializer.rb` | `movements` | 60-61 | `CuadreCajaMovimientoSerializer.collection_to_hash(..., { all: true })` |
| 20 | `cuadre_caja_serializer.rb` | `eventos` | 99 | `CuadreCajaEventoSerializer.collection_to_hash(object.eventos.order('created_at ASC'), { all: true })` |
| 21 | `produccion_serializer.rb` | `detalles_produccion` | 33 | `DetalleProduccionSerializer.collection_to_hash(object.detalles_produccion, { all: true })` |
| 22 | `produccion_serializer.rb` | `user` | 37 | `UserSerializer.to_hash(object.user, { nombre: true, apellido: true })` |
| 23 | `detalle_factura_serializer.rb` | `articuloSelect` | 40 | `ArticuloSerializer.to_hash(@articuloSelect, { all: true })` |
| 24 | `cabecera_conduce_serializer.rb` | `detalle_conduces` | 14 | `DetalleConduceSerializer.collection_to_hash(object.detalle_conduces, { all: true })` |
| 25 | `cabecera_factura_serializer.rb` | `detalle_facturas` | 70 | `DetalleFacturaSerializer.collection_to_hash(object.detalle_facturas, @instance_options)` |
| 26 | `cabecera_factura_serializer.rb` | `movimientos_viaje` | 159 | `MovimientoViajeSerializer.collection_to_hash(object.movimientos_viaje, @instance_options)` |

### Fase E — Retiro de código muerto (atributos AMS + métodos de instancia)

Una vez completadas las Fases A–D, **todos** los `serialize_parser` y `render json:` que activaban la vía AMS clásica habrán sido migrados. Entonces se pueden retirar de forma segura:

1. Los `attribute :X, if: Proc.new { self.get_param('X') || self.get_param('all') }` de todos los serializers.
2. Los métodos de instancia que ya no se invocan (`def denominations`, `def movements`, `def eventos`, `def serialize_user`, `def serialize_accion`, etc.).
3. El método `def get_param(col)` de cada serializer (ya que `@instance_options` solo se lee en la vía AMS clásica).

**NOTA**: esta fase se documenta aquí pero se ejecuta como un plan separado AFTER la migración completa. No se toca en este plan.

---

## Orden de trabajo propuesto (por prioridad / riesgo)

### Fase A — Modelos con `serialize_parser(self)` directo (bajo riesgo, cambio mínimo)
1. `suplidor.rb:78` → `res.set_data(suplidor, {all:true})`
2. `user.rb:123` → `res.set_data(user, {all: true})`
3. `divisa.rb:42` → `res.set_data(divisa, { all: true })`
4. `cliente.rb:91` → `res.set_data(cliente, {all: true})`
5. `cabecera_conduce.rb:54` → `res.set_data(conduce, {all: true})`

### Fase B — Controllers con `render json:` (bajo riesgo, cambia endpoint)
6-9. `facturas_aplicadas_controller.rb` → migrar a `Response.new(...).send_response`

### Fase C — Modelos con `serialize_parser(otro_modelo)` activo (riesgo medio, requiere validar JSON anidado)
10-11. `cabecera_factura.rb:317,320` → `ClienteSerializer.to_hash` / `UserSerializer.to_hash`
12. `cliente.rb:197` → `CabeceraFacturaSerializer.collection_to_hash`
13-17. `cuadre_caja.rb:218,301,329,350,451` → vía fast o `UserSerializer.to_hash`

### Fase D — Serializers con `serialize_parser` en métodos instancia (bajo riesgo, dead code → fast)
18-20. `cuadre_caja_serializer.rb` → denominations/movements/eventos
21-22. `produccion_serializer.rb` → detalles_produccion/user
23. `detalle_factura_serializer.rb` → articuloSelect
24. `cabecera_conduce_serializer.rb` → detalle_conduces
25-26. `cabecera_factura_serializer.rb` → detalle_facturas/movimientos_viaje

### Fase E — Retiro de código muerto (post-migración, plan separado)
- Retirar atributos AMS clásicos `attribute ... if: get_param`
- Retirar métodos de instancia muertos
- Retirar `get_param` de cada serializer

---

## Lista de entidades a modificar, en orden (una a una)

Trabajar **una sola entidad por turno**, en este orden. Cada turno completa el flujo obligatorio de abajo y se valida antes de pasar a la siguiente. NO avanzar a la siguiente entidad en el mismo turno.

### Fase A — Modelos con `serialize_parser(self)` directo

| # | Entidad (archivo) | Punto | Sustitución |
|---|---|---|---|
| 1 | `suplidor.rb` | `res.set_data(serialize_parser(suplidor,{all:true}))` (línea 78) | `res.set_data(suplidor, {all:true})` |
| 2 | `user.rb` | `res.set_data(serialize_parser(user, {all: true}))` (línea 123) | `res.set_data(user, {all: true})` |
| 3 | `divisa.rb` | `res.set_data(serialize_parser(divisa, { all: true }))` (línea 42) | `res.set_data(divisa, { all: true })` |
| 4 | `cliente.rb` | `res.set_data(serialize_parser(cliente, {all: true}))` (línea 91) | `res.set_data(cliente, {all: true})` |
| 5 | `cabecera_conduce.rb` | `res.set_data(serialize_parser(conduce, {all: true}))` (línea 54) | `res.set_data(conduce, {all: true})` |

### Fase B — Controllers con `render json:` directo

| # | Entidad (archivo) | Punto(s) | Sustitución |
|---|---|---|---|
| 6 | `facturas_aplicadas_controller.rb` | `render json: @facturas_aplicadas` (línea 13) | `Response.new(params, HTTP_STATUS_CODE[:ok], @facturas_aplicadas, nil, {all: true}).send_response self` |
| 7 | `facturas_aplicadas_controller.rb` | `render json: @factura_aplicada` (línea 18) | `Response.new(params, nil, @factura_aplicada, nil, {all: true}).send_response self` |
| 8 | `facturas_aplicadas_controller.rb` | `render json: @factura_aplicada, status: :created` (línea 26) | `Response.new(params, HTTP_STATUS_CODE[:created], @factura_aplicada, nil, {all: true}).send_response self` |
| 9 | `facturas_aplicadas_controller.rb` | `render json: @factura_aplicada` (línea 35) | `Response.new(params, nil, @factura_aplicada, nil, {all: true}).send_response self` |

### Fase C — Modelos con `serialize_parser(otro_modelo)` activo

| # | Entidad (archivo) | Punto | Sustitución |
|---|---|---|---|
| 10 | `cabecera_factura.rb` | `serialize_parser(Cliente.find_by_id(cliente_id), { nombre_completo: true })` (línea 317) | `ClienteSerializer.to_hash(Cliente.find_by_id(cliente_id), { nombre_completo: true })` |
| 11 | `cabecera_factura.rb` | `serialize_parser(User.find_by_id(user_id), { nombre_completo: true })` (línea 320) | `UserSerializer.to_hash(User.find_by_id(user_id), { nombre_completo: true })` |
| 12 | `cliente.rb` | `serialize_parser(paginate_class.get_data, { all: true, movimientos_viaje: true })` (línea 197) | `CabeceraFacturaSerializer.collection_to_hash(paginate_class.get_data, { all: true, movimientos_viaje: true })` |
| 13 | `cuadre_caja.rb` | `res.set_data(serialize_parser(self, { all: true }))` (línea 218) | `res.set_data(self, { all: true })` |
| 14 | `cuadre_caja.rb` | `serialize_parser(prepared_by, ...)` (línea 301) | `UserSerializer.to_hash(prepared_by, { id: true, nombre: true, apellido: true, nombre_completo: true })` |
| 15 | `cuadre_caja.rb` | `serialize_parser(closing_user, ...)` (línea 329) | `UserSerializer.to_hash(closing_user, { id: true, nombre: true, apellido: true, nombre_completo: true })` |
| 16 | `cuadre_caja.rb` | `serialize_parser(self, { all: true })` (línea 350) | `self.class.to_hash(self, { all: true })` |
| 17 | `cuadre_caja.rb` | `res.set_data(serialize_parser(cuadre_caja.reload, { all: true }))` (línea 451) | `res.set_data(cuadre_caja.reload, { all: true })` |

### Fase D — Serializers con `serialize_parser` en métodos instancia

| # | Entidad (archivo) | Método | Sustitución |
|---|---|---|---|
| 18 | `cuadre_caja_serializer.rb` | `denominations` (líneas 52-54) | `bills: CuadreCajaDenominacionSerializer.collection_to_hash(object.denominaciones.select{...}, {all:true})` (x3) |
| 19 | `cuadre_caja_serializer.rb` | `movements` (líneas 60-61) | `CuadreCajaMovimientoSerializer.collection_to_hash(object.movimientos.select{...}, {all:true})` (x2) |
| 20 | `cuadre_caja_serializer.rb` | `eventos` (línea 99) | `CuadreCajaEventoSerializer.collection_to_hash(object.eventos.order('created_at ASC'), {all:true})` |
| 21 | `produccion_serializer.rb` | `detalles_produccion` (línea 33) | `DetalleProduccionSerializer.collection_to_hash(object.detalles_produccion, {all:true})` |
| 22 | `produccion_serializer.rb` | `user` (línea 37) | `UserSerializer.to_hash(object.user, {nombre:true, apellido:true})` |
| 23 | `detalle_factura_serializer.rb` | `articuloSelect` (línea 40) | `ArticuloSerializer.to_hash(@articuloSelect, {all:true})` |
| 24 | `cabecera_conduce_serializer.rb` | `detalle_conduces` (línea 14) | `DetalleConduceSerializer.collection_to_hash(object.detalle_conduces, {all:true})` |
| 25 | `cabecera_factura_serializer.rb` | `detalle_facturas` (línea 70) | `DetalleFacturaSerializer.collection_to_hash(object.detalle_facturas, @instance_options)` |
| 26 | `cabecera_factura_serializer.rb` | `movimientos_viaje` (línea 159) | `MovimientoViajeSerializer.collection_to_hash(object.movimientos_viaje, @instance_options)` |

---

## Regla de Commit
Cuando el usuario solicite hacer un commit, **antes de ejecutar el commit**, el agente debe:
1. Actualizar la sección "Estado de avance" del archivo `docs/plan-migrar-ams-classic-a-fast.md`.
2. Marcar con `[x]` la(s) fase(s)/entidad(ades) que se acaban de completar en ese commit.
3. Luego ejecutar el commit con el mensaje descriptivo correspondiente.

## Flujo obligatorio por entidad (por cada modificación)

1. `git status --short` antes de editar.
2. **Capturar baseline** del endpoint(s) que serializan la entidad **antes** de tocar nada:
   - Identificar el/los controller/ruta(s) o el punto de serialización con `rg "serialize_parser|render json:" app`.
   - Si hay endpoint HTTP real → `curl` contra el proxy `localhost:9090`.
   - Si no hay endpoint HTTP (solo Rake task / nested / runner) → preparar runner en transacción con rollback.
3. **Medir tiempo de respuesta baseline** del endpoint (mínimo 3 calls, promedio).
4. **Revisar el JSON baseline**: estructura raíz, `data`, `msg`, paginación, atributos, orden de claves y dependencias anidadas.
5. Implementar la sustitución (`serialize_parser` → `ModelSerializer.to_hash`/`collection_to_hash`, o `serialize_parser(self, params)` → `res.set_data(self, params)`, o `render json:` → `Response.new(...).send_response`).
6. Validar sintaxis con `docker compose exec -T agrodemi-dev ruby -c app/models/<archivo>.rb` o `app/serializers/<archivo>.rb`.
7. Volver a llamar el/los mismos endpoint(s) con `curl` (o correr el runner).
8. **Comparar baseline vs nueva respuesta con JSON parseado** (ver "Comparación" abajo).
9. **Medir tiempo de respuesta post-cambio** (mínimo 3 calls, promedio) y comparar con baseline.
10. Si hay diferencia, revisar campo por campo (claves, orden, valores, nil vs faltante).
11. Revisar logs que NO aparezcan nuevos `[active_model_serializers] Rendered ...Serializer` (no reintroducir overhead de AMS).
12. Revisar setup multi-cliente con `rg` en `scripts` y `config_setup`.
13. Reportar resumen: JSON idéntico, status HTTP, tiempo de respuesta (mejoró/se mantuvo/peoró) y esperar validación del usuario.

## Criterio de completado (por entidad)
- Respuesta del API **exactamente igual** antes y después de la modificación (JSON parseado idéntico, mismo orden de claves).
- Status HTTP igual.
- Sin perder ni agregar propiedades en el JSON.
- La serialización pasa por `to_hash`/`collection_to_hash` (sin `serialize_parser` que active AMS clásico).
- Tiempo de respuesta **mejorado o igual** al baseline (nunca peor).
- Logs sin render adicional de AMS para esa entidad.
- Revisado setup multi-cliente.
- Usuario probó y validó; recién entonces marcar y pasar a la siguiente.

## Comparación del JSON (obligatorio)
- **NO** usar `serializable_hash` + `JSON.generate` (no resuelve adapters anidados ni formatea Time en ISO).
- Replicar el render de producción con el `@res.to_json`:
  `JSON.parse(ActiveModelSerializers::SerializableResource.new(obj, params).as_json.to_json)`
- La diferencia símbolos vs strings de keys se resuelve normalizando por JSON.
- Para dependencias anidadas dentro de `to_hash`, delegar al serializer fast (`to_hash`/`collection_to_hash`).

## Métricas de rendimiento (obligatorio por entidad)
- **Antes**: curl timing con `curl -o /dev/null -s -w "time_total:%{time_total}\n" http://localhost:9090/<endpoint>` (3 calls, promedio).
- **Después**: mismo curl, mismos 3 calls.
- **Reporte**: `time_total` antes vs después (en segundos). Si mejora → reportar mejora. Si se mantiene → reportar "igual". Si empeora → **DETENER** y revisar antes de continuar.

## Validaciones Docker (aplicadas al nuevo alcance)
- Sintaxis de modelos: `docker compose exec -T agrodemi-dev ruby -c app/models/<archivo>.rb`.
- Sintaxis de serializers: `docker compose exec -T agrodemi-dev ruby -c app/serializers/<archivo>.rb`.
- Runner (cuando no haya endpoint): copiar a `/tmp` con `docker compose cp /tmp/x.rb agrodemi-dev:/tmp/x.rb`, luego `docker compose exec -T agrodemi-dev rails runner "/tmp/x.rb"`, en transacción con rollback para no ensuciar la BD.
- HTTP (cuando haya endpoint): `curl` contra el proxy `localhost:9090`, comparando el JSON parseado antes/después.
- Contenedor: `agrodemi-dev`, BD: `db-dev`.

## Notas importantes
- **NO cambiar contratos del API**: todo JSON resultante debe ser idéntico byte a byte.
- **Conservar el contrato actual** de cada endpoint: mismas claves, mismo orden, mismos valores.
- Si un serializer dependiente (ej. `CuadreCajaDenominacionSerializer`) es invocado anidado dentro de otro serializer que va por fast, verificar que `collection_to_hash`/`to_hash` produce el JSON esperado.
- `send_response` usa `controller.render body: @res.except(:status).to_json` — el hash debe serializar correctamente a JSON sin wrapper AMS.
- **No usar `serialize_parser` como valor anidado** dentro de un hash plano de `to_hash` (no se resuelve bien en `to_json`). Delegar con `to_hash`/`collection_to_hash`.
- Si una entidad anidada NO tiene serializer fast (`to_hash`), NO delegar: dejarlo con método inline hasta que exista (o documentarlo).
- Timestamps/date en readers: `&.as_json` (formato ISO).
- **B6 (index facturas_aplicadas)**: además del controller, se migró el reader anidado `cabecera_factura` de `factura_aplicada_serializer.rb` de AMS clásico (`ActiveModelSerializers::SerializableResource`) a `CabeceraFacturaSerializer.to_hash` (patrón Fase D), y se añadió preload de `document_reference_as_origin/referenced` en `FacturaAplicada.models_includes` (el `show_field?` de `CabeceraFacturaSerializer` hace 2 queries por fila si no está preload). El index devolvía `[{},{}]` (AMS con get_param vacío omitía todos los atributos); ahora devuelve data real con `{all: true}` (id, total, cabecera_factura, detalles_facturas_notas, fecha_equivalente).
- **B8 (create facturas_aplicadas)**: bug preexistente en strong params — `factura_aplicada_params` permite `:cabeza_factura_id` pero la columna real es `cabecera_factura_id` y `tipo_factura_id` no está permitido. El POST siempre devuelve 422 en producción (no relacionado con la migración; NO se corrige en este plan).

## Estado de avance (marcar al validar cada una)
- [x] A1 `suplidor.rb` (serialize_parser self)
- [x] A2 `user.rb` (serialize_parser self)
- [x] A3 `divisa.rb` (serialize_parser self)
- [x] A4 `cliente.rb` (serialize_parser self)
- [x] A5 `cabecera_conduce.rb` (serialize_parser self)
- [x] B6 `facturas_aplicadas_controller.rb` index (render json)
- [x] B7 `facturas_aplicadas_controller.rb` show (render json)
- [x] B8 `facturas_aplicadas_controller.rb` create (render json)
- [x] B9 `facturas_aplicadas_controller.rb` update (render json)
- [x] C10 `cabecera_factura.rb` serialize_parser Cliente
- [x] C11 `cabecera_factura.rb` serialize_parser User
- [x] C12 `cliente.rb` serialize_parser CabeceraFactura
- [x] C13 `cuadre_caja.rb:218` serialize_parser self
- [x] C14 `cuadre_caja.rb:301` serialize_parser User (prepared_by)
- [x] C15 `cuadre_caja.rb:329` serialize_parser User (closing_user)
- [x] C16 `cuadre_caja.rb:350` serialize_parser self (detailed?)
- [x] C17 `cuadre_caja.rb:451` serialize_parser self (reload)
- [x] D18 `cuadre_caja_serializer.rb` denominations
- [x] D19 `cuadre_caja_serializer.rb` movements
- [x] D20 `cuadre_caja_serializer.rb` eventos
- [ ] D21 `produccion_serializer.rb` detalles_produccion
- [ ] D22 `produccion_serializer.rb` user
- [ ] D23 `detalle_factura_serializer.rb` articuloSelect
- [ ] D24 `cabecera_conduce_serializer.rb` detalle_conduces
- [ ] D25 `cabecera_factura_serializer.rb` detalle_facturas
- [ ] D26 `cabecera_factura_serializer.rb` movimientos_viaje
- [ ] E (retiro de código muerto — plan separado post-migración)

### Entidad actual
Siguiente: **D21 `produccion_serializer.rb` detalles_produccion**.
