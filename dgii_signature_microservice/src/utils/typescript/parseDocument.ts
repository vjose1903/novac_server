import { DetalleFacturaI, FacturaI } from '@core/types/factura.types';
import { Clean } from './clean';
import { isEmpty, normalizarTexto, redondearNum } from './functions';
import { condicionE, forma_pago_codeE, indicadorBienoServicioE, indicadorFacturacionE, sheet_typeE, tipo_pago_codeE, unidad_codeE } from '@core/constants/factura.utils';
import { FormaDePagoE, DescuentoORecargoI } from '@core/types/xml/xml_json';
import { CodigosItem, ItemI } from '@core/types/xml/xml_detallesItem_json';
import { Totalizacion } from './totalizacion';
import { agruparArticulosPorPagina } from './paginacion';
import { PaginacionI } from '@core/types/xml/xml_paginacion_json';
import { NotaI } from '@core/types/notas.types';
import { documentTypeE } from '@core/types/document.types';
import { DateUtils } from '@vjose1903/dateutils';

export class ParseDocument {
  private version: string;
  private rnc_emisor: string;
  private environment: any;
  private sheet_type: sheet_typeE;
  private items_per_page: number;
  private items_per_page_credit: number;

  private cleaner: Clean;
  private totalizacion: Totalizacion;

  private document: FacturaI | NotaI;

  constructor() {
    this.environment = process.env;
    this.version = this.environment.XML_VERSION || '1.0';
    this.rnc_emisor = this.environment.RNC_EMISOR || '';
    this.sheet_type = sheet_typeE[this.environment.SHEET_TYPE] || sheet_typeE.paper;
    this.items_per_page = this.environment.ITEMS_PER_PAGE || 9;
    this.items_per_page_credit = this.environment.ITEMS_PER_PAGE_CREDIT || 18;

    this.cleaner = new Clean();
    this.totalizacion = new Totalizacion();
  }

  get isFactura() {
    return this.document.document_type == documentTypeE.factura;
  }

  get isNota() {
    return this.document.document_type == documentTypeE.nota;
  }

  get factura_aplicada() {
    return this.document.facturas_aplicadas[0];
  }

  parse(document: FacturaI | NotaI) {
    this.document = document;

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
            IndicadorMontoGravado: null, // a) Valor 0 si los montos de los items no tienen itbis incluido.             b) Valor 1 si los montos de los items tienen itbis incluido.
            TipoIngresos: '01', // 01: Ingresos por operaciones (No financieros).    02: Ingresos Financieros     03: Ingresos Extraordinarios     04: Ingresos por Arrendamientos     05: Ingresos por Venta de Activo Depreciable     06: Otros Ingresos
            TipoPago: null, // Las facturas por entrega gratuita (código 3), no son válidas para crédito fiscal.
            FechaLimitePago: null, // TODO: agregar en el backend la fecha limite de pago
            TerminoPago: null,
            TablaFormasPago: {
              FormaDePago: [],
            },
            TipoCuentaPago: null, // CT: Cta. Corriente AH: Ahorro OT: Otra TODO: agregar en el backend
            NumeroCuentaPago: null, // Número de la cuenta si la forma de pago es por cheque o transferencia bancaria.
            BancoPago: null, // Banco de la Cuenta
            FechaDesde: null, // Período de facturación para Servicios Periódicos Ej. Energía eléctrica, telefónica, otros. Fecha desde (Fecha inicial del servicio facturado).
            FechaHasta: null, // Período de facturación para Servicios Periódicos. Fecha hasta (Fecha final del servicio facturado).
            TotalPaginas: null, // TODO: agregar un mecanismo para poder saber cuantos items por pagina tendra dependiendo del cliente
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
            NumeroFacturaInterna: document.numero_factura, // TODO: agregar en el backend el numero de factura interna
            NumeroPedidoInterno: null,
            ZonaVenta: null,
            RutaVenta: null,
            InformacionAdicionalEmisor: null,
            FechaEmision: document.fecha_equivalente,
          },
          Comprador: {
            RNCComprador: null, // TODO: agregar en el backend antes de pasarlo por el microservicio
            IdentificadorExtranjero: null,
            RazonSocialComprador: document.cliente?.nombre,
            ContactoComprador: null, // TODO: agregar propiedad en la tabla cliente en el backend
            CorreoComprador: null, // TODO: agregar propiedad en la tabla cliente en el backend
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
            MontoGravadoI1: null, // TODO: hacer un metodo que sume los totales de cada item que tenga identificadorFacturacion = 1
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
      if (this.factura_aplicada) document_parsed.ECF.Encabezado.IdDoc.IndicadorNotaCredito = this.factura_aplicada.fecha_equivalente 
    }

