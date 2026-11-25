# Instrucciones para agentes: configuración Firebase

Leer antes de agregar, modificar o eliminar parámetros de empresa/equipo o cambiar su persistencia. Esta guía corresponde al código del repositorio; no demuestra que esos cambios estén desplegados o probados.

## Fuente de verdad y archivos

| Archivo | Responsabilidad |
| --- | --- |
| `config/configuration_schema.json` | Contrato canónico: versión, campos, ámbitos y tipos. |
| `app/services/configuration_contract.rb` | Validación y selección de valores según el contrato. |
| `app/services/firebase_configuration_service.rb` | Autorización por contraseña, lectura, revisiones y commit atómico. |
| `app/controllers/firebase_configuration_controller.rb` | Endpoints, autenticación de sesión, parámetros y respuestas HTTP. |
| `app/controllers/firebase_logos_controller.rb` | Autorización y carga de logos, separada de la transacción de configuración. |

En novac-system, consultar `docs/ai/12-configuration-contract.md`. Su copia distribuida del contrato está en `src/app/core/config/configuration-schema.json`.

## Agregar un parámetro

1. Revisar `git status --short` en ambos proyectos y conservar cambios ajenos.
2. Agregar el campo a `fields` en `config/configuration_schema.json`. Usar nombres estables en snake_case para opciones nuevas. Elegir `scope: "general"` o `scope: "machine"`; no duplicar la misma opción en ambos documentos.
3. Declarar un tipo soportado y sus restricciones. Incrementar el entero `version` al cambiar el contrato. Un cambio de valor de una opción existente no cambia la versión.
4. No modificar listas de claves: `ConfigurationContract` y Electron las derivan del JSON. Para reglas de negocio adicionales, validar explícitamente en el servicio antes de escribir.
5. Desde la raíz del frontend, ejecutar:

   ```sh
   npm run config:sync -- ../novac-server/config/configuration_schema.json
   ```

   Adaptar la ruta si los repositorios no son hermanos. Versionar la copia sincronizada con los cambios de ambos repositorios. No dar por terminada una opción nueva hasta actualizar también `ConfigI`, defaults pertinentes y consumidor/UI en el frontend.
6. Explicar la compatibilidad requerida al entregar. Rails carga el esquema en una constante: un cambio requiere reiniciar/actualizar sus procesos. Angular/Electron deben distribuirse con la misma versión del contrato para guardar.

Ejemplo ilustrativo de campo en `fields`:

```json
"mostrar_referencia_cliente": {
  "scope": "general",
  "type": "boolean"
}
```

No agregar el ejemplo por defecto: usar el parámetro solicitado y definir cómo se comporta la app mientras no exista en documentos antiguos.

## Tipos y seguridad de los datos

- `boolean`: acepta `true` y `false`, no sus equivalentes de texto o números.
- `string`: requiere `maxLength`; puede declarar `enum` y `format: "httpUrl"`.
- `stringMap`: hasta 100 entradas de cadenas, valores de hasta 4096 caracteres y claves alfanuméricas/underscore. Se rechazan claves peligrosas como `__proto__`, `prototype` y `constructor`.
- `httpUrl`: permite HTTP/HTTPS con host y sin credenciales embebidas. Admite cadena vacía; no equivale a validar obligatoriedad.
- No se admite `null`, arrays, números ni objetos arbitrarios como nuevos tipos sin ampliar los validadores Ruby y TypeScript coordinadamente.
- No añadir nuevos parámetros a `LEGACY_METADATA`: es una excepción de compatibilidad para metadatos, no una vía alternativa para opciones persistidas.
- Las claves desconocidas se rechazan en solicitudes de escritura. Las claves remotas no declaradas se excluyen de la configuración activa; no se borran de Firebase de forma implícita.

Cambiar el tipo, retirar un campo o moverlo de empresa a equipo requiere planear la migración de valores existentes. Aumentar la versión por sí solo no transforma los documentos.

## Contrato HTTP que debe conservarse

