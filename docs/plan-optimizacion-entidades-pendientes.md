# Plan de optimizacion de entidades pendientes

Este documento deja el contexto para continuar la optimizacion de serializers y requests entidad por entidad. La meta no es cambiar contratos del API: cada endpoint debe responder exactamente el mismo JSON que respondia antes, pero evitando overhead de `ActiveModel::Serializer`, N+1 queries, paginacion en memoria y logs innecesarios de AMS.

## Regla de trabajo

Cuando el usuario diga: `continua con la siguiente entidad`, trabajar solo la siguiente entidad de la lista de prioridad. No avanzar a otra entidad en el mismo turno.

Flujo obligatorio por entidad:

1. Ejecutar `git status --short` antes de editar.
2. Leer solo controller, modelo, serializer y rutas de esa entidad.
3. Identificar todos los endpoints que usa esa entidad: REST (`index`, `show`), filtros, `custom`, rutas de collection/member y metodos del modelo llamados desde controller.
4. Capturar baseline antes de modificar con `curl` contra Docker, por ejemplo `http://localhost:9090/...`.
5. Revisar el JSON del baseline y anotar que retorna al front: estructura raiz, `data`, `msg`, paginacion, atributos simples, atributos calculados, dependencias y dependencias anidadas.
6. Implementar la optimizacion manteniendo exactamente las mismas propiedades, anidados, orden de claves y estructura de respuesta.
7. Validar sintaxis con Docker usando `docker compose exec -T agrodemi-dev ruby -c <archivo>`.
8. Volver a llamar los mismos endpoints con `curl`.
9. Comparar baseline vs respuesta nueva con JSON parseado, no solo visualmente.
10. Si hay diferencia, no asumir que es valida: revisar si se perdio/agrego/renombro algun campo o si cambio `nil`, `[]`, `{}`, timestamp, orden o metadata.
11. Revisar logs recientes y confirmar que no aparecen nuevos `active_model_serializers` para esos endpoints.
12. Revisar setup multi-cliente con `rg` en `scripts` y `config_setup` para confirmar si algun template sobreescribe los archivos tocados.
13. Reportar resumen corto y esperar que el usuario valide. No hacer commit hasta que el usuario lo pida.

El usuario validara manualmente. Cuando diga que funciona y pida commit, antes de crear el commit hay que actualizar este documento:

1. Mover la entidad terminada desde `Lista de prioridad pendiente` hacia `Entidades ya optimizadas`.
2. Actualizar `Siguiente entidad inmediata` con la proxima entidad pendiente.
3. Confirmar que la lista pendiente ya no contiene la entidad completada.
4. Incluir esa actualizacion del `.md` en el mismo commit de la entidad optimizada.

Despues de actualizar el `.md`, hacer commit de esa entidad y esperar la orden para continuar con la siguiente. No avanzar automaticamente.

## Contexto actual

Ya existe el helper global:

- `app/serializers/fast_serializer.rb`

Funciones disponibles:

- `serialize_record(record, fields, readers: {})`
- `serialize_collection(collection, fields, readers: {})`
- `show_serialized_field?(params, field)`
- `selected_serialized_fields(param, default_fields, include_all: false)`
- `serialize_selected_record(record, default_fields, param: nil, include_all: false, readers: {})`
- `read_serialized_value(record, field)`

La clase `Response` en `config/initializers/global/functions.rb` ya intenta usar fast serializers automaticamente cuando el serializer del modelo implementa:

- `self.to_hash(object, params={})`
- `self.collection_to_hash(collection, params={})`

Si el serializer no tiene esos metodos, `Response` cae al flujo viejo con `serialize_parser`, por compatibilidad.

## Contexto Docker

Este proyecto esta dockerizado. No asumir que Ruby on Rails, PostgreSQL, gems o la base de datos existen instalados en la maquina local. Para validar comportamiento real del API hay que usar los contenedores.

Contenedores/puertos usados en desarrollo actualmente:

