# Estándar de Flujo para Módulos

Este documento define el estándar general para implementar módulos nuevos o extender módulos existentes en el backend. Aplica a flujos de captura de datos, guardado, actualización, anulación, eliminación, consultas, listados y serialización de respuestas.

La intención es mantener un patrón uniforme: controllers delgados, lógica de negocio centralizada, respuestas consistentes, transacciones para operaciones con efectos secundarios y payloads controlados por serializers.

## Principios Generales

- Mantener cambios mínimos, enfocados y alineados al módulo.
- Respetar nombres, convenciones, helpers, constantes y estructura existente.
- No duplicar reglas de negocio entre controller, model, serializer o frontend.
- El controller no debe contener lógica de negocio compleja.
- El modelo o servicio del dominio debe concentrar validaciones, persistencia y efectos secundarios.
- Toda operación pública del modelo debe devolver un objeto `Response`.
- El resultado final debe responderse desde el controller con `resultado.send_response self`.
- Las operaciones que modifican varias tablas o generan efectos secundarios deben ejecutarse dentro de una transacción.
- Ante errores de validación o negocio, devolver mensajes claros y status HTTP adecuado dentro de `Response`.
- No exponer campos internos en serializers salvo que el frontend los necesite explícitamente.
- Usar constantes existentes para valores de negocio en vez de literales repetidos.
- Evitar refactors generales cuando la tarea sea agregar o modificar un flujo puntual.

## Estructura Recomendada del Flujo

Un flujo estándar debe seguir esta secuencia:

1. Route recibe el request.
2. Controller identifica la acción y delega.
3. Modelo o servicio inicializa `Response`.
4. Modelo o servicio valida datos base.
5. Modelo o servicio calcula datos derivados o secuencias.
6. Modelo o servicio construye la entidad principal.
7. Modelo o servicio procesa dependencias hijas.
8. Modelo o servicio valida errores acumulados.
9. Modelo o servicio persiste dentro de transacción si aplica.
10. Modelo o servicio ejecuta efectos secundarios.
11. Modelo o servicio arma respuesta exitosa o de error.
12. Controller responde con `send_response`.

## Controller

### Responsabilidad

El controller debe ser una capa fina de entrada y salida.

Debe encargarse de:

- Recibir params.
- Resolver callbacks simples como carga de entidad.
- Resolver validaciones previas estrictamente necesarias para la ruta.
- Seleccionar el método del modelo o servicio que maneja el caso.
- Enviar la respuesta.

No debe encargarse de:

- Crear o actualizar múltiples modelos directamente.
- Calcular balances, secuencias, totales o reglas de negocio.
- Procesar dependencias hijas.
- Armar manualmente payloads complejos.
- Definir reglas de listado complejas si ya pertenecen al dominio.
- Repetir validaciones que ya existen en el modelo o servicio.

### Patrón de Acción Simple

```ruby
def create
  resultado = Entidad.crear_entidad(params)
  resultado.send_response self
end
```

```ruby
def update
  resultado = Entidad.actualizar_entidad(params)
  resultado.send_response self
end
```

```ruby
def index
  resultado = Entidad.listar_entidades(params, set_paginate_options(params), get_parametros_opcionales)
  resultado.send_response self
end
```

### Rutas Custom

Cuando un recurso tenga varias consultas o acciones especiales, usar un dispatcher claro basado en `params[:ruta_complemento]` o una ruta dedicada.

El dispatcher debe:

- Inicializar `Response`.
- Usar `case` o estructura equivalente.
- Delegar cada caso al modelo o servicio.
- Responder `not_implemented` cuando la ruta no exista.
- Mantener mensajes simples y consistentes.

Ejemplo:

```ruby
def custom_route
  resultado = Response.new

  case params[:ruta_complemento]
  when 'get_documentos'
    resultado = Entidad.get_documentos(params, set_paginate_options(params), get_parametros_opcionales)
  when 'can_update'
    resultado = Entidad.verificar_actualizacion(params[:id])
  else
    resultado.add_msg('Ruta no encontrada.')
    resultado.set_status(HTTP_STATUS_CODE[:not_implemented])
  end

  resultado.send_response self
end
```

### Callbacks

Usar callbacks solo para carga de entidad o validaciones previas que pertenezcan a la ruta.

Reglas:

- Si la entidad no existe, responder inmediatamente usando el `Response` del helper de busqueda.
- No hacer procesamiento de negocio pesado dentro del callback.
- No modificar estado persistente dentro de callbacks de controller.
- Mantener los callbacks asociados solo a las acciones que realmente los necesitan.

### Parámetros Opcionales de Serialización

Cuando una respuesta pueda variar segun el uso del frontend, centralizar opciones en un método como `get_parametros_opcionales`.

Reglas:

- Incluir `all: true` cuando la vista necesita el payload completo.
- Convertir booleanos con helpers existentes como `to_boolean`.
- Validar presencia con helpers existentes como `validate_optional_param`.
- No pasar params crudos al serializer si basta con flags controlados.
- Mantener nombres de opciones alineados al serializer.

Ejemplo:

```ruby
def get_parametros_opcionales
  {
    all: true,
    detalle: validate_optional_param(params, 'detalle') ? params['detalle'].to_boolean : false
  }
end
```

## Response

### Regla Principal

Toda operación de dominio debe devolver `Response`.

El `Response` debe transportar:

- Data de respuesta.
- Mensajes de exito o error.
- Status HTTP.
- Opciones de paginacion cuando aplique.
- Opciones para serializer cuando aplique.

### Respuesta Exitosa

En una creación o actualización exitosa:

- Setear data con la entidad o colección resultante.
- Pasar opciones de serializer necesarias.
- Agregar mensaje de exito.
- Dejar status default si no requiere uno especial.

Ejemplo:

```ruby
res = Response.new
res.set_data(entidad, { all: true })
res.add_msg('Registro creado correctamente.')
res
```

### Respuesta de Error

En error de validación o negocio:

- Agregar uno o varios mensajes.
- Setear status apropiado.
- Retornar inmediatamente cuando el flujo no puede continuar.

Ejemplo:

```ruby
res.add_msgs(entidad.errors.to_a)
res.set_status(HTTP_STATUS_CODE[:conflict])
return res
```

### Normalización de Mensajes

Cuando un helper reciba uno o varios mensajes:

- Convertir strings sueltos a array si hace falta.
- Usar `add_msgs` para arrays.
- Usar `add_msg` para un mensaje individual.
- No perder mensajes generados por dependencias.

## Modelo o Servicio de Dominio

### Responsabilidad

El modelo o servicio debe contener el flujo de negocio completo del recurso.

Debe encargarse de:

- Validar precondiciones.
- Buscar configuraciones necesarias.
- Calcular secuencias o valores derivados.
- Construir la entidad principal.
- Procesar dependencias hijas.
- Persistir cambios.
- Ejecutar efectos secundarios.
- Armar respuestas.
- Hacer rollback cuando el flujo falle.

### Método Público de Entrada

Cada operación importante debe tener un método público claro.

Ejemplos:

- `crear_entidad(params)`
- `actualizar_entidad(params)`
- `eliminar_entidades(params)`
- `get_entidades_by_params(params, paginate_options, parametros_opcionales)`
- `verificar_actualizacion(id)`

El método público debe:

- Inicializar variables de contexto si el flujo las requiere.
- Abrir transacción cuando hay escritura o efectos secundarios relacionados.
- Delegar en métodos privados de clase para pasos internos.
- Retornar siempre `Response`.

Ejemplo:

```ruby
def self.crear_entidad(params)
  res = Response.new

  Entidad.transaction do
    res = validar_y_crear_entidad(params)
    raise ActiveRecord::Rollback unless res.status_valid
  end

  res
end
```

### Métodos Internos

Dividir el flujo en métodos internos con responsabilidades concretas:

- `validar_y_crear_entidad`
- `build_entidad`
- `validar_balance`
- `find_secuencias`
- `crear_dependencias`
- `procesar_efectos_secundarios`
- `finalizar_entidad`
- `success_create_response`
- `set_error_response`

Reglas:

- Cada método debe hacer una cosa identificable.
- Usar early returns para cortar el flujo cuando una validación falla.
- No continuar con persistencia si un `Response` previo no es valido.
- Mantener los métodos privados si no son API del modelo.

## Captura de Datos

### Params

La captura desde `params` debe ocurrir en un solo punto del flujo siempre que sea posible.

Reglas:

- Asignar atributos explicitamente.
- Evitar asignación masiva si el recurso tiene reglas de negocio sensibles.
- Mantener nombres de params alineados con el frontend cuando ya existe contrato.
- No transformar valores exactos a menos que el dominio lo requiera.
- No limpiar strings sensibles como contraseñas o valores que pueden necesitar espacios exactos.
- Convertir booleanos solo cuando el contrato lo entregue como string.
- Preservar `nil` cuando el campo sea opcional y su ausencia tenga significado.