`POST /firebase/configuration` requiere sesión válida y contraseña de configuración. `POST /firebase/configuration/prelogin` usa la contraseña sin sesión. No existe bypass de contraseña en development.

El cuerpo debe contener:

| Campo | Origen/uso |
| --- | --- |
| `empresa_id`, `machine_id` | Identificadores del contexto; se validan antes de formar rutas. |
| `config_password` | Contraseña actual para autorizar. Si se cambia la contraseña, el nuevo valor va en `config.config_password`. |
| `config` | Opciones declaradas y ya normalizadas, validadas otra vez por Rails. |
| `schema_version` | Entero igual a `ConfigurationContract::VERSION`. |
| `expected_general_revision` | Última revisión general leída; `''` solo si no existe revisión. |
| `expected_machine_revision` | Última revisión del equipo leída; misma regla. |
| `only_missing` | En el endpoint autenticado, sincroniza claves ausentes sin reemplazar las existentes, salvo normalización de la serie. |

La respuesta mantiene `{ data: ... }` con los valores confirmados, `firebase_empresa_id`, `machineId`, `firebase_general_revision`, `firebase_machine_revision` y `firebase_config_schema_version`. No sustituirla por un eco del cuerpo recibido ni por confirmaciones especiales de un único campo.

Errores actuales: 401 si falta sesión en el endpoint autenticado; 422 por parámetros, contraseña o versión inválidos; 409 por revisión obsoleta/concurrencia; 502 por fallo del servicio remoto. No convertir un fallo en respuesta exitosa ni sobrescribir a ciegas tras un 409.

## Persistencia, concurrencia y caché

- Empresa: `Empresas/{empresa_id}/general_configuration/app`.
- Equipo: `Empresas/{empresa_id}/configuration/{machine_id}`.
- El servicio lee ambos documentos, compara revisiones, combina opciones y aplica la regla de serie. Escribe ambos con un único commit de Firestore y precondiciones `updateTime`/`exists`.
- `_config_schema_version` identifica el contrato. `_config_revision` se genera en el servidor en cada commit. No aceptar revisiones generadas por el formulario como nuevas revisiones del documento.
- Documentos antiguos sin versión/revisión son compatibles. No bajar versiones remotas ni eliminar revisiones para eludir una incompatibilidad.
- El caché local se actualiza en Electron después de una lectura válida o guardado confirmado. Firebase sigue siendo la fuente remota; no resolver inconsistencias guardando defaults sobre datos remotos existentes.

## Alta inicial y límites

Para una empresa sin documento general, el bootstrap requiere configurar explícitamente `FIREBASE_BOOTSTRAP_EMPRESA_ID` y `FIREBASE_BOOTSTRAP_CONFIG_PASSWORD` en el servidor. La autorización verifica la empresa indicada y esa contraseña. Retirar ambas variables después de aprovisionar. No obtener autorización de la contraseña nueva incluida dentro de `config` ni agregar credenciales reales a archivos versionados.

Los logos requieren la misma autorización. Su carga en Storage precede al commit de configuración y no forma parte de esa transacción. No afirmar atomicidad entre Storage y Firestore.

Las credenciales de servicio y reglas de Firestore/Storage desplegadas deben restringir accesos por empresa y escrituras al servidor. Este contrato valida datos; no sustituye esas reglas. El caché del frontend usa Base64, no cifrado: no incorporar secretos nuevos a la configuración distribuida.

## Antes de entregar

Revisar el diff, sincronización del esquema, tipo del campo en ambos lenguajes, compatibilidad de clientes antiguos y mantenimiento de autorización/precondiciones. No ejecutar validaciones automáticas sin autorización aplicable. Si se autorizan pruebas, cubrir tipos inválidos, campo desconocido, credenciales incorrectas, versión incompatible, revisiones obsoletas, commit fallido sin actualización parcial, y lectura después de guardar.

Informar archivos cambiados, necesidad de actualización coordinada y qué validaciones no se ejecutaron. No declarar probado o desplegado un flujo que solo se modificó en código.