- API Rails: contenedor `agrodemi-dev`.
- Proxy local del API: `http://localhost:9090`.
- Base de datos: contenedor `db-dev`.

Comandos base:

```bash
docker ps --format '{{.Names}} {{.Ports}}'
docker compose exec -T agrodemi-dev ruby -c app/serializers/entidad_serializer.rb
docker compose logs --tail=120 agrodemi-dev
curl -sS 'http://localhost:9090/entidad'
```

Si `curl http://localhost:9090/...` no responde, primero verificar que Docker este levantado y que existan `agrodemi-dev`, `nginx-proxy-dev` y `db-dev`. No intentar correr `rails server`, `bundle exec rails`, `psql` local ni instalar Ruby/Postgres localmente.

Si se necesita ejecutar codigo Rails puntual, hacerlo dentro del contenedor:

```bash
docker compose exec -T agrodemi-dev rails runner 'puts Entidad.count'
```

Si Rails no toma cambios en serializers/initializers por cache o proceso cargado, reiniciar solo el servicio del API con Docker y volver a probar:

```bash
docker compose restart agrodemi-dev
```

## Entidades ya optimizadas

No repetir estas salvo que haya bug:

- `acciones`
- `articulos`
- `cabecera_conduces`
- `cabecera_facturas`
- `clientes`
- `config_articulos`
- `configuracion_cuadres`
- `contenido_articulos`
- `costo_fletes`
- `cuadre_caja_denominaciones`
- `cuadre_caja_eventos`
- `cuadre_caja_movimientos`
- `cuadre_cajas`
- `divisas`
- `documentos_de_identidad`
- `detalles_produccion`
- `detalle_conduces`
- `detalle_facturas`
- `detalle_recibos`
- `detalles_facturas_notas`
- `document_references`
- `ecf_receptions`
- `facturas_aplicadas`
- `formulas_productos_terminados`
- `incidencias`
- `marcas`
- `modelos`
- `movimiento_viajes`
- `municipios`
- `notas`
- `permisos`
- `producciones`
- `provincias`
- `recibos_ingresos`
- `roles`
- `suplidores`
- `tasas_de_cambio`
- `tipo_articulos`
- `tipo_facturas`
- `users` / empleados
- `vehiculos`

## Siguiente entidad inmediata

La siguiente entidad a trabajar es:

1. `commertial_approval_receptions`

Despues de terminar esta entidad, continuar con la lista de prioridad de abajo.

## Lista de prioridad pendiente

Trabajar en este orden, una entidad o grupo pequeno por turno:

1. `commertial_approval_receptions`
5. `calendar_event_types`
6. `calendar_events`
7. `calendar_event_links`
8. `global_holidays`

Nota: `tipo_recibos` (estaba aqui al inicio de la lista) se salto el 2026-08-29 porque no tiene tabla en la BD: el endpoint devuelve `500 PG::UndefinedTable`. Solo existen `resources :tipo_recibos`, `TipoRecibosController` (scaffold `render json:`) y `TipoRecibo`; no hay migracion, schema, datos ni serializer. Quedo pendiente de aclarar si la entidad sigue viva y que columnas deberia tener.

Si una entidad no tiene controller REST directo, buscar donde se serializa con `rg "NombreSerializer|serialize_parser\\(|render json:" app`.

## Patron para serializers

En cada serializer pendiente, conservar los `attribute` existentes para compatibilidad, pero agregar `FastSerializer`:

```ruby
class EntidadSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id, if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id]
  end
end
```

Si el serializer viejo siempre devolvia todos los campos porque el controller usaba `render json:` sin parametros opcionales, entonces `to_hash` debe devolver todos esos campos siempre. Ejemplo:

```ruby
def self.to_hash(object, params={})
  serialize_record(object, default_fields)
end
```

Si el serializer viejo usaba `get_param('all') || has_to_show(...)`, entonces usar:

```ruby
fields = default_fields.select { |field| show_serialized_field?(params, field) }
serialize_record(object, fields, readers: readers)
```

## Campos calculados y anidados

