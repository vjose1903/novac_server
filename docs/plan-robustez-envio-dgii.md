# Plan: robustez del envío de e-CF a la DGII

## Objetivo

Evitar que una espera indefinida, un socket reutilizado o una respuesta inválida de la DGII termine en un error ambiguo para el cliente, y conservar suficiente información técnica para diagnosticar el caso sin exponer XML, certificados, tokens ni datos sensibles.

## Hallazgos que motivan el plan

- El cliente Ruby espera hasta 60 segundos al microservicio DGII (`BaseRequest::Client`).
- El cliente Axios del microservicio no define un timeout total propio (`timeout: 0` en el error observado).
- El envío a `/eCF/recepcionfc/api/recepcion/ecf` ha producido `Net::ReadTimeout` y `HPE_INVALID_CONSTANT`.
- `DGII_MANAGER.send_document_to_dgii` intenta ejecutar `with_indifferent_access` sobre cualquier excepción. Una excepción de Faraday no es un Hash y genera un segundo `NoMethodError`, ocultando la causa real.
- El resultado actual usa `secuenciaUtilizada: false` también cuando el resultado del envío es desconocido. Un timeout posterior a la transmisión no demuestra que la DGII no haya recibido el comprobante.
- El XML firmado se procesa en memoria y no queda disponible para comparar el documento enviado con la respuesta de la DGII.

## Diseño propuesto

### 1. Clasificar explícitamente el resultado del envío

Definir un contrato común entre el microservicio y Rails:

- `accepted`: la DGII confirmó recepción/aceptación.
- `rejected`: la DGII respondió con rechazo o validación definitiva.
- `validation_error`: respuesta 4xx con detalle de la DGII.
- `auth_error`: token o certificado inválido/expirado.
- `transport_error`: DNS, conexión, TLS, timeout o respuesta HTTP inválida.
- `unknown`: se agotó la espera después de enviar y no puede determinarse si la DGII recibió el comprobante.

Cada respuesta debe incluir `request_id`, `e_ncf`, `track_id` si existe, `retryable`, `sequence_status` (`unused`, `used`, `unknown`) y un `error_code` estable. No depender de analizar textos libres para decidir el flujo.

Cuando la DGII devuelva un `trackId`, debe persistirse inmediatamente en la base de datos antes de iniciar el sondeo de estado, construir respuestas adicionales o ejecutar lógica no esencial. El microservicio debe devolverlo en su respuesta estructurada y Rails debe hacer un `upsert` del intento identificado por cliente/RNC y e-NCF. La escritura debe ser pequeña, transaccional y reintentable; si falla, debe conservarse el `trackId` en el contexto del error y marcar el intento como pendiente de persistencia para recuperarlo, sin reenviar el comprobante.

### 2. Definir tiempos de espera por etapa

Configurar límites separados en Axios y Faraday:

- conexión TCP: 10–15 segundos;
- negociación TLS: 15 segundos;
- envío del body: 30 segundos;
- espera de headers/respuesta DGII: 45–60 segundos;
- timeout total del request: máximo 75 segundos, incluyendo margen de serialización.

Usar `AbortController`/cancelación en Node y `open_timeout`/`timeout` en Faraday. El timeout debe devolver un error estructurado, nunca dejar una promesa pendiente ni un request abierto indefinidamente.

### 3. Evitar reintentos peligrosos de un POST

No repetir automáticamente el POST de recepción cuando el resultado sea `timeout`, `HPE_INVALID_CONSTANT` o conexión cerrada después de transmitir el body. En esos estados el comprobante pudo haber sido recibido.

El flujo seguro será:

1. generar y conservar un `request_id` y el e-NCF;
2. consultar el estado de recepción por `trackId` cuando exista;
3. si no existe `trackId`, consultar la disponibilidad del e-NCF mediante el endpoint de consulta permitido por DGII;
4. solo reenviar cuando la consulta confirme que no fue recibido y la política de reintento lo permita;
5. bloquear reintentos simultáneos para el mismo cliente, RNC y e-NCF.

