import { DetalleFacturaI, FacturaI } from '@core/types/factura.types';
import { Clean } from './clean';
import { getProperty, hasValue, isEmpty, normalizarTexto, redondearNum } from './functions';
import { codigo_modificacionE, condicionE, forma_pago_codeE, indicadorBienoServicioE, indicadorFacturacionE, sheet_typeE, tipo_ingreso_E, tipo_pago_codeE, unidad_codeE } from '@core/constants/factura.utils';
import { FormaDePagoE } from '@core/types/xml/xml_json';
import { CodigosItem, ItemI } from '@core/types/xml/xml_detallesItem_json';
import { Totalizacion } from './totalizacion';
import { agruparArticulosPorPagina } from './paginacion';
import { PaginacionI } from '@core/types/xml/xml_paginacion_json';
import { DetallesFacturasNota, FacturasAplicada, NotaI } from '@core/types/notas.types';
import { documentTypeE } from '@core/types/document.types';
import { DateUtils } from '@vjose1903/dateutils';
import { Detalles } from './detalles';

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

  constructor() {
    this.environment = process.env;
    this.version = this.environment.XML_VERSION || '1.0';
    this.rnc_emisor = this.environment.RNC_EMISOR || '';
    this.sheet_type = sheet_typeE[this.environment.SHEET_TYPE] || sheet_typeE.paper;
    this.items_per_page = this.environment.ITEMS_PER_PAGE || 9;
    this.items_per_page_credit = this.environment.ITEMS_PER_PAGE_CREDIT || 18;
    this.items_per_page_nota = this.environment.ITEMS_PER_PAGE_NOTA || 9;

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
    return this.isFactura ? this.document as FacturaI : (getProperty(this.factura_aplicada, 'factura') as FacturaI);
  }

  get detalles(): DetalleFacturaI[] | DetallesFacturasNota[] {
    return this.isFactura ? getProperty(this.document, 'detalle_facturas') : getProperty(this.document, 'facturas_aplicadas')[0].detalles_facturas_notas;
  }

  parse(document: FacturaI | NotaI) {
    this.document = document;
    console.log(" ");
    console.log(" ");
    console.log(" =========================================");
    console.log(`       ${this.isFactura ? 'FACTURA' : 'NOTA CREDITO'}`);
    console.log(" =========================================");
    console.log(" ");
    console.log(" ");
    

    const document_parsed = {
      ECF: {
        Encabezado: {
          Version: this.version,
          IdDoc: {
            TipoeCF: document.TipoeCF, // TODO: agregar en el backend la secuencia a utilizar
            eNCF: document.numero_comprobante, // TODO: agregar en el backend antes de pasarlo por el microservicio
            FechaVencimientoSecuencia: null, // TODO: agregar en el backend antes de pasarlo por el microservicio
            IndicadorNotaCredito: null, // a) Valor 0 si fecha de emisión del e-CF afectado es ≤ 30 días calendario.             b) Valor 1 si fecha de emisión del e-CF afectado es > 30 días calendario.
            IndicadorEnvioDiferido: null,
            IndicadorMontoGravado: 0, // a) Valor 0 si los montos de los items no tienen itbis incluido.             b) Valor 1 si los montos de los items tienen itbis incluido.
            TipoIngresos: tipo_ingreso_E.por_operaciones, // 01: Ingresos por operaciones (No financieros).    02: Ingresos Financieros     03: Ingresos Extraordinarios     04: Ingresos por Arrendamientos     05: Ingresos por Venta de Activo Depreciable     06: Otros Ingresos
            TipoPago: null, // Las facturas por entrega gratuita (código 3), no son válidas para crédito fiscal.
            FechaLimitePago: null, // TODO: agregar en el backend la fecha limite de pago
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
            NumeroFacturaInterna: this.isFactura ? getProperty(document, 'numero_factura').toString()?.padStart(8, '0') : getProperty(document, 'numero_documento').toString()?.padStart(8, '0'),
            NumeroPedidoInterno: null,
            ZonaVenta: null,
            RutaVenta: null,
            InformacionAdicionalEmisor: null,
            FechaEmision: hasValue(document.fecha_equivalente) ? DateUtils.format({ date: document.fecha_equivalente, dateFormat: 'DD-MM-YYYY' }) : null,
          },
          Comprador: {
            RNCComprador: null, // TODO: agregar en el backend antes de pasarlo por el microservicio
            IdentificadorExtranjero: null,
            RazonSocialComprador: document.cliente?.nombre,
            ContactoComprador: null, // TODO: agregar propiedad en la tabla cliente en el backend, nombre de la persona de contacto con la empresa
            CorreoComprador: null, // TODO: agregar propiedad en la tabla cliente en el backend, correo de la empresa
            DireccionComprador: document.cliente?.direccion,
            MunicipioComprador: document.cliente?.municipio?.codigo || null,
            ProvinciaComprador: document.cliente?.provincia?.codigo || null,
            PaisComprador: null,
            FechaEntrega: null,
            ContactoEntrega: null,
            DireccionEntrega: null,
            TelefonoAdicional: null,
            FechaOrdenCompra: null,
            NumeroOrdenCompra: null,
            CodigoInternoComprador: document.cliente?.id?.toString()?.padStart(5, '0') || null,
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
    

    if (this.isNota) {
      const daysFromNow = DateUtils.diffDays(this.factura.fecha_equivalente, new Date());
      document_parsed.ECF.Encabezado.IdDoc.IndicadorNotaCredito = daysFromNow > 30 ? 1 : 0;
    }

    document_parsed.ECF.Encabezado.IdDoc.TipoPago = this.factura.condicion === condicionE.contado ? tipo_pago_codeE.contado : this.factura.condicion === condicionE.credito ? tipo_pago_codeE.credito : tipo_pago_codeE.gratuito;

    if (this.factura.condicion == condicionE.credito && this.isFactura) {
      document_parsed.ECF.Encabezado.IdDoc.FechaLimitePago = this.factura.fecha_vencimiento;
      document_parsed.ECF.Encabezado.IdDoc.TerminoPago = `${document.cliente?.limite_credito} días`;
    }

    document_parsed.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago = [];

    if (this.isFactura) {
      const forma_pago: FormaDePagoE = { FormaPago: forma_pago_codeE[normalizarTexto(this.factura.forma_pago)] };
      if (this.factura.condicion != condicionE.credito) forma_pago.MontoPago = this.factura.total_factura;

      document_parsed.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago.push(forma_pago);
    }

    // ENCABEZADO COMPRADOR

    const documento_identidad = document.cliente?.documentos_de_identidad?.find(documento => documento.principal);
    
    if (!isEmpty(documento_identidad)) document_parsed.ECF.Encabezado.Comprador.RNCComprador = documento_identidad.numero.replace(/-/g, '');

    // ENCABEZADO TOTALES
    const totales = this.totalizacionClass.run(this.detalles, this.isFactura);
    document_parsed.ECF.Encabezado.Totales = totales as any;

    // DETALLESITEMS
    document_parsed.ECF.DetallesItems = this.detallesClass.parse(this.detalles);

    // Paginacion
    document_parsed.ECF.Paginacion = this.parsePaginacion();
    const pages_amount = document_parsed.ECF.Paginacion.Pagina.length;
    document_parsed.ECF.Encabezado.IdDoc.TotalPaginas = pages_amount > 1 ? pages_amount : null;

    if (this.isNota) {
      // codigo_modificacionE
      const diferencia = Math.abs(this.factura_aplicada.factura.total_factura - this.factura_aplicada.total);
      const codigo_modificacion = diferencia <= 0.9 ? codigo_modificacionE.anulacion : codigo_modificacionE.correccion_monto;

      document_parsed.ECF.InformacionReferencia = {
        NCFModificado: this.factura_aplicada.factura.numero_comprobante,
        RNCOtroContribuyente: null,
        FechaNCFModificado: DateUtils.format({ date: this.factura_aplicada.factura.fecha_equivalente, dateFormat: 'DD-MM-YYYY' }),
        CodigoModificacion: codigo_modificacion,
      };
    }

    this.cleanerClass.clean(document_parsed);

    return document_parsed;
  }

  parsePaginacion() {
    const paginacion = { Pagina: [] };

    // TODO: agregar condicion para las notas de credito
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
