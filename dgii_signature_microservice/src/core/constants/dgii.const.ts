import { ENVIRONMENT } from "dgii-ecf";

export enum codigo_rechazo_dgiiE {
  e_ncf_y_codigo_seguridad_utilizados = '75',
}

export interface QrUrlDgiiData {
  rncemisor: string;
  encf: string;
  montototal: number;
  env: ENVIRONMENT;
  codigoseguridad?: string;
  rncComprador?: string;
  fechaEmision?: string;
  fechaFirma?: string;
}