Los reintentos automáticos con backoff y jitter se reservarán para fallos ocurridos antes de abrir/transmitir la solicitud, o para consultas idempotentes de estado. Implementar un límite de intentos y un circuit breaker para no saturar la DGII.

#### Validación de recepción cuando el POST es ambiguo

Cuando el envío termine en `timeout`, `HPE_INVALID_CONSTANT`, `ECONNRESET` o cualquier otro error ocurrido después de iniciar la transmisión, el sistema debe considerar el resultado como `unknown`. No debe generar otro e-CF ni reutilizar inmediatamente el mismo e-NCF.

La reconciliación debe seguir este flujo:

1. Si la respuesta contiene `trackId`, consultar `consultaresultado/api/consultas/estado?trackid={trackId}` hasta obtener un estado final. Mientras esté `En Proceso`, continuar con backoff y un límite de tiempo.
2. Si no se recibió `trackId`, consultar `consultatrackids/api/trackids/consulta?rncemisor={rnc}&encf={eNCF}` usando el token delegado del emisor. Esta consulta permite encontrar un `trackId` que la DGII haya generado aunque la respuesta del POST se haya perdido.
3. Si la consulta por e-NCF devuelve uno o más registros, guardar el `trackId`, `estado` y `fechaRecepcion`, y continuar la consulta por `trackId` cuando el estado sea `En Proceso`.
4. Tratar `Aceptado` y `Aceptado Condicional` como recepción confirmada; tratar `Rechazado` como recepción confirmada con error fiscal y conservar los mensajes y `secuenciaUtilizada`.
5. Si permanece `No encontrado`, repetir únicamente la consulta idempotente durante una ventana acotada. Solo después de agotar esa ventana, registrar el intento para revisión y permitir un nuevo e-NCF según una política explícita; nunca asumir inmediatamente que el número está libre.
6. Antes de crear otro comprobante, verificar nuevamente el e-NCF y bloquear concurrencia por `(RNC emisor, e-NCF)` para evitar dos envíos simultáneos.

La consulta `consultaestado/api/consultas/estado` por RNC, e-NCF, RNC comprador y código de seguridad puede utilizarse como verificación fiscal secundaria cuando esos datos estén disponibles, pero no reemplaza la consulta de `TrackId` para resolver un POST cuyo resultado de transporte es desconocido.

### 3.1. Validación previa como barrera de envío

La consulta previa del e-NCF no debe quedarse como un log diagnóstico. Debe ser una barrera explícita antes del POST de recepción. El microservicio debe consultar el endpoint de DGII que busca `TrackId` por `(RNC emisor, e-NCF)` y clasificar la respuesta en tres estados:

- `used`: DGII devuelve uno o más registros para el e-NCF. No se realiza el POST. Se devuelve `sequence_status: used` para que Rails avance la secuencia y genere el siguiente e-NCF.
- `available`: DGII confirma que no existe recepción para el e-NCF. Se permite el POST.
- `unknown`: timeout, error de autenticación, respuesta incompleta o indisponibilidad de la consulta. No se realiza el POST ni se reutiliza la secuencia; el envío queda pendiente de verificación.

Para reducir la latencia, el firmado del XML y esta consulta pueden ejecutarse en paralelo. El POST solo comienza después de que la consulta termine con `available`. Si devuelve `used`, se descarta el XML firmado y se evita enviar una factura que ya tiene una secuencia ocupada. No se debe interpretar un timeout como `available`.

La consulta no debe depender de analizar mensajes libres ni de inferir el estado a partir de `trackId` ausente. La respuesta estructurada del microservicio debe incluir `sequence_status`, `e_ncf`, `track_id` si existe y un código estable. Rails debe conservar la reserva del e-NCF mediante una operación atómica y una restricción única por `(RNC emisor, e-NCF)`, de modo que dos workers no puedan validar y enviar la misma secuencia simultáneamente.

La respuesta `available` solo autoriza ese intento de envío; no debe almacenarse como una garantía permanente, porque otro proceso podría ocupar la secuencia después de la consulta. Si la consulta de DGII devuelve `No encontrado` pero existe una respuesta inconsistente o no concluyente, se debe tratar como `unknown` y no enviar.