### Construcción de Entidad Principal

La entidad principal debe construirse antes de guardar dependencias.

Reglas:

- Inicializar defaults del sistema primero.
- Asignar usuario actual desde helper existente.
- Calcular fechas derivadas antes de asignar campos dependientes.
- Calcular numeros, codigos o secuencias antes de asignarlos.
- Asignar campos recibidos desde params de forma explicita.
- Ejecutar validaciones de negocio del modelo antes de guardar.
- Retornar la instancia construida aunque tenga errores para que el caller pueda leerlos.

Ejemplo:

```ruby
def self.build_entidad(params, data_derivada)
  entidad = Entidad.new

  entidad.user_id = get_current_user[:id]
  entidad.estado = true
  entidad.codigo = data_derivada[:codigo]
  entidad.nombre = params[:nombre]
  entidad.total = params[:total]

  entidad.otras_validaciones(params)
  entidad
end
```

### Validaciones de Negocio

Las validaciones especificas del flujo deben ejecutarse antes del `save!`.

Reglas:

- Usar validaciones ActiveRecord para presencia y reglas estructurales del modelo.
- Usar métodos como `otras_validaciones` para reglas dependientes de params o contexto.
- Agregar errores con `errors.add`.
- Validar duplicados antes de construir dependencias costosas.
- Validar balances, limites o disponibilidad antes de persistir.
- Devolver errores usando `Response`, no excepciones visibles al controller.

## Guardado de Datos

### Transacciones

Usar transacciones para operaciones que:

- Crean una entidad y sus detalles.
- Actualizan balances.
- Consumen o actualizan secuencias.
- Modifican inventario.
- Modifican viajes o movimientos.
- Crean referencias entre documentos.
- Dependen de servicios externos pero deben preservar consistencia local.
- Anulan o eliminan varios registros.

Reglas:

- Abrir la transacción en el método público o en el método de dominio principal.
- Hacer `raise ActiveRecord::Rollback` cuando `Response` no sea valido.
- Hacer rollback si la entidad acumula errores.
- No enviar respuestas HTTP desde el modelo.
- Retornar el `Response` al controller.

### Persistencia

Reglas:

- Usar `save!` cuando el flujo esta dentro de transacción y se espera rollback.
- Revisar errores de la entidad despues de procesar dependencias.
- No actualizar secuencias antes de confirmar que la entidad y dependencias son validas.
- No ejecutar efectos secundarios posteriores si la entidad no se guardo.
- Releer la entidad cuando la respuesta necesita datos ya persistidos o callbacks aplicados.

### Dependencias Hijas

Cuando un recurso tiene hijos o detalles:

- Procesarlos desde un método dedicado.
- Usar utilidades existentes como `crear_actualizar_dependencias` si el proyecto ya las usa.
- Pasar el padre sin guardar cuando las asociaciones pueden construirse en memoria.
- Asignar las dependencias al padre desde el bloque del helper.
- Propagar errores de dependencias al `Response`.

Ejemplo:

```ruby
dependencias = [
  { modelo: DetalleEntidad, key_object: 'detalles', padre: entidad }
]

crear_actualizar_dependencias(dependencias, params, false) do |key_object, dependencia_data|
  entidad.detalles = dependencia_data if key_object == 'detalles'
end
```

### Efectos Secundarios

Los efectos secundarios deben estar en métodos separados y ejecutarse en orden claro.

Ejemplos:

- Actualizar balance de cliente.
- Actualizar inventario.
- Actualizar secuencias.
- Crear movimientos.
- Marcar documentos relacionados como pagados.
- Enviar datos a servicios externos.
- Guardar referencias entre documentos.

Reglas:

- Cada efecto secundario debe devolver `Response` cuando pueda fallar.
- Si el efecto secundario es obligatorio para la consistencia, debe participar en la transacción.
- Si un servicio externo devuelve error, el flujo debe decidir si se revierte o si responde con ese error.
- No ocultar errores de dependencias.
- No duplicar efectos secundarios si el flujo se reintenta.

## Secuencias, Códigos y Valores Derivados

Cuando un módulo use secuencias o códigos:

