export interface EcfXmlAnulacionJson {
  ANECF: ANECF;
}

export interface ANECF {
  Encabezado:       Encabezado;
  DetalleAnulacion: DetalleAnulacion;
}

export interface Encabezado {
  Version:                any;
  RncEmisor:              string;
  CantidadeNCFAnulados:   number;
  FechaHoraAnulacioneNCF: string;
}

export interface DetalleAnulacion {
  Anulacion: Anulacion[];
}

export interface Anulacion {
  NoLinea:                          number;
  TipoeCF:                          string;
  TablaRangoSecuenciasAnuladaseNCF: TablaRangoSecuenciasAnuladaseNCF;
  CantidadeNCFAnulados:             number;
}

export interface TablaRangoSecuenciasAnuladaseNCF {
  SecuenciaeNCFDesde: string;
  SecuenciaeNCFHasta: string;
}