Si un atributo del serializer viejo tiene metodo propio, no leerlo como columna directa sin revisar. Debe pasarse por `readers`.

Ejemplo:

```ruby
def self.to_hash(object, params={})
  serialize_record(object, default_fields, readers: {
    total: ->(record) { record.total },
    cliente: ->(record) { ClienteSerializer.to_hash(record.cliente, params[:cliente] || { all: true }) }
  })
end
```

Si el serializer viejo hacia:

```ruby
optional_params = parse_serialize_optional_params(self.get_param('cliente'), { all: false, id: true, nombre: true })
serialize_parser(object.cliente, optional_params)
```

El fast serializer debe hacer equivalente:

```ruby
def self.cliente_to_hash(object, param=nil)
  optional_params = parse_serialize_optional_params(param, { all: false, id: true, nombre: true })
  ClienteSerializer.to_hash(object.cliente, optional_params)
end
```

Si el serializer anidado aun no esta optimizado, hay dos opciones:

- Si la entidad anidada esta en la lista pendiente y es pequena, optimizarla dentro del mismo turno solo si es dependencia directa imprescindible.
- Si es entidad grande o delicada, mantener `serialize_parser` temporalmente para no cambiar demasiado en un solo paso y anotar que queda pendiente.

## Situaciones y que hacer

### Si el controller usa `Response`

Mantener `Response`. Solo pasar `models_includes` si hay asociaciones:

```ruby
optional_params = get_parametros_opcionales
Response.new(params, nil, Entidad.all, nil, optional_params, Entidad.models_includes_for(optional_params)).send_response self
```

Para `show`:

```ruby
optional_params = get_parametros_opcionales
Response.new(params, nil, @entidad, nil, optional_params, Entidad.models_includes_for(optional_params)).send_response self
```

### Si el controller usa `render json:`

No meter `Response` si eso cambia el contrato. Usar render directo con body:

```ruby
render body: EntidadSerializer.collection_to_hash(records).to_json, content_type: 'application/json'
```

Para paginacion vieja tipo `my_paginate`:

```ruby
res = records.my_paginate(page, per_page)
data = res.merge("data" => EntidadSerializer.collection_to_hash(res["data"]))
render body: data.to_json, content_type: 'application/json'
```

Para un registro:

```ruby
render body: EntidadSerializer.to_hash(@entidad).to_json, content_type: 'application/json'
```

### Si hay `serialize_parser` dentro del modelo

Evitarlo si el resultado puede pasar por `Response#set_data`. Preferir:

```ruby
res.set_data(records, optional_params, Entidad.models_includes_for(optional_params))
```

Si cambiar eso modifica `msg`, `total_registros`, `total_paginas` o estructura de respuesta, mantener el contrato anterior y optimizar solo el serializer usado.

### Si hay `.to_a` antes de paginar

Evitarlo salvo que sea necesario. La paginacion debe quedar en SQL cuando sea `ActiveRecord::Relation`.

Mal:

```ruby
records = Entidad.where(...).to_a
records.my_paginate(page, per_page)
```

Mejor:

```ruby
records = Entidad.where(...)
Response.new(params, nil, records, nil, optional_params, includes).send_response self
```

### Si hay SQL interpolado

Cambiar a bind params sin alterar resultados:

```ruby
where("LOWER(nombre) LIKE LOWER(?)", "%#{arg}%")
```

No cambiar filtros funcionales ni ordenamientos salvo que sea un bug claro.

### Si hay joins/includes y campos virtuales del SELECT

Preservar campos extra. Ejemplo real ya ocurrido: `/modelos/filtro` devolvia `marca_descripcion`; el fast serializer tuvo que incluirlo si `object.has_attribute?(:marca_descripcion)`.

Patron:

```ruby
fields = default_fields.dup
fields.insert(-2, :campo_virtual) if object.respond_to?(:has_attribute?) && object.has_attribute?(:campo_virtual)
```

Leer con:

```ruby
campo_virtual: ->(record) { record.read_attribute(:campo_virtual) }
```