- Calcular la siguiente secuencia antes de construir la entidad.
- Validar que exista la configuración requerida.
- Validar duplicados antes de guardar.
- Formatear códigos en un método dedicado.
- Actualizar la secuencia solo al final, despues de guardar correctamente.
- Diferenciar secuencias internas de secuencias externas o fiscales si existen.
- Usar constantes para tipos, series, keys o descripciones.

Patrón:

```ruby
res_secuencias = Entidad.find_secuencias(params)
return set_error_response(Response.new, res_secuencias.get_msgs.to_a) unless res_secuencias.status_valid

data_secuencias = res_secuencias.get_data
return set_error_response(Response.new, 'El número ya existe.') if entidad_existente?(params, data_secuencias)
```

## Actualización

### Flujo Estándar

Una actualización debe:

1. Buscar la entidad.
2. Verificar si puede actualizarse.
3. Validar efectos sobre balances, inventario u otros agregados.
4. Procesar detalles o dependencias.
5. Asignar campos permitidos.
6. Guardar dentro de transacción.
7. Retornar entidad actualizada serializada.

### Reglas

- No permitir actualización si el documento tiene pagos, notas, cierres o dependencias que bloqueen el cambio.
- La verificación de actualización debe vivir en un método dedicado.
- Ajustar balances solo por la diferencia entre valor nuevo y valor anterior.
- No reemplazar dependencias sin revertir primero sus efectos anteriores cuando aplique.
- Mantener mensajes de bloqueo especificos.
- Retornar status `conflict` cuando el estado de negocio impide actualizar.

## Anulación y Eliminación

### Anulación

Usar anulación lógica cuando el registro debe mantenerse para trazabilidad.

Reglas:

- Cambiar `estado` a `false`.
- Revertir balances o movimientos si aplica.
- Procesar detalles con método dedicado.
- Retornar colección de exitos y errores cuando se procesan multiples IDs.

### Eliminación Física

Usar eliminación física solo cuando el dominio lo permita.

Reglas:

- Validar dependencias antes de destruir.
- Revertir efectos secundarios antes de eliminar.
- No destruir registros con trazabilidad fiscal, contable o historica si el dominio exige conservarlos.
- Devolver errores por registro si una eliminación parcial falla.

## Pagos, Balances y Agregados

Cuando una operación afecte balances:

- Centralizar el calculo en métodos del dominio correspondiente.
- Calcular diferencias contra el valor anterior.
- Truncar o redondear de forma consistente si el dominio trabaja con decimales.
- Marcar como pagado solo cuando el balance llegue a cero o el pago sea total.
- Registrar fecha de completado cuando el documento queda cerrado.
- Revertir balance cuando se anula o elimina un documento que lo habia afectado.

## Listados y Consultas

### Métodos de Listado

Los listados deben vivir en métodos del modelo o servicio.

Cada método debe:

- Inicializar `Response`, incluyendo paginación si aplica.
- Parsear params de filtros.
- Convertir valores al tipo esperado.
- Construir condiciones.
- Aplicar joins solo cuando sean necesarios.
- Usar `includes` para relaciones que el serializer va a leer.
- Ordenar de forma consistente.
- Agrupar cuando un join pueda duplicar filas.
- Retornar mensajes claros cuando no hay resultados.

### Filtros

Reglas:

- Reutilizar clases/helpers de params cuando existan.
- Decodificar o parsear valores en un solo punto.
- No repetir lógica de filtros en el controller.
- Mantener default de tipo, estado, serie o pagada segun el contrato del modulo.
- Evitar traer registros inactivos salvo que el filtro lo pida.

### Respuesta Sin Resultados

Cuando no hay resultados:

- Si no existe ningun registro base, usar mensaje de ausencia general.
- Si hay registros pero no coinciden con filtros, usar mensaje de especificaciones.
- Setear status segun el caso (`conflict`, `not_found` u otro ya usado por el modulo).

## Includes y Performance

### `models_includes`

Cada modelo con serializers complejos debe exponer un método centralizado para includes.

Reglas:

- Incluir asociaciones que el serializer consume.
- Incluir asociaciones anidadas necesarias para campos derivados.
- Reutilizar `models_includes` en show, listados y respuestas post-guardado cuando aplique.
- No agregar includes que ningun serializer o flujo usa.
- Revisar includes cuando se agregue un campo derivado que lea asociaciones.

Ejemplo:

```ruby
def self.models_includes
  [
    :tipo,
    { cliente: :documentos_de_identidad },
    { detalles: :articulo },
    :user
  ]
end
```

