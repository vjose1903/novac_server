import { tipoComprobanteE } from "@core/constants/factura.utils";
import { Articulo } from "@core/types/articulo.types";
import { ClienteI } from "@core/types/cliente.types";
import { FacturaI } from "@core/types/factura.types";
import { documentTypeT } from "@core/types/document.types";

export interface NotaI {
  cliente_id:         number;
  user_id:            null;
  fecha_valida:       string;
  numero_comprobante: string;
  tipo_factura_id:    number;
  numero_documento?:  number; // TODO: agregar en el backend
  fecha_equivalente?: string | Date; // TODO: agregar en el backend
  total:              number;
  TipoeCF:            tipoComprobanteE;
  facturas_aplicadas: FacturasAplicada[];
  cliente?: ClienteI;
  document_type?: documentTypeT;
}

export interface FacturasAplicada {
  cabecera_factura_id:     number;
  factura?:                FacturaI;
  total:                   number;
  detalles_facturas_notas: DetallesFacturasNota[];
} 

export interface DetallesFacturasNota {
  articulo:             Articulo;
  articulo_id:          number;
  unidad:               string;
  itbis:                number;
  itbis_real:           number;
  costo:                number;
  precio:               number;
  precio_real:          number;
  total:                number;
  cantidad_en_unidades: number;
  cantidad:             number;
  cantidad_origin:      number;
  detalle_factura_id:   number;
  descuento:            number;
  descuento_real:       number;
}
