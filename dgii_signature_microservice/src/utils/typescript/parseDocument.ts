import { FacturaI } from '../../core/types/factura.types';
import { Clean } from './clean';
import { normalizarTexto } from './functions';
import { condicionE, forma_pago_codeE, tipo_pago_codeE } from '../../core/constants/factura.utils';
import { FormaDePagoE } from '../../core/types/xml_json';

export class ParseDocument {
  private version: string;
  private rnc_emisor: string;
  private cleaner: Clean;

  constructor() {
    this.version = process.env.XML_VERSION || '1.0';
    this.rnc_emisor = process.env.RNC_EMISOR || '';
    this.cleaner = new Clean();
  }

  parse(document: FacturaI) {
    const document_parsed = {
      ECF: {
        Encabezado: {
          Version: this.version,
          IdDoc: {
            TipoeCF: document.FACTURA_DE,
            // agregar en el backend la secuencia a utilizar
            eNCF: document.eNCF,
            FechaVencimientoSecuencia: null,
            // a) Valor 0 si fecha de emisión del e-CF afectado es ≤ 30 días calendario.             b) Valor 1 si fecha de emisión del e-CF afectado es > 30 días calendario.
            IndicadorNotaCredito: null,
            IndicadorEnvioDiferido: null,
            // a) Valor 0 si no tienen itbis.             b) Valor 1 si tienen itbis.
            IndicadorMontoGravado: null,
            // 01: Ingresos por operaciones (No financieros).    02: Ingresos Financieros     03: Ingresos Extraordinarios     04: Ingresos por Arrendamientos     05: Ingresos por Venta de Activo Depreciable     06: Otros Ingresos
            TipoIngresos: '01',
            // Las facturas por entrega gratuita (código 3), no son válidas para crédito fiscal.
            TipoPago: null,
            // agregar en el backend la fecha limite de pago
            FechaLimitePago: null,
            TerminoPago: null,
            TablaFormasPago: {
              FormaDePago: [],
            },

            TipoCuentaPago: null,
            NumeroCuentaPago: null,
            BancoPago: null,
            FechaDesde: null,
            FechaHasta: null,
            TotalPaginas: null,
          },
          Emisor: {
            RNCEmisor: this.rnc_emisor,
            RazonSocialEmisor: null,
            NombreComercial: null,
            Sucursal: null,
            DireccionEmisor: null,
            Municipio: null,
            Provincia: null,

            TablaTelefonoEmisor: {
              TelefonoEmisor: [],
            },
            CorreoEmisor: null,
            WebSite: null,
            ActividadEconomica: null,
            CodigoVendedor: null,
            NumeroFacturaInterna: null,
            NumeroPedidoInterno: null,
            ZonaVenta: null,
            RutaVenta: null,
            InformacionAdicionalEmisor: null,
            FechaEmision: null,
          },
          Comprador: {
            RNCComprador: null,
            RazonSocialComprador: null,
            ContactoComprador: null,
            CorreoComprador: null,
            DireccionComprador: null,
            MunicipioComprador: null,
            ProvinciaComprador: null,
            FechaEntrega: null,
            ContactoEntrega: null,
            DireccionEntrega: null,
            TelefonoAdicional: null,
            FechaOrdenCompra: null,
            NumeroOrdenCompra: null,
            CodigoInternoComprador: null,
            ResponsablePago: null,
            InformacionAdicionalComprador: null,
            IdentificadorExtranjero: null,
          },
          InformacionesAdicionales: {
            FechaEmbarque: null,
            NumeroEmbarque: null,
            NumeroContenedor: null,
            NumeroReferencia: null,
            PesoBruto: null,
            PesoNeto: null,
            UnidadPesoBruto: null,
            UnidadPesoNeto: null,
            CantidadBulto: null,
            UnidadBulto: null,
            VolumenBulto: null,
            UnidadVolumen: null,
          },
          Transporte: {
            Conductor: null,
            DocumentoTransporte: null,
            Ficha: null,
            Placa: null,
            RutaTransporte: null,
            ZonaTransporte: null,
            NumeroAlbaran: null,
          },
          Totales: {
            MontoGravadoTotal: null,
            MontoGravadoI1: null,
            MontoGravadoI2: null,
            MontoGravadoI3: null,
            MontoExento: null,
            ITBIS1: null,
            ITBIS2: null,
            ITBIS3: null,
            TotalITBIS: null,
            TotalITBIS1: null,
            TotalITBIS2: null,
            TotalITBIS3: null,
            MontoImpuestoAdicional: null,
            ImpuestosAdicionales: {
              ImpuestoAdicional: [],
            },
            MontoTotal: null,
            MontoNoFacturable: null,
            MontoPeriodo: null,
            SaldoAnterior: null,
            MontoAvancePago: null,
            ValorPagar: null,
            TotalITBISRetenido: null,
            TotalISRRetencion: null,
            TotalITBISPercepcion: null,
            TotalISRPercepcion: null,
          },
          OtraMoneda: {
            TipoMoneda: null,
            TipoCambio: null,
            MontoGravadoTotalOtraMoneda: null,
            MontoGravado1OtraMoneda: null,
            MontoGravado2OtraMoneda: null,
            MontoGravado3OtraMoneda: null,
            MontoExentoOtraMoneda: null,
            TotalITBISOtraMoneda: null,
            TotalITBIS1OtraMoneda: null,
            TotalITBIS2OtraMoneda: null,
            TotalITBIS3OtraMoneda: null,
            MontoImpuestoAdicionalOtraMoneda: null,
            ImpuestosAdicionalesOtraMoneda: {
              ImpuestoAdicionalOtraMoneda: [],
            },
            MontoTotalOtraMoneda: null,
          },
        },
        DetallesItems: {
          Item: [],
        },
        Subtotales: {
          Subtotal: [],
        },
        DescuentosORecargos: {
          DescuentoORecargo: [],
        },
        Paginacion: {
          Pagina: [],
        },
        InformacionReferencia: {
          NCFModificado: null,
          RNCOtroContribuyente: null,
          FechaNCFModificado: null,
          CodigoModificacion: null,
        },
        FechaHoraFirma: null,
      },
    };

    document_parsed.ECF.Encabezado.IdDoc.IndicadorMontoGravado = document.itbis > 0 ? 1 : 0;
    document_parsed.ECF.Encabezado.IdDoc.TipoPago = document.condicion === condicionE.contado ? tipo_pago_codeE.contado : document.condicion === condicionE.credito ? tipo_pago_codeE.credito : tipo_pago_codeE.gratuito;

    if (document.condicion == condicionE.credito) {
      document_parsed.ECF.Encabezado.IdDoc.FechaLimitePago = document.fecha_limite_pago;
      document_parsed.ECF.Encabezado.IdDoc.TerminoPago = `${document.cliente?.limite_credito} días`;
    }

    document_parsed.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago = [];

    const forma_pago: FormaDePagoE = { FormaPago: forma_pago_codeE[normalizarTexto(document.forma_pago)] };
    if (document.condicion != condicionE.credito) forma_pago.MontoPago = document.total_factura;

    document_parsed.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago.push(forma_pago);

    this.cleaner.clean(document_parsed);

    return document_parsed;
  }
}