## Serializer

### Responsabilidad

El serializer define el contrato de salida hacia el frontend.

Debe encargarse de:

- Exponer atributos permitidos.
- Controlar campos por flags.
- Serializar relaciones.
- Armar campos derivados simples.
- Ocultar campos internos.

No debe encargarse de:

- Ejecutar reglas de negocio.
- Modificar registros.
- Consultar datos pesados que debieron incluirse previamente.
- Exponer campos internos solo porque existen en DB.

### Atributos Condicionales

Usar flags de `@instance_options` para controlar salida.

Patrón:

```ruby
attribute :id, if: Proc.new { self.get_param('all') || self.get_param('id') }
attribute :detalles, if: Proc.new { self.get_param('all') || self.get_param('detalles') }
```

Reglas:

- `all` debe representar payload completo de la vista principal.
- Campos costosos o relaciones grandes deben poder activarse/desactivarse.
- Usar nombres de flags estables y claros.
- No serializar valores sensibles o internos por default.

### Relaciones y Campos Derivados

Reglas:

- Usar `serialize_parser` para relaciones cuando el proyecto ya lo usa.
- Para datos opcionales, devolver `nil`, `{}` o `[]` de forma consistente con el contrato existente.
- Para entidades alternativas o casuales, construir un objeto compatible con la forma esperada por el frontend.
- No asumir que una asociación existe si es opcional.
- Evitar queries dentro del serializer cuando se pueda resolver con includes.

### Método `get_param`

Mantener un helper simple para leer opciones:

```ruby
def get_param(col)
  @instance_options[:"#{col}"]
end
```

## Servicios Externos

Cuando el flujo dependa de servicios externos:

- Encapsular el envio en un manager o servicio dedicado.
- Validar si aplica enviar antes de llamar el servicio.
- Guardar respuesta externa solo desde el componente responsable.
- Devolver `Response` desde el manager.
- Si el servicio falla y el documento no debe persistir, propagar el error y hacer rollback.
- Si el servicio consume una secuencia externa, actualizar la secuencia segun la respuesta real del servicio.
- Mantener campos internos del servicio fuera del serializer salvo requerimiento explícito.

## Estados y Campos Internos

Reglas:

- `estado` representa vigencia logica del registro cuando el dominio lo use.
- Campos internos de control no deben viajar al frontend si no son parte del contrato.
- Flags internos deben persistirse solo cuando el request los provee o cuando el dominio los calcula.
- No agregar un campo al serializer solo porque se agrego a la tabla.
- Cuando un campo nuevo afecta reglas de negocio, actualizar validaciones, creación, actualización, listados y serializer segun corresponda.

## Mensajes y Status

### Mensajes

Reglas:

- Mensajes de exito deben indicar la accion completada.
- Mensajes de error deben indicar la causa de negocio.
- No usar mensajes genericos si hay una validación especifica.
- Propagar mensajes de dependencias.
- Mantener idioma y tono consistente con el modulo.

### Status HTTP

Usar los status definidos en `HTTP_STATUS_CODE`.

Guía:

- `conflict`: regla de negocio impide completar la operación.
- `not_found`: recurso o resultado requerido no existe.
- `bad_request`: parametros invalidos o precondicion externa invalida.
- `internal_server_error`: configuración requerida ausente o error interno no recuperable.
- `not_implemented`: ruta custom no soportada.

## Constantes y Literales

Reglas:

- Usar constantes existentes para tipos, descripciones, keys, series y estados de negocio.
- No duplicar strings de negocio en varios lugares.
- Si un literal ya existe como constante, usar la constante.
- Si se introduce un nuevo valor repetible, crear constante en el lugar correspondiente del proyecto.
- Evitar comparar contra texto visible de UI si existe key estable.

## Nombres y Convenciones

Reglas:

- Mantener nombres existentes aunque no sean ideales si ya forman parte del contrato.
- No renombrar params, columnas o atributos serializados sin migración de contrato.
- Usar nombres descriptivos para métodos de dominio.
- Mantener estilo de métodos existente en el modulo.
- No mezclar idiomas dentro de un mismo concepto nuevo si el modulo ya tiene una convención.

## Checklist Para Implementar un Módulo Nuevo

Antes de implementar:

- Identificar rutas necesarias.
- Identificar entidad principal.
- Identificar dependencias hijas.
- Identificar efectos secundarios.
- Identificar campos internos y campos expuestos.
- Identificar reglas de validación.
- Identificar si necesita secuencias.
- Identificar si necesita transacciones.
- Identificar includes requeridos por serializer.

