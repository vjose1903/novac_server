import { forma_pago_codeE } from "../../constants/factura.utils";
import { ItemI } from "./xml_detallesItem_json";
import { PaginacionI } from "./xml_paginacion_json";

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
  Totales:                  TotalI;
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
  PaisComprador:                 any;
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
  FechaEmbarque:           any;
  NumeroEmbarque:          any;
  NumeroContenedor:        any;
  NumeroReferencia:        any;
  NombrePuertoEmbarque:    any;
  CondicionesEntrega:      any;
  TotalFob:                any;
  Seguro:                  any;
  Flete:                   any;
  OtrosGastos:             any;
  TotalCif:                any;
  RegimenAduanero:         any;
  NombrePuertoSalida:      any;
  NombrePuertoDesembarque: any;
  PesoBruto:            any;
  PesoNeto:             any;
  UnidadPesoBruto:      any;
  UnidadPesoNeto:       any;
  CantidadBulto:        any;
  UnidadBulto:          any;
  VolumenBulto:         any;
  UnidadVolumen:        any;
}

export interface OtraMoneda {
  ImpuestoAdicionalOtraMoneda: any[];
}

export interface TotalI {
  MontoGravadoTotal?:      number,
  MontoGravadoI1?:         number,
  MontoGravadoI2?:         number,
  MontoGravadoI3?:         number,
  MontoExento?:            number,
  ITBIS1?:                 number,
  ITBIS2?:                 number,
  ITBIS3?:                 number,
  TotalITBIS?:             number,
  TotalITBIS1?:            number,
  TotalITBIS2?:            number,
  TotalITBIS3?:            number,
  MontoTotal?:             number,
  MontoImpuestoAdicional?: number,
  ImpuestosAdicionales:    any,
  MontoNoFacturable?:      number,
  MontoPeriodo?:           number,
  SaldoAnterior?:          number,
  MontoAvancePago?:        number,
  ValorPagar?:             number,
  TotalITBISRetenido?:     number,
  TotalISRRetencion?:      number,
  TotalITBISPercepcion?:   number,
  TotalISRPercepcion?:     number,
}

export interface Transporte {
  ViaTransporte:       any;
  PaisOrigen:          any;
  DireccionDestino:    any;
  PaisDestino:         any;
  RNCIdentificacionCompaniaTransportista: any;
  NombreCompaniaTransportista: any;
  NumeroViaje:         any;
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
  Pagina: PaginacionI[];
}

export interface Subtotales {
  Subtotal: any[];
}
