import { condicionT, forma_pagoT } from '../constants/factura.utils';

export interface FacturaI {
  id_documento: string;
  condicion: condicionT;
  forma_pago: forma_pagoT;
  fecha_viaje: any;
  fecha_equivalente: any;
  fecha_limite_pago?: string;
  pagada: boolean;
  balance: number;
  devuelta: number;
  fecha_valida: any;
  tipo_factura_id: number;
  numero_comprobante: any;
  costoYgasto: any;
  numero_factura: any;
  total_factura: number;
  Bruto: number;
  itbis: number;
  descuento: number;
  estado: boolean;
  is_adelantada: boolean;
  is_viaje: boolean;
  is_nota: boolean;
  movimientos_viaje: any[];
  serie: string;
  pre_factura: any;
  cotizacion: any;
  cliente_id: any;
  NoCliente_nombre: string;
  NoCliente_direccion: string;
  detalle_facturas: DetalleFactura[];
  FACTURA_DE: number;
  tipo: string;
  tiene_nota: boolean;
  eNCF: string;
  cliente?: ClienteI;
  [key: string]: any;
}

export interface DetalleFactura {
  key: string;
  articulo: Articulo;
  unidades: UnidadesI[];
  detalle_id: any;
  codigo: string;
  cantidad: number;
  cantidad_initial: number;
  cantidad_ant: number;
  descripcion: string;
  unidad: string;
  precio: number;
  costo: number;
  descuento_valor: number;
  total: number;
  itbis: number;
  cantidad_en_unidades: number;
  cantidad_en_unidades_initial: number;
  calcular_saco: boolean;
  is_defectuoso: boolean;
  is_devuelto: boolean;
  from_pre_factura: boolean;
  vende_sin_inventario: boolean;
  is_bad_price: boolean;
  actual_price: any;
  actual_price_value: any;
  key_initial: any;
  producto_initial: any;
  articulo_id: number;
  retirado: number;
  retirado_en_venta: number;
  [key: string]: any;
}

export interface ClienteI {
  id: number;
  nombre: string;
  apellido: string;
  telefono: string;
  direccion: string;
  limite_credito: number;
  [key: string]: any;
}

export interface Articulo {
  id: number;
  imagen_id: any;
  tipo_articulo_id: number;
  nombre: string;
  costo_principal: number;
  precio_principal: number;
  existencia: number;
  aviso_existencia: number;
  codigo: string;
  fecha_ingreso: Date;
  medida: string;
  is_detallable: boolean;
  medida_alerta: string;
  calcular_itbis: boolean;
  estado: boolean;
  is_combo: boolean;
  otros_costos: number;
  vendido_en: string;
  is_materia_prima: boolean;
  contenido_articulos: ContenidoArticuloI[];
  descripcion: string;
  contenido: ContenidoI;
  cantidades: CantidadesI;
  calcular_saco: boolean;
  costos: CostosI;
  tipo_articulo: TipoArticuloI;
  [key: string]: any;
}

export interface CantidadesI {
  Saco?: number;
  Libra: number;
  Quintal?: number;
}

export interface ContenidoI {
  Saco?: number;
  Libra: number;
  Saco_100?: number;
  Saco_50?: number;
  Saco_25?: number;
  Quintal?: number;
}

export interface ContenidoArticuloI {
  id: number;
  articulo_id: number;
  referencia: any;
  costo: number;
  precio: number;
  cantidad: number;
  medida: string;
  condicion: string;
  calcular_itbis: boolean;
  [key: string]: any;
}

export interface CostosI {
  Saco?: LibraI;
  Libra: LibraI;
  Quintal?: LibraI;
  Saco_100?: LibraI;
  Saco_50?: LibraI;
  Saco_25?: LibraI;
}

export interface LibraI {
  costo: number;
  precio: number;
}

export interface TipoArticuloI {
  id: number;
  descripcion: string;
  tipo: string;
  codigo: string;
  [key: string]: any;
}

export interface UnidadesI {
  value: string;
  precio: number | string;
  costo: number | string;
  cantidad: number;
}