Durante implementación:

- Crear controller delgado.
- Crear métodos públicos de modelo o servicio.
- Crear métodos internos para validación, construcción, dependencias y finalización.
- Usar `Response` en todas las salidas.
- Usar transacciones en escrituras compuestas.
- Centralizar filtros de listado.
- Definir serializer con atributos condicionales.
- No exponer campos internos.
- Propagar errores de dependencias.

Antes de cerrar:

- Revisar que el controller no tenga lógica de negocio pesada.
- Revisar que no haya efectos secundarios fuera de transacción cuando deban ser atomicos.
- Revisar que errores agreguen mensajes y status.
- Revisar que el serializer tenga flags correctos.
- Revisar que listados usen includes necesarios.
- Revisar que no se hayan tocado contratos no relacionados.

## Checklist Para Extender un Módulo Existente

Antes de modificar:

- Leer controller, modelo, serializer y rutas activas del modulo.
- Identificar método real usado por la ruta.
- Verificar si el campo debe capturarse, persistirse, listarse o solo usarse internamente.
- Buscar si existen constantes para el nuevo valor.
- Revisar si hay dependencias o efectos secundarios relacionados.

Al agregar un campo:

- Agregar migración si aplica.
- Asignar el campo en el builder o método de captura correspondiente.
- Definir default o backfill si los registros existentes lo necesitan.
- Agregar validación solo si el dominio lo exige.
- Agregar al serializer solo si el frontend lo necesita.
- Agregar a filtros o listados solo si debe buscarse o mostrarse.
- Revisar managers externos si el campo cambia reglas de envio.

Al agregar una dependencia hija:

- Agregar asociación en el modelo.
- Agregar includes si el serializer la lee.
- Procesar creación/actualización con el helper de dependencias existente.
- Revertir efectos anteriores en update/delete si aplica.
- Serializar con flag propio si puede ser costosa.

## Antipatrones a Evitar

- Meter creación de hijos directamente en el controller.
- Responder desde el modelo usando `send_response`.
- Retornar hashes crudos cuando el estándar espera `Response`.
- Actualizar secuencias antes de guardar la entidad.
- Exponer campos internos en serializer sin necesidad.
- Repetir filtros SQL en controller y modelo.
- Hacer queries pesadas dentro del serializer.
- Ignorar mensajes de error de dependencias.
- Continuar el flujo despues de un `Response` invalido.
- Agregar refactors no relacionados al cambio solicitado.
- Cambiar nombres de params o payload sin coordinar contrato con frontend.
- Ejecutar efectos secundarios sin rollback cuando forman parte de la misma operación de negocio.

## Plantilla Base

```ruby
class Entidad < ApplicationRecord
  def self.models_includes
    [
      :user
    ]
  end

  def self.crear_entidad(params)
    res = Response.new

    Entidad.transaction do
      res = validar_y_crear_entidad(params)
      raise ActiveRecord::Rollback unless res.status_valid
    end

    res
  end

  private_class_method def self.validar_y_crear_entidad(params)
    res_validacion = validar_precondiciones(params)
    return set_error_response(Response.new, res_validacion.get_msgs.to_a) unless res_validacion.status_valid

    entidad = build_entidad(params)

    res_dependencias = crear_dependencias_entidad(entidad, params)
    return set_error_response(res_dependencias, entidad.errors.to_a) unless res_dependencias.status_valid && entidad.errors.empty?

    return set_error_response(Response.new, entidad.errors.to_a) unless entidad.save!

    res_finalizacion = finalizar_entidad(entidad)
    return set_error_response(res_finalizacion, res_finalizacion.get_msgs.to_a) unless res_finalizacion.status_valid

    success_create_response(entidad)
  end

  private_class_method def self.build_entidad(params)
    entidad = Entidad.new
    entidad.user_id = get_current_user[:id]
    entidad.estado = true
    entidad.nombre = params[:nombre]
    entidad.otras_validaciones(params)
    entidad
  end

  private_class_method def self.success_create_response(entidad)
    res = Response.new
    res.set_data(entidad, { all: true })
    res.add_msg('Registro creado correctamente.')
    res
  end

  private_class_method def self.set_error_response(res, msgs)
    msgs = [msgs] unless msgs.is_a?(Array)
    res.add_msgs(msgs)
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end
end
```