### Si hay ordenamiento desde SQL

No quitarlo. Si el modelo/controller ya trae `.order(...)`, mantenerlo. Si el endpoint antes no tenia orden estable, no agregar orden salvo que el usuario lo haya pedido para esa entidad.

### Si hay `created_at` / `updated_at`

Preservarlos exactamente si antes salian por `render json:`. Rails serializa timestamps con formato ISO; `to_json` de Hash con objetos Time debe mantener formato compatible. Comparar JSON exacto antes/despues.

### Si hay `msg: nil` o ausencia de `msg`

No cambiarlo. Algunos endpoints con `Response.new(params, nil, data, nil, ...)` devuelven `msg: nil`. Otros endpoints con `render json:` no tienen `msg`. Mantener tal cual.

### Si el endpoint devuelve error 404 viejo

No arreglarlo dentro de esta optimizacion salvo que sea necesario para validar. Documentar que el baseline era 404 y no tocar comportamiento.

### Si hay archivos de setup por cliente

Antes de terminar, ejecutar busqueda especifica:

```bash
rg -n "nombre_serializer|NombreController|app/models/nombre|nombre_controller" scripts config_setup config app -g '!log/**' -g '!tmp/**'
```

Si aparece un template en `config_setup`, aplicar el mismo cambio tambien al template correspondiente. Si no aparece, reportar que el setup no sobreescribe esa entidad.

## Includes en modelos

Si una entidad serializa asociaciones, agregar en el modelo un metodo:

```ruby
def self.models_includes_for(params={})
  return nil unless has_to_show(params[:asociacion]) || params[:all]

  :asociacion
end
```

Para anidados:

```ruby
def self.models_includes_for(params={})
  return nil unless params[:all] || has_to_show(params[:detalles])

  has_to_show(params.dig(:detalles, :articulo)) ? { detalles: :articulo } : :detalles
end
```

Usarlo desde controller o desde `res.set_data`.

No precargar asociaciones que no se van a serializar porque puede empeorar endpoints simples.

## Validaciones manuales recomendadas

Antes de modificar hay que validar que responde actualmente el endpoint que se va a optimizar. No basta con leer el serializer: hay que llamar el endpoint real, porque el controller/modelo puede agregar metadata, paginacion, filtros, campos virtuales de SQL o una estructura sin `Response`.

Primero buscar endpoints de la entidad:

```bash
rg -n "resources :entidades|EntidadSerializer|serialize_parser|render json:|custom|filtro" config/routes.rb app/controllers app/models app/serializers
```

Capturar baseline de todos los endpoints relevantes:

```bash
curl -sS -o /tmp/entidad_before.json -w '%{http_code}' 'http://localhost:9090/entidad?paginado=true&page=1&per_page=2'
curl -sS -o /tmp/entidad_show_before.json -w '%{http_code}' 'http://localhost:9090/entidad/ID_REAL'
curl -sS -o /tmp/entidad_filtro_before.json -w '%{http_code}' 'http://localhost:9090/entidad/filtro/%20?paginado=true&page=1&per_page=2'
```

Si el endpoint necesita parametros opcionales para anidados, capturar tambien combinaciones reales:

```bash
curl -sS -o /tmp/entidad_anidado_before.json -w '%{http_code}' 'http://localhost:9090/entidad?paginado=true&page=1&per_page=2&cliente.id=true&cliente.nombre=true'
```

Inspeccionar que se esta enviando al front:

```bash
ruby -rjson -e 'd=JSON.parse(File.read("/tmp/entidad_before.json")); p d.keys; p(d["data"].is_a?(Array) ? d["data"].first : d["data"])'
```

Guardar mentalmente o en notas temporales:

- Si la raiz es un array directo o un hash con `data`.
- Si existe `msg`, y si es `nil`, `[]` o no existe.
- Si existen `total_registros` y `total_paginas`.
- Campos exactos de cada registro.
- Campos calculados que no son columnas.
- Campos virtuales que vienen de `select`, por ejemplo `marca_descripcion`.
- Asociaciones y campos de cada asociacion.
- Si una asociacion sale como `nil`, `{}`, `[]` o no sale.

