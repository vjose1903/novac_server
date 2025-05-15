import { DetalleFacturaI, FacturaI } from '@core/types/factura.types';
import { Clean } from './clean';
import { getProperty, hasValue, isEmpty, normalizarTexto, redondearNum } from './functions';
import { codigo_modificacionE, condicionE, forma_pago_codeE, indicadorBienoServicioE, indicadorFacturacionE, sheet_typeE, tipo_ingreso_E, tipo_pago_codeE, tipoComprobanteE, unidad_codeE } from '@core/constants/factura.const';
import { EcfXmlJson, FormaDePagoE } from '@core/types/xml/xml_json';
import { CodigosItem, ItemI } from '@core/types/xml/xml_detallesItem_json';
import { Totalizacion } from './totalizacion';
import { agruparArticulosPorPagina } from './paginacion';
import { PaginacionI } from '@core/types/xml/xml_paginacion_json';
import { DetallesFacturasNota, FacturasAplicada, NotaI } from '@core/types/notas.types';
import { documentTypeE } from '@core/types/document.types';
import { DateUtils } from '@vjose1903/dateutils';
import { Detalles } from './detalles';
import Big from 'big.js';
import { getCurrentFormattedDateTime } from 'dgii-ecf';

export class ParseDocument {
  private version: string;
  private rnc_emisor: string;
  private environment: any;
  private sheet_type: sheet_typeE;
  private items_per_page: number;
  private items_per_page_credit: number;
  private items_per_page_nota: number;

  private cleanerClass: Clean;
  private totalizacionClass: Totalizacion;
  private detallesClass: Detalles;

  private document: FacturaI | NotaI;

  constructor(document: FacturaI | NotaI) {
    this.document = document;
    this.environment = process.env;
    this.version = this.environment.XML_VERSION || '1.0';
    this.rnc_emisor = this.environment.RNC_EMISOR || '';
    this.sheet_type = sheet_typeE[this.environment.SHEET_TYPE] || sheet_typeE.paper;
    this.items_per_page = this.environment.ITEMS_PER_PAGE || 5;
    this.items_per_page_credit = this.environment.ITEMS_PER_PAGE_CREDIT || 14;
    this.items_per_page_nota = this.environment.ITEMS_PER_PAGE_NOTA || 5;

    this.cleanerClass = new Clean();
    this.totalizacionClass = new Totalizacion();
    this.detallesClass = new Detalles();
  }

  get isFactura() {
    return this.document.document_type == documentTypeE.factura;
  }

  get isNota() {
    return this.document.document_type == documentTypeE.nota;
  }

  get factura_aplicada(): FacturasAplicada | undefined {
    return hasValue(this.document?.facturas_aplicadas) ? this.document.facturas_aplicadas[0] : undefined;
  }

  get factura(): FacturaI {
    return this.isFactura ? (this.document as FacturaI) : (getProperty(this.factura_aplicada, 'factura') as FacturaI);
  }

  get detalles(): DetalleFacturaI[] | DetallesFacturasNota[] {
    return this.isFactura ? getProperty(this.document, 'detalle_facturas') : getProperty(this.document, 'facturas_aplicadas')[0].detalles_facturas_notas;
  }

  get daysFromNow(): number {
    return this.isNota ? DateUtils.diffDays(this.factura.fecha_equivalente, new Date()) : 0;
  }

  get rnc_comprador() {
    const documento_identidad = this.document.cliente?.documentos_de_identidad?.find(documento => documento.principal);
    return documento_identidad ? documento_identidad.documento.replace(/-/g, '') : null;
  }

  get eNCF() {
    return this.document.numero_comprobante;
  }

  get fecha_emision() {
    if (!hasValue(this.document.fecha_equivalente)) return DateUtils.format({ dateFormat: 'DD-MM-YYYY' });

    const fechaComparacion = DateUtils.format({ date: this.document.fecha_equivalente, dateFormat: 'YYYY-MM-DD' });
    const fechaActual = DateUtils.format({ dateFormat: 'YYYY-MM-DD' });

    const esFechaValida = DateUtils.compareDates(fechaActual, fechaComparacion) >= 0;

    return esFechaValida ? DateUtils.format({ date: this.document.fecha_equivalente, dateFormat: 'DD-MM-YYYY' }) : DateUtils.format({ dateFormat: 'DD-MM-YYYY' });
  }