### 4. Reparar el manejo de excepciones en Rails

Cambiar `send_document_to_dgii` para no llamar métodos de Hash sobre excepciones. Normalizar cualquier excepción a un Hash seguro con:

- clase (`Faraday::TimeoutError`, `Faraday::ConnectionFailed`, etc.);
- código interno;
- status HTTP si existe;
- mensaje sanitizado;
- `cause` resumida;
- `retryable` y `sequence_status`.

En `DGII_MANAGER.send`, validar el tipo de respuesta antes de acceder a `[:data]`. Si la respuesta es `unknown`, guardar el documento como pendiente de verificación y devolver un conflicto controlado, sin marcarlo automáticamente como rechazado ni liberar la secuencia como no utilizada.

### 5. Normalizar errores en el microservicio

Crear un adaptador único para Axios/DGII que convierta:

- `ECONNABORTED`, `ETIMEDOUT`, `ECONNRESET`, `ENOTFOUND`;
- `HPE_INVALID_CONSTANT`;
- respuestas HTTP 4xx/5xx;
- errores de autenticación o certificado;

en el contrato común. Mantener el `cause` solo en logs internos y enviar al API un mensaje funcional sin stack trace.

El endpoint del microservicio debe responder siempre JSON válido, incluso en errores, con status apropiado (`400`, `401/403`, `409`, `502`, `504`) y `request_id`.

### 6. Cola de envíos y continuidad operativa

La creación de la factura en Rails no debe depender de que la DGII esté disponible en ese instante. La factura y su e-NCF deben guardarse primero en una transacción local, junto con un registro de envío en estado `queued`. El e-NCF queda reservado para esa factura y no puede ser asignado a otra mientras el envío esté pendiente.

Un worker de Rails tomará los registros de la cola y llamará al microservicio. La cola debe ser durable, con reintentos diferidos, backoff exponencial y jitter. Los errores de DNS, conexión, timeout, `5xx`, `HPE_INVALID_CONSTANT` y circuit breaker abierto deben devolver el trabajo a la cola; los errores definitivos de XML, autenticación o validación fiscal deben detener el reintento automático y marcar la factura como `rejected` o `needs_review` según el caso.

Estados mínimos del envío:

- `queued`: factura creada localmente, pendiente de envío;
- `sending`: un worker posee el trabajo mediante un lease con vencimiento;
- `sent_pending_validation`: la DGII devolvió un `trackId`, pero falta el resultado final;
- `accepted`, `accepted_conditional` o `rejected`: resultado fiscal definitivo;
- `unknown`: se perdió la respuesta y requiere reconciliación por `trackId` o RNC/e-NCF;
- `needs_review`: se agotó la política de reintentos o existe una inconsistencia que requiere intervención.

El worker debe ser idempotente: antes de enviar debe comprobar si el registro ya tiene `trackId` o un resultado final. Si el microservicio devuelve un `trackId`, debe guardarlo y cambiar el estado a `sent_pending_validation` antes de liberar el trabajo. Si ocurre un timeout después de transmitir, el trabajo no debe volver a enviarse ciegamente; debe pasar a `unknown` y ejecutar la reconciliación definida anteriormente.

La disponibilidad de la DGII debe controlarse con circuit breaker. Cuando se detecte una interrupción, los nuevos documentos continúan entrando a `queued` y el sistema responde al usuario que quedaron pendientes de envío. Al recuperarse el servicio, el worker reanuda la cola respetando el orden o la prioridad definida, sin crear facturas duplicadas.

La cola debe tener límite de intentos, prioridad, visibilidad de antigüedad, métricas de backlog y una tarea periódica que recupere leases vencidos. Ninguna factura debe pasar a `accepted` solo por haber sido encolada o por recibir un `trackId`; la aceptación final siempre debe provenir de una consulta posterior a la DGII.

### 6.1. Latencia del API y decisión de impresión