Despues de cambios:

```bash
curl -sS -o /tmp/entidad_after.json -w '%{http_code}' 'http://localhost:9090/entidad?paginado=true&page=1&per_page=2'
curl -sS -o /tmp/entidad_show_after.json -w '%{http_code}' 'http://localhost:9090/entidad/ID_REAL'
curl -sS -o /tmp/entidad_filtro_after.json -w '%{http_code}' 'http://localhost:9090/entidad/filtro/%20?paginado=true&page=1&per_page=2'
```

Comparar:

```bash
ruby -rjson -e 'a=JSON.parse(File.read("/tmp/entidad_before.json")); b=JSON.parse(File.read("/tmp/entidad_after.json")); puts(a == b ? "OK" : "DIFF"); p a unless a == b; p b unless a == b'
```

Comparar varios archivos en una sola corrida:

```bash
ruby -rjson -e 'names=%w[entidad entidad_show entidad_filtro entidad_anidado]; names.each { |n| before="/tmp/#{n}_before.json"; after="/tmp/#{n}_after.json"; next unless File.exist?(before) && File.exist?(after); a=JSON.parse(File.read(before)); b=JSON.parse(File.read(after)); puts "#{n}: #{a == b ? "OK" : "DIFF"}"; unless a == b; p a; p b; end }'
```

Si sale `DIFF`, revisar primero estas causas:

- Falta una propiedad que antes salia.
- Se agrego una propiedad que antes no salia.
- Cambio la estructura raiz, por ejemplo array directo vs `{ data: ... }`.
- Cambio `msg`, especialmente `nil` vs `[]`.
- Cambio metadata de paginacion.
- Un campo calculado ahora sale distinto.
- Un campo virtual de SQL ya no sale.
- Un timestamp cambio de formato.
- Una asociacion cambio de `nil` a `{}` o de `[]` a `nil`.
- Cambio el orden de registros por modificar el query.

No continuar hasta que el JSON sea igual, salvo que el usuario apruebe explicitamente la diferencia.

Validar sintaxis:

```bash
docker compose exec -T agrodemi-dev ruby -c app/serializers/entidad_serializer.rb
docker compose exec -T agrodemi-dev ruby -c app/models/entidad.rb
docker compose exec -T agrodemi-dev ruby -c app/controllers/entidades_controller.rb
```

Revisar logs:

```bash
docker compose logs --tail=120 agrodemi-dev | rg "active_model_serializers|Rendered ActiveModel|/entidad"
```

Si aparecen lineas viejas de AMS anteriores al cambio, fijarse en timestamp. Lo importante es que las requests nuevas de esa entidad no generen `Rendered ActiveModel...`.

## Criterio de completado por entidad

Una entidad esta completa cuando:

- Los endpoints principales devuelven status HTTP igual que antes.
- El JSON parseado antes/despues es igual.
- No se perdieron propiedades del registro ni de sus dependencias.
- No se agregaron propiedades nuevas salvo que ya existieran en baseline o el usuario lo pida.
- Los includes eliminan N+1 evidentes sin cargar asociaciones innecesarias.
- Los logs nuevos no muestran render de ActiveModelSerializers para esa entidad.
- Se reviso si `scripts/start.js -c X` o `config_setup` sobreescriben archivos modificados.
- El usuario probo y autorizo commit.

## Notas finales para continuar

Trabajar cambios pequenos. Las entidades de facturacion, recibos, notas, conduces y cuadre de caja son delicadas porque tienen muchos anidados y contratos usados por PDF, DGII y flujos de cobro. En esas entidades, primero mapear todos los `attribute`, metodos del serializer, `get_parametros_opcionales`, `models_includes`, scopes y endpoints custom. No reemplazar varios serializers profundos a la vez sin baseline.

No tocar secretos ni configuraciones de Montu/Fraga. No tocar validaciones de permisos/accion en esta fase.
