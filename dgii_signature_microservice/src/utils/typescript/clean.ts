import { FacturaI } from '../../core/types/factura.types';
import { EcfXmlJson } from '../../core/types/xml/xml_json';
import { isEmpty } from './functions';

export class Clean {
  constructor() {}

  clean(document: EcfXmlJson) {
    if (Array.isArray(document)) {
      // Si es un arreglo, recorrer cada elemento y limpiarlo
      document.forEach((item, index) => {
        this.clean(item); // Recursión para cada item
        // Si el item es un objeto vacío, eliminarlo
        if (isEmpty(item)) {
          document.splice(index, 1);
        }
      });
    } else if (typeof document === 'object' && document !== null) {
      // Si es un objeto, recorrer sus propiedades
      Object.keys(document).forEach(key => {
        this.clean(document[key]); // Recursión para cada propiedad
        // Si la propiedad está vacía, eliminarla
        if (isEmpty(document[key])) {
          delete document[key];
        }
      });
    }
  }
}
