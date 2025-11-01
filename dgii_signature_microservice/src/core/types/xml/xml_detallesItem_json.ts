export interface ItemI {
  NumeroLinea: string;
  TablaCodigosItem?: TablaCodigosItem;
  IndicadorFacturacion: string;
  Retencion?: Retencion;
  NombreItem: string;
  IndicadorBienoServicio: string;
  DescripcionItem?: string;
  CantidadItem: string;
  UnidadMedida?: string;
  CantidadReferencia?: string;
  UnidadReferencia?: string;
  TablaSubcantidad?: TablaSubcantidad;
  GradosAlcohol?: string;
  PrecioUnitarioReferencia?: string;
  FechaElaboracion?: string;
  FechaVencimientoItem?: string;
  PrecioUnitarioItem: string;
  DescuentoMonto?: string;
  TablaSubDescuento?: TablaSubDescuento;
  RecargoMonto?: string;
  TablaSubRecargo?: TablaSubRecargo;
  TablaImpuestoAdicional?: TablaImpuestoAdicional;
  OtraMonedaDetalle?: OtraMonedaDetalle;
  MontoItem: string;
}

export interface OtraMonedaDetalle {
  PrecioOtraMoneda: string;
  MontoItemOtraMoneda: string;
}

export interface Retencion {
  IndicadorAgenteRetencionoPercepcion: string;
  MontoITBISRetenido?: string;
  MontoISRRetenido?: string;
}

export interface TablaCodigosItem {
  CodigosItem: CodigosItem[];
}

export interface CodigosItem {
  TipoCodigo: string;
  CodigoItem: string;
}

export interface TablaImpuestoAdicional {
  ImpuestoAdicional: ImpuestoAdicional[];
}

export interface ImpuestoAdicional {
  TipoImpuesto: string;
}

export interface TablaSubDescuento {
  SubDescuento: SubDescuento[];
}

export interface SubDescuento {
  TipoSubDescuento: string;
  SubDescuentoPorcentaje?: string;
  MontoSubDescuento?: string;
}

export interface TablaSubRecargo {
  SubRecargo: SubRecargo[];
}

export interface SubRecargo {
  TipoSubRecargo: string;
  SubRecargoPorcentaje?: string;
  MontoSubRecargo?: string;
}

export interface TablaSubcantidad {
  SubcantidadItem: SubcantidadItem[];
}

export interface SubcantidadItem {
  Subcantidad: string;
  CodigoSubcantidad: string;
}
