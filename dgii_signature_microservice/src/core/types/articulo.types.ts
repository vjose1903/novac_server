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
  fecha_ingreso: Date | string;
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
  contenido?: ContenidoI;
  cantidades?: CantidadesI;
  calcular_saco: boolean;
  costos?: CostosI;
  tipo_articulo?: TipoArticuloI;
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