La operación de creación no debe esperar al microservicio, al `TrackId` ni a la aceptación final. Después de confirmar la transacción local y registrar el trabajo `queued`, Rails debe responder al frontend para que la factura pueda continuar su flujo de impresión. El envío y la reconciliación se ejecutan en segundo plano mediante la cola.

La representación impresa debe depender del estado persistido:

- `accepted` o `accepted_conditional`: imprimir la representación normal con e-NCF, datos de validación y QR;
- `queued`, `sending`, `sent_pending_validation`, `unknown` o contingencia por indisponibilidad de la DGII: imprimir la representación de contingencia, con el e-NCF y la leyenda correspondiente, pero sin QR de validación;
- `rejected`: no imprimirla como representación fiscal válida y mostrar el motivo del rechazo.

El endpoint de creación debe responder con un estado de impresión (`normal`, `contingency`, `pending_validation` o `rejected`) para que el frontend no tenga que inferirlo. Si el negocio exige que la primera impresión sea siempre la representación normal con QR, eso requiere esperar la confirmación de la DGII y entra en conflicto con la latencia objetivo; la alternativa compatible con una respuesta rápida es imprimir contingencia y permitir una reimpresión normal cuando la aceptación quede confirmada.

### 7. Manejar conexiones y keep-alive

Revisar el agente HTTPS de Axios. Configurar límites de sockets, TTL de conexiones y manejo de `ECONNRESET`; destruir y recrear el socket cuando falle la lectura. Evitar reutilizar una conexión que la DGII cerró silenciosamente. Comparar el comportamiento con keep-alive desactivado en una prueba controlada antes de elegir la configuración definitiva.

### 8. Persistencia e idempotencia

Agregar o reutilizar un registro de intento de envío con:

- cliente/RNC, e-NCF y hash del XML firmado;
- `request_id`, fecha, intento y etapa;
- estado (`pending`, `accepted`, `rejected`, `unknown`);
- `trackId`, código y mensaje DGII;
- fecha de última consulta.

El `trackId` debe guardarse en cuanto llegue la respuesta de recepción, incluso si el estado inicial es `En Proceso`, antes de cualquier consulta posterior. La persistencia debe:

- usar una operación atómica que permita insertar o actualizar el intento existente;
- conservar el primer `trackId` y registrar cualquier `trackId` adicional devuelto para el mismo RNC/e-NCF;
- tener índices por `(RNC emisor, e-NCF)` y por `trackId` para resolver rápidamente la reconciliación;
- actualizar estado y fecha de consulta por separado, sin borrar el `trackId` ante un timeout posterior;
- publicar o encolar la consulta de estado después de confirmar la escritura.

Usar una restricción única para impedir dos envíos concurrentes del mismo e-NCF. Un proceso de reconciliación debe revisar estados `unknown` y consultar DGII sin crear facturas duplicadas.

### 9. Observabilidad segura

Registrar logs estructurados con `request_id`, e-NCF parcialmente enmascarado, duración, etapa, endpoint y código de error. Nunca registrar:

- `Authorization: Bearer`;
- certificados, contraseñas o `SIGNATURE_PSW`;
- XML completo en logs;
- datos completos de clientes.

Para depuración temporal, guardar el XML firmado cifrado o en un almacenamiento privado con TTL corto, permisos restringidos y hash de integridad. El modo de diagnóstico debe expirar automáticamente y no habilitarse mediante un archivo accesible sin control.

Agregar métricas y alertas para timeouts, `HPE_INVALID_CONSTANT`, respuestas 4xx/5xx, estados `unknown`, duración p95/p99 y porcentaje de reintentos.

### 10. Respuesta del API al frontend

El frontend debe distinguir entre:

- rechazo definitivo: mostrar el mensaje DGII;
- error transitorio: permitir reintentar solo después de consultar el estado;
- resultado desconocido: mostrar que se está verificando el comprobante y bloquear un nuevo envío del mismo e-NCF;
- aceptación: continuar el flujo actual.

La respuesta de creación debe llegar después de la persistencia local, sin esperar a la DGII, e incluir el estado de impresión y un identificador para consultar posteriormente la aceptación. El frontend no debe mostrar una factura pendiente como aceptada.

