export interface PaginacionI {
  PaginaNo: string | number;
  NoLineaDesde: string | number;
  NoLineaHasta: string | number;
  SubtotalMontoGravadoPagina?: string | number;
  SubtotalMontoGravado1Pagina?: string | number;
  SubtotalMontoGravado2Pagina?: string | number;
  SubtotalMontoGravado3Pagina?: string | number;
  SubtotalExentoPagina?: string | number;
  SubtotalItbisPagina?: string | number;
  SubtotalItbis1Pagina?: string | number;
  SubtotalItbis2Pagina?: string | number;
  SubtotalItbis3Pagina?: string | number;
  SubtotalImpuestoAdicionalPagina?: string | number;
  SubtotalImpuestoAdicional?: SubtotalImpuestoAdicionalI[];
  MontoSubtotalPagina?: string | number;
  SubtotalMontoNoFacturablePagina?: string | number;
}

export interface SubtotalImpuestoAdicionalI {
  SubtotalImpuestoSelectivoConsumoEspecificoPagina: string | number;
  SubtotalOtrosImpuesto: string | number;
}