    document_parsed.ECF.Encabezado.IdDoc.IndicadorMontoGravado = 0;
    document_parsed.ECF.Encabezado.IdDoc.TipoPago = document.condicion === condicionE.contado ? tipo_pago_codeE.contado : document.condicion === condicionE.credito ? tipo_pago_codeE.credito : tipo_pago_codeE.gratuito;

    if (document.condicion == condicionE.credito) {
      document_parsed.ECF.Encabezado.IdDoc.FechaLimitePago = document.fecha_limite_pago;
      document_parsed.ECF.Encabezado.IdDoc.TerminoPago = `${document.cliente?.limite_credito} días`;
    }

    document_parsed.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago = [];

    const forma_pago: FormaDePagoE = { FormaPago: forma_pago_codeE[normalizarTexto(document.forma_pago)] };
    if (document.condicion != condicionE.credito) forma_pago.MontoPago = document.total_factura;

    document_parsed.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago.push(forma_pago);

    // ENCABEZADO COMPRADOR

    const documento_identidad = document.cliente?.documentos_de_identidad?.find(documento => documento.principal);
    if (!isEmpty(documento_identidad)) document_parsed.ECF.Encabezado.Comprador.RNCComprador = document.cliente?.documentos_de_identidad[0].documento;

    // ENCABEZADO TOTALES
    const totales = this.totalizacion.run(document.detalle_facturas);
    document_parsed.ECF.Encabezado.Totales = totales as any;

    // DETALLESITEMS
    document_parsed.ECF.DetallesItems = this.parseDetalles();

    // Paginacion
    document_parsed.ECF.Paginacion = this.parsePaginacion();

    if (document.condicion == condicionE.credito) {
      document_parsed.ECF.InformacionReferencia = {
        NCFModificado: document.eNCF,
        RNCOtroContribuyente: null,
        FechaNCFModificado: document.fecha_equivalente,
        CodigoModificacion: null,
      };
    }

    this.cleaner.clean(document_parsed);

    return document_parsed;
  }

  parseDetalles() {
    const detallesItems = { Item: [] };

    this.document.detalle_facturas.forEach((item: DetalleFacturaI, index: number) => {
      const itemParsed = {} as ItemI;
      itemParsed.NumeroLinea = `${index + 1}`;

      itemParsed.TablaCodigosItem = { CodigosItem: [] };
      const codigo: CodigosItem = { TipoCodigo: 'Interna', CodigoItem: item.codigo };
      itemParsed.TablaCodigosItem.CodigosItem.push(codigo);

      // TODO: revisar
      itemParsed.IndicadorFacturacion = item.articulo.calcular_itbis ? indicadorFacturacionE.itbis_18 : indicadorFacturacionE.excento;

      itemParsed.NombreItem = item.descripcion;
      itemParsed.IndicadorBienoServicio = item.articulo.tipo_articulo.descripcion.toLowerCase().includes('servicio') ? indicadorBienoServicioE.servicio : indicadorBienoServicioE.bien;
      itemParsed.CantidadItem = redondearNum(item.cantidad);

      let key_unidad = item.unidad.replace(' ', '_').toLowerCase();
      if (key_unidad.match(/saco_de_(\d+)?_libras/)) key_unidad = 'saco';
      if (key_unidad == 'funda') key_unidad = 'bolsa';

      itemParsed.UnidadMedida = unidad_codeE[item.articulo.unidad_medida] || null;
      itemParsed.PrecioUnitarioItem = redondearNum(item.precio);

      if (item.descuento_valor) {
        itemParsed.DescuentoMonto = redondearNum(item.descuento_valor);

        itemParsed.TablaSubDescuento = {
          SubDescuento: [
            {
              TipoSubDescuento: '$',
              MontoSubDescuento: redondearNum(item.descuento_valor),
            },
          ],
        };
      }

      itemParsed.MontoItem = redondearNum(Number(itemParsed.PrecioUnitarioItem) * item.cantidad - Number(itemParsed.DescuentoMonto || 0));
      detallesItems.Item.push(itemParsed);
    });

    return detallesItems;
  }

  parsePaginacion() {
    const paginacion = { Pagina: [] };

    // TODO: agregar condicion para las notas de credito
    const items_per_page = this.document.condicion == condicionE.contado ? this.items_per_page : this.items_per_page_credit;

    if (this.sheet_type == sheet_typeE.paper && this.document.detalle_facturas.length > items_per_page) {
      const articulos_agrupados = agruparArticulosPorPagina(this.document.detalle_facturas, items_per_page);

      articulos_agrupados.forEach((grupo, index) => {
        const paginaParsed = {} as PaginacionI;
        paginaParsed.PaginaNo = `${index + 1}`;
        paginaParsed.NoLineaDesde = `${index * items_per_page + 1}`;
        paginaParsed.NoLineaHasta = `${(index + 1) * items_per_page}`;

        const totales = this.totalizacion.run(grupo);
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