  parse() {
    console.log(' ');
    console.log(' ');
    console.log(' =========================================');
    console.log(`       ${this.isFactura ? 'FACTURA' : 'NOTA CREDITO'}`);
    console.log(' =========================================');
    console.log(' ');
    console.log(' ');

    const document_parsed: EcfXmlJson = {
      ECF: {
        Encabezado: {
          Version: this.version,
          IdDoc: {
            TipoeCF: this.document.TipoeCF,
            eNCF: this.document.numero_comprobante,
            FechaVencimientoSecuencia: null,
            IndicadorNotaCredito: null, // a) Valor 0 si fecha de emisión del e-CF afectado es ≤ 30 días calendario.             b) Valor 1 si fecha de emisión del e-CF afectado es > 30 días calendario.
            IndicadorEnvioDiferido: null,
            IndicadorMontoGravado: 0, // a) Valor 0 si los montos de los items no tienen itbis incluido.             b) Valor 1 si los montos de los items tienen itbis incluido.
            TipoIngresos: tipo_ingreso_E.por_operaciones, // 01: Ingresos por operaciones (No financieros).    02: Ingresos Financieros     03: Ingresos Extraordinarios     04: Ingresos por Arrendamientos     05: Ingresos por Venta de Activo Depreciable     06: Otros Ingresos
            TipoPago: null, // Las facturas por entrega gratuita (código 3), no son válidas para crédito fiscal.
            FechaLimitePago: null,
            TerminoPago: null,
            TablaFormasPago: {
              FormaDePago: [],
            },
            TipoCuentaPago: null, // CT: Cta. Corriente AH: Ahorro OT: Otra
            NumeroCuentaPago: null, // Número de la cuenta si la forma de pago es por cheque o transferencia bancaria.
            BancoPago: null, // Banco de la Cuenta
            FechaDesde: null, // Período de facturación para Servicios Periódicos Ej. Energía eléctrica, telefónica, otros. Fecha desde (Fecha inicial del servicio facturado).
            FechaHasta: null, // Período de facturación para Servicios Periódicos. Fecha hasta (Fecha final del servicio facturado).
            TotalPaginas: null,
          },
          Emisor: {
            RNCEmisor: this.rnc_emisor,
            RazonSocialEmisor: this.environment.RAZON_SOCIAL_EMISOR,
            NombreComercial: this.environment.NOMBRE_COMERCIAL_EMISOR,
            Sucursal: null,
            DireccionEmisor: this.environment.DIRECCION_EMISOR,
            Municipio: this.environment.MUNICIPIO_EMISOR,
            Provincia: this.environment.PROVINCIA_EMISOR,
            TablaTelefonoEmisor: {
              TelefonoEmisor: [this.environment.TELEFONO_EMISOR],
            },
            CorreoEmisor: this.environment.CORREO_EMISOR,
            WebSite: null,
            ActividadEconomica: null,
            CodigoVendedor: null,
            NumeroFacturaInterna: this.isFactura ? getProperty(this.document, 'numero_factura').toString()?.padStart(8, '0') : getProperty(this.document, 'numero_documento').toString()?.padStart(8, '0'),
            NumeroPedidoInterno: null,
            ZonaVenta: null,
            RutaVenta: null,
            InformacionAdicionalEmisor: null,
            FechaEmision: this.fecha_emision,
          },
          Comprador: {
            RNCComprador: null,
            IdentificadorExtranjero: null,
            RazonSocialComprador: this.document.cliente?.nombre || 'VENTA DE CONTADO',
            ContactoComprador: null, // TODO: agregar propiedad en la tabla cliente en el backend, nombre de la persona de contacto con la empresa
            CorreoComprador: null, // TODO: agregar propiedad en la tabla cliente en el backend, correo de la empresa
            DireccionComprador: this.document.cliente?.direccion || null,
            MunicipioComprador: this.document.cliente?.municipio?.codigo || null,
            ProvinciaComprador: this.document.cliente?.provincia?.codigo || null,
            PaisComprador: null,
            FechaEntrega: null,
            ContactoEntrega: null,
            DireccionEntrega: null,
            TelefonoAdicional: null,
            FechaOrdenCompra: null,
            NumeroOrdenCompra: null,
            CodigoInternoComprador: this.document.cliente?.id?.toString()?.padStart(5, '0') || null,
            ResponsablePago: null,
            InformacionAdicionalComprador: null,
          },
          InformacionesAdicionales: {
            FechaEmbarque: null,
            NumeroEmbarque: null,
            NumeroContenedor: null,
            NumeroReferencia: null,
            NombrePuertoEmbarque: null,
            CondicionesEntrega: null,
            TotalFob: null,
            Seguro: null,
            Flete: null,
            OtrosGastos: null,
            TotalCif: null,
            RegimenAduanero: null,
            NombrePuertoSalida: null,
            NombrePuertoDesembarque: null,
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
            ViaTransporte: null, // 01: Terrestre 02: Marítimo 03: Aérea
            PaisOrigen: null,
            DireccionDestino: null,
            PaisDestino: null,
            RNCIdentificacionCompaniaTransportista: null,
            NombreCompaniaTransportista: null,
            NumeroViaje: null,
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

    // ENCABEZADO IDDOC

    if (this.isNota && this.document.TipoeCF == tipoComprobanteE.nota_de_credito) {
      document_parsed.ECF.Encabezado.IdDoc.IndicadorNotaCredito = this.daysFromNow > 30 ? 1 : 0;
    }

    if (hasValue(this.factura.fecha_vencimiento)) {
      document_parsed.ECF.Encabezado.IdDoc.FechaLimitePago = DateUtils.format({ date: this.factura.fecha_vencimiento, dateFormat: 'DD-MM-YYYY' });

      // PARA LA CERTIFICACION -----
      // const fecha_vencimiento_certificacion = DateUtils.addDays(30);
      // document_parsed.ECF.Encabezado.IdDoc.FechaLimitePago = DateUtils.format({ date: fecha_vencimiento_certificacion, dateFormat: 'DD-MM-YYYY' });
      // ---------------------------
    }

    const no_fecha_vencimiento = [tipoComprobanteE.factura_de_consumo, tipoComprobanteE.nota_de_credito];
    if (!no_fecha_vencimiento.includes(this.document.TipoeCF)) {
      if (this.isFactura) {
        document_parsed.ECF.Encabezado.IdDoc.FechaVencimientoSecuencia = this.document.fecha_valida ? DateUtils.format({ date: this.document.fecha_valida, dateFormat: 'DD-MM-YYYY' }) : DateUtils.getLastDayOfYear({ format: 'DD-MM-YYYY' });
        document_parsed.ECF.Encabezado.IdDoc.TerminoPago = `${this.document.cliente?.limite_credito} días`;
      }

      // PARA LA CERTIFICACION -----
      // document_parsed.ECF.Encabezado.IdDoc.FechaVencimientoSecuencia = DateUtils.getLastDayOfYear({ format: 'DD-MM-YYYY' });
      // ---------------------------
    }

    document_parsed.ECF.Encabezado.IdDoc.TipoPago = this.factura.condicion === condicionE.contado ? tipo_pago_codeE.contado : this.factura.condicion === condicionE.credito ? tipo_pago_codeE.credito : tipo_pago_codeE.gratuito;

    document_parsed.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago = [];

    if (this.isFactura && this.factura.condicion != condicionE.credito) {
      const forma_pago: FormaDePagoE = { FormaPago: forma_pago_codeE[normalizarTexto(this.factura.forma_pago)] };
      forma_pago.MontoPago = this.factura.total_factura;

      document_parsed.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago.push(forma_pago);
    }

    // ENCABEZADO COMPRADOR
    if (!isEmpty(this.rnc_comprador)) document_parsed.ECF.Encabezado.Comprador.RNCComprador = this.rnc_comprador;

    // ENCABEZADO TOTALES
    const totales = this.totalizacionClass.run(this.detalles, this.isFactura);
    document_parsed.ECF.Encabezado.Totales = totales as any;

    // DETALLESITEMS
    document_parsed.ECF.DetallesItems = this.detallesClass.parse(this.detalles, this.isFactura);

    // Paginacion
    document_parsed.ECF.Paginacion = this.parsePaginacion();
    const pages_amount = document_parsed.ECF.Paginacion.Pagina.length;
    document_parsed.ECF.Encabezado.IdDoc.TotalPaginas = pages_amount > 1 ? pages_amount : null;

    if (this.isNota) {
      // codigo_modificacionE
      const diferencia = Math.abs(Big(this.factura.total_factura).minus(this.factura_aplicada.total).toNumber());

      const codigo_modificacion = diferencia <= 0.9 ? codigo_modificacionE.anulacion : codigo_modificacionE.correccion_monto;

      document_parsed.ECF.InformacionReferencia = {
        NCFModificado: this.factura.numero_comprobante,
        RNCOtroContribuyente: null,
        FechaNCFModificado: DateUtils.format({ date: this.factura.fecha_equivalente, dateFormat: 'DD-MM-YYYY' }),
        CodigoModificacion: codigo_modificacion,
      };
    }

    document_parsed.ECF.FechaHoraFirma = getCurrentFormattedDateTime();

    this.cleanerClass.clean(document_parsed);

    return document_parsed;
  }

  parsePaginacion() {
    const paginacion = { Pagina: [] };

    const items_per_page = this.isNota ? this.items_per_page_nota : getProperty(this.document, 'condicion') == condicionE.contado ? this.items_per_page : this.items_per_page_credit;

    if (this.sheet_type == sheet_typeE.paper && this.detalles.length > items_per_page) {
      const articulos_agrupados = agruparArticulosPorPagina(this.detalles, items_per_page);

      articulos_agrupados.forEach((grupo, index) => {
        const paginaParsed = {} as PaginacionI;
        paginaParsed.PaginaNo = `${index + 1}`;
        paginaParsed.NoLineaDesde = `${index * items_per_page + 1}`;
        paginaParsed.NoLineaHasta = `${(index + 1) * items_per_page}`;

        const totales = this.totalizacionClass.run(grupo, this.isFactura);
        paginaParsed.SubtotalMontoGravadoPagina = totales.MontoGravadoTotal;
        paginaParsed.SubtotalMontoGravado1Pagina = totales.MontoGravadoI1;
        paginaParsed.SubtotalExentoPagina = totales.MontoExento;
        paginaParsed.SubtotalItbisPagina = totales.TotalITBIS;
        paginaParsed.SubtotalItbis1Pagina = totales.TotalITBIS1;
        paginaParsed.MontoSubtotalPagina = totales.MontoTotal;

        paginacion.Pagina.push(paginaParsed);
      });
    }

    return paginacion;
  }
}