El flujo de impresión será asíncrono:

1. La creación responde rápido con `estado: pending_validation` y `puedeImprimir: false`.
2. El frontend espera una notificación SSE/WebSocket o consulta `GET /facturas/:id/estado-impresion` con backoff progresivo, sin consultar directamente a la DGII.
3. Ruby responde `puedeImprimir: true` y `tipoImpresion: normal` únicamente para `accepted` o `accepted_conditional`.
4. Solo después de esa autorización el frontend solicita el PDF normal con e-NCF y QR.
5. Para una contingencia explícitamente habilitada, Ruby puede responder `tipoImpresion: contingency`; ese PDF lleva la leyenda de contingencia y se genera sin QR.
6. Si el estado es `rejected`, `unknown` o continúa `pending_validation`, Ruby mantiene `puedeImprimir: false` para la representación fiscal normal.

El endpoint que genera el PDF debe repetir la validación en Rails y rechazar la solicitud si la factura no está autorizada, aunque el frontend intente saltarse la pantalla o reutilizar una respuesta anterior. Los requests de estado deben detenerse al llegar a un estado terminal y tener límite de tiempo para no generar polling indefinido. Si se usa SSE/WebSocket, la consulta periódica debe mantenerse como mecanismo de recuperación cuando se pierda la conexión.

No mostrar al usuario stacks, respuestas completas de Axios/Faraday ni detalles de certificados.

### 11. Módulo de búsqueda y administración de envíos

El módulo de búsqueda de facturas debe mostrar el estado fiscal y el estado técnico del envío por separado. La API de listado y detalle debe incluir, como mínimo:

- `estado_factura` y `estado_envio`;
- e-NCF, `trackId` cuando exista y fecha de última consulta;
- cantidad de intentos, próximo intento y último error funcional;
- `puede_imprimir`, `tipo_impresion` y si la factura está en contingencia;
- mensajes de rechazo o motivo por el que quedó en `unknown` o `needs_review`.

La búsqueda debe poder filtrar por e-NCF, fecha, cliente, estado fiscal (`accepted`, `accepted_conditional`, `rejected`), estado de cola (`queued`, `sending`, `sent_pending_validation`, `unknown`, `needs_review`) y contingencia. El detalle debe mostrar la línea de tiempo del envío: creación, entrada a cola, intentos, `TrackId`, consultas realizadas y respuesta final de la DGII.

El backend debe exponer acciones protegidas para:

- reintentar una factura individual en `queued`, `unknown`, `needs_review` o contingencia, después de comprobar que no tiene un resultado final ni otro worker activo;
- reintentar todos los registros elegibles de una búsqueda, creando trabajos idempotentes y sin duplicar los que ya estén `sending` o `sent_pending_validation`;
- consultar nuevamente el estado de un `TrackId` sin reenviar el XML;
- generar la representación normal únicamente cuando el estado lo autorice;
- generar la representación de contingencia solo cuando la política de contingencia esté activa.

El botón de reintento individual debe indicar el motivo y el próximo paso. El botón de reintentar todo debe mostrar cuántas facturas elegibles encontró, pedir confirmación y devolver un resumen de encoladas, omitidas y rechazadas. Ninguna acción del frontend debe permitir reutilizar manualmente un e-NCF ni saltarse la idempotencia del backend.

En el frontend, los listados deben mostrar badges claros para `En cola`, `Enviando`, `En proceso`, `Aceptada`, `Aceptada condicional`, `Rechazada`, `Desconocida` y `Requiere revisión`. Los estados deben actualizarse por SSE/WebSocket o por polling controlado. El usuario debe poder abrir el detalle mientras la factura está pendiente, pero no verla como aceptada hasta que Ruby persista el resultado definitivo.

La impresión de contingencia seguirá la documentación de la DGII: incluirá el e-NCF y la leyenda de emisión en modalidad de contingencia, no incluirá QR de validación y quedará marcada como pendiente de regularización. Una vez aceptada por la DGII, se habilitará la representación normal con QR. El PDF normal y el PDF de contingencia deben ser plantillas y rutas diferenciadas para impedir que un QR se agregue accidentalmente a una factura aún no validada.

