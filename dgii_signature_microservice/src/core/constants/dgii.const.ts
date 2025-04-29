import { ENVIRONMENT } from "dgii-ecf";

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
