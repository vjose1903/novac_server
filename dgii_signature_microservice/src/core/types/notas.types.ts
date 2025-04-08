export interface NotaI {
  cliente_id:         number;
  user_id:            null;
  fecha_valida:       string;
  tipo_factura_id:    number;
  total:              number;
  facturas_aplicadas: FacturasAplicada[];
}

export interface FacturasAplicada {
  cabecera_factura_id:     number;
  total:                   number;
  detalles_facturas_notas: DetallesFacturasNota[];
}

export interface DetallesFacturasNota {
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
  detalle_factura_id:   number;
  descuento:            number;
  descuento_real:       number;
}
