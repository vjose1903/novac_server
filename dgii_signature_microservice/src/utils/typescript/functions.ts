import * as fs from 'fs';
import * as path from 'path';

/**
 * Nombre: guardarArchivoXML
 * Descripción: Esta función guarda un archivo XML con el contenido proporcionado.
 * @param content El contenido a escribir en el archivo.
 * @param filePath La ruta del archivo a crear.
 * @example guardarArchivoXML('<xml>contenido</xml>', 'ruta/al/archivo.xml')
 */
export function guardarArchivoXML(content: string, filePath: string, folder?: string): Promise<void> {
  return new Promise<void>((resolve, reject) => {
    const dirPath = path.dirname(filePath);

    // Crear el directorio si no existe
    fs.mkdir(dirPath, { recursive: true }, err => {
      if (err) {
        console.error('Error al crear el directorio:', err);
        reject(err);
        return;
      }

      // Una vez creado el directorio, escribir el archivo
      fs.writeFile(filePath, content, err => {
        if (err) {
          console.error('Error al escribir el archivo:', err);
          reject(err);
        } else {
          console.log(`El archivo ${filePath} ha sido creado exitosamente.`);
          resolve();
        }
      });
    });
  });
}

/**
 * Nombre: eliminarArchivo
 * Descripción: Esta función elimina un archivo de la ruta especificada.
 * @param filePath La ruta del archivo a eliminar.
 * @example eliminarArchivo('ruta/al/archivo.xml')
 */
export function eliminarArchivo(filePath: string): Promise<void> {
  return new Promise<void>((resolve, reject) => {
    fs.unlink(filePath, err => {
      if (err) {
        console.error('Error al eliminar el archivo:', err);
        reject(err);
      } else {
        console.log(`El archivo ${filePath} ha sido eliminado exitosamente.`);
        resolve();
      }
    });
  });
}

// __________________________________________________________________________________________________
/**
 * Nombre: leerArchivo
 * Descripción: Esta función lee el contenido de un archivo.
 * @param ruta La ruta del archivo a leer.
 * @returns El contenido del archivo como una cadena de texto.
 * @example leerArchivo('ruta/al/archivo.txt')
 */
export function leerArchivo(ruta: string): string {
  return fs.readFileSync(ruta, 'utf-8');
}

/**
 * Nombre: sleep
 * Descripción: Esta función pausa la ejecución durante un tiempo especificado.
 * @param time El tiempo en milisegundos para pausar la ejecución.
 * @returns Una promesa que se resuelve después del tiempo especificado.
 * @example sleep(1000)
 */
export function sleep(time: number) {
  return new Promise<void>((resolve, reject) => {
    setTimeout(() => resolve(), time);
  });
}

/**
 * Nombre: normalizarTexto
 * Descripción: Esta función convierte un texto a minúsculas y elimina acentos.
 * @param texto El texto a normalizar.
 * @returns El texto normalizado sin acentos y en minúsculas.
 * @example normalizarTexto('Texto Con Acentos')
 */
export function normalizarTexto(texto: string): string {
  const textoMinusculas = texto.toLowerCase();

  const textoSinAcentos = textoMinusculas.normalize('NFD').replace(/[\u0300-\u036f]/g, '');

  return textoSinAcentos;
}

/**
 * Nombre: redondearNum
 * Descripción: Esta función redondea un número a un número específico de decimales.
 * @param numero El número a redondear.
 * @param decimales El número de decimales al que redondear (por defecto es 2).
 * @returns El número redondeado como una cadena de texto.
 * @example redondearNum(3.14159, 2)
 */
export function redondearNum(numero: number, decimales: number = 2): string {
  const factor = Math.pow(10, decimales);
  const numberRounded = Math.round((numero + Number.EPSILON) * factor) / factor;
  return numberRounded.toFixed(decimales);
}

// __________________________________________________________________________________________________
/**
 * Nombre: isEmpty
 * Descripción: Esta función valida si una variable está vacía.
 * @param value La variable a evaluar.
 * @returns true si la variable está vacía, false en caso contrario.
 * @example isEmpty(variable)
 */

export function isEmpty(value: any): boolean {
  if (value == null) return true;

  if (typeof value === 'string') return value.trim().length === 0;

  if (Array.isArray(value)) return value.length === 0;

  if (value instanceof Date) return isNaN(value.getTime());

  if (typeof value === 'object') return Object.keys(value).length === 0;

  return false;
}

// __________________________________________________________________________________________________
/**
 * Nombre: hasValue
 * Descripción: Esta función valida si una variable tiene un valor.
 * @param value La variable a evaluar.
 * @returns true si la variable tiene un valor, false en caso contrario.
 * @example hasValue(variable)
 */

export function hasValue(value: any): boolean {
  return !isEmpty(value);
}

/**
 * Nombre: getProperty
 * Descripción: Esta función obtiene el valor de una propiedad anidada de un objeto dado.
 * @param obj El objeto del cual se desea obtener la propiedad.
 * @param prop La cadena que representa la propiedad anidada, separada por puntos.
 * @returns El valor de la propiedad especificada o undefined si no existe.
 * @example getProperty({ a: { b: 2 } }, 'a.b') // Retorna 2
 */
export function getProperty(obj: any, prop: string) {
  if (isEmpty(obj)) return null;

  const value = prop.split('.').reduce((objeto, property) => objeto?.[property], obj);
  return value ?? null;
}

/**
 * Nombre: retryUntil
 * Descripción: Esta función reintenta una tarea hasta que se cumpla una condición o se alcance un número máximo de intentos.
 * @param task La función asíncrona que ejecuta la tarea.
 * @param retryWhen Función que determina si se debe reintentar (retorna true para reintentar).
 * @param actionAfterRetry Función a ejecutar cuando la tarea es exitosa.
 * @param actionIfNoSuccess Función a ejecutar si se alcanza el número máximo de intentos sin éxito.
 * @param delayBetweenRetries Tiempo de espera entre reintentos en milisegundos (por defecto 500).
 * @param retryMax Número máximo de reintentos (por defecto 20).
 * @param retryCount Contador actual de reintentos (por defecto 0).
 * @param logError Indica si se deben registrar errores en consola (por defecto false).
 * @example retryUntil(fetchData, res => !res.data, data => processData(data), () => handleError(), 1000, 5)
 */
export function retryUntil(task: any, retryWhen: any, actionAfterRetry: any, actionIfNoSuccess: any, delayBetweenRetries = 500, retryMax = 20, retryCount = 0, logError = false) {
  task().then((response: any) => {
    const hasRetries = retryCount < retryMax;

    if (hasRetries && retryWhen(response)) {
      setTimeout(() => {
        retryUntil(task, retryWhen, actionAfterRetry, actionIfNoSuccess, delayBetweenRetries, retryMax, ++retryCount, logError);
      }, delayBetweenRetries);
    } else if (!hasRetries) {
      if (logError) console.error('Max numbers of retries -');
      actionIfNoSuccess();
    } else {
      actionAfterRetry(response);
    }
  });
}