## Orden de implementación

1. Normalizar errores en el microservicio y Rails, eliminando `with_indifferent_access` sobre excepciones.
2. Añadir timeouts explícitos y cancelación en Axios/Faraday.
3. Implementar la barrera previa `used/available/unknown` por RNC/e-NCF.
4. Crear la cola durable, leases, reintentos y circuit breaker para la DGII.
5. Persistir inmediatamente el `trackId` recibido y confirmar esa escritura antes del sondeo.
6. Implementar el contrato `unknown`, la consulta por RNC/e-NCF y la consulta por `TrackId` antes de reenviar.
7. Añadir idempotencia y bloqueo por e-NCF.
8. Separar la respuesta rápida de creación de la preparación de la representación impresa.
9. Revisar keep-alive.
10. Añadir observabilidad segura y métricas del backlog.
11. Implementar API y UI de búsqueda, detalle, filtros y acciones de reintento.
12. Implementar las plantillas y permisos de impresión normal y de contingencia.
13. Ajustar frontend para los estados transitorio, pendiente y desconocido.

## Verificación antes de producción

- Simular timeout durante conexión, durante envío y después de transmitir el body.
- Simular `ECONNRESET`, `HPE_INVALID_CONSTANT`, DNS fallido, TLS inválido y respuestas 400/401/409/500/504.
- Confirmar que cada caso devuelve JSON válido y no genera `NoMethodError`.
- Confirmar que un timeout no duplica el e-NCF ni libera incorrectamente la secuencia.
- Confirmar que el `trackId` queda almacenado aunque el sondeo posterior termine en timeout o falle.
- Confirmar que una falla temporal de persistencia deja el intento recuperable y nunca provoca un reenvío automático.
- Confirmar que una caída de la DGII permite crear facturas locales y las deja en `queued` sin perder ni reutilizar el e-NCF.
- Confirmar que la recuperación de la DGII reanuda la cola sin duplicar envíos y que un worker interrumpido libera su lease.
- Confirmar que una factura aceptada se imprime con e-NCF y QR, y que una factura en contingencia se imprime sin QR y con la leyenda correspondiente.
- Confirmar que la creación responde después de la persistencia local sin esperar la disponibilidad de la DGII.
- Confirmar que una factura pendiente o rechazada no puede generar la representación fiscal normal aunque se invoque directamente el endpoint de PDF.
- Confirmar que el frontend deja de consultar al recibir `accepted`, `accepted_conditional` o `rejected`, y que la pérdida de SSE/WebSocket activa polling de recuperación.
- Confirmar que la búsqueda distingue estado fiscal de estado de cola y muestra `TrackId`, intentos y próximo intento.
- Confirmar que el reintento individual y masivo solo encola registros elegibles y no duplica trabajos activos.
- Confirmar que la factura en contingencia se imprime con e-NCF y leyenda, sin QR, y que tras ser aceptada se habilita la plantilla normal con QR.
- Confirmar que, después de un timeout sin `trackId`, una factura recibida por la DGII se encuentra mediante la consulta por RNC/e-NCF y no se reenvía con el mismo número.
- Confirmar que un e-NCF realmente no encontrado queda en revisión antes de permitir reutilizarlo o generar el siguiente número.
- Confirmar que un comprobante aceptado durante un timeout se reconcilia sin reenviarse.
- Validar que ningún token, certificado, contraseña o XML completo aparece en logs.
- Probar la recuperación de estados `unknown` después de reiniciar cualquiera de los contenedores.

## Criterios de aceptación

- Ninguna solicitud queda esperando indefinidamente.
- Todo error tiene código interno, `request_id` y estado de reintento definido.
- El API nunca transforma una excepción en un segundo `NoMethodError`.
- Un POST ambiguo nunca se reintenta ciegamente.
- La secuencia y el estado fiscal quedan pendientes de verificación cuando corresponde.
- Se puede diagnosticar la solicitud con logs y hash del XML sin exponer información sensible.
