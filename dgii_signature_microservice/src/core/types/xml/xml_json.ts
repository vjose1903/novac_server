import { forma_pago_codeE } from "../../constants/factura.utils";
import { ItemI } from "./xml_detallesItem_json";

export interface EcfXmlJson {
  ECF: Ecf;
}

export interface Ecf {
  Encabezado:            Encabezado;
  DetallesItems:         DetallesItems;
  Subtotales:            Subtotales;
  DescuentosORecargos:   DescuentosORecargos;
  Paginacion:            Paginacion;
  InformacionReferencia: InformacionReferencia;
  FechaHoraFirma:        any;
}

export interface DescuentosORecargos {
  DescuentoORecargo: DescuentoORecargoI[];
}

export interface DescuentoORecargoI {
  NumeroLinea: string;
  TipoAjuste: string;
  DescripcionDescuentooRecargo: string;
  TipoValor: string;
  ValorDescuentooRecargo: string;
  MontoDescuentooRecargo: string;
  IndicadorFacturacionDescuentooRecargo: string;
}

export interface DetallesItems {
  Item: ItemI[];
}

export interface Encabezado {
  Version:                  any;
  IdDoc:                    { [key: string]: IDDoc | any };
  Emisor:                   { [key: string]: Emisor | any };
  Comprador:                Comprador;
  InformacionesAdicionales: InformacionesAdicionales;
  Transporte:               Transporte;
  Totales:                  { [key: string]: Totale | any };
  OtraMoneda:               { [key: string]: OtraMoneda | any };
}

export interface Comprador {
  RNCComprador:                  any;
  RazonSocialComprador:          any;
  ContactoComprador:             any;
  CorreoComprador:               any;
  DireccionComprador:            any;
  MunicipioComprador:            any;
  ProvinciaComprador:            any;
  FechaEntrega:                  any;
  ContactoEntrega:               any;
  DireccionEntrega:              any;
  TelefonoAdicional:             any;
  FechaOrdenCompra:              any;
  NumeroOrdenCompra:             any;
  CodigoInternoComprador:        any;
  ResponsablePago:               any;
  InformacionAdicionalComprador: any;
  IdentificadorExtranjero:       any;
}

export interface Emisor {
  TelefonoEmisor: any[];
}

export interface IDDoc {
  FormaDePago: any[];
}

export interface FormaDePagoE {
  FormaPago: forma_pago_codeE;
  MontoPago?: any;
}

export interface InformacionesAdicionales {
  FechaEmbarque:    any;
  NumeroEmbarque:   any;
  NumeroContenedor: any;
  NumeroReferencia: any;
  PesoBruto:        any;
  PesoNeto:         any;
  UnidadPesoBruto:  any;
  UnidadPesoNeto:   any;
  CantidadBulto:    any;
  UnidadBulto:      any;
  VolumenBulto:     any;
  UnidadVolumen:    any;
}

export interface OtraMoneda {
  ImpuestoAdicionalOtraMoneda: any[];
}

export interface Totale {
  ImpuestoAdicional: any[];
}

export interface Transporte {
  Conductor:           any;
  DocumentoTransporte: any;
  Ficha:               any;
  Placa:               any;
  RutaTransporte:      any;
  ZonaTransporte:      any;
  NumeroAlbaran:       any;
}

export interface InformacionReferencia {
  NCFModificado:        any;
  RNCOtroContribuyente: any;
  FechaNCFModificado:   any;
  CodigoModificacion:   any;
}

export interface Paginacion {
  Pagina: any[];
}

export interface Subtotales {
  Subtotal: any[];
}
