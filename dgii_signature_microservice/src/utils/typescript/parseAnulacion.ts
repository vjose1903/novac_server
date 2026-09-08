import { getCurrentFormattedDateTime } from 'dgii-ecf';
import { EcfXmlAnulacionJson } from '@core/types/xml/xml_anulacion_json';
import { AnulacionParams } from '@core/types/anulacion.types';

export class ParseAnulacion {
  private version: string;
  private rnc_emisor: string;
  private environment: any;

  constructor() {
    this.environment = process.env;
    this.version = this.environment.XML_VERSION || '1.0';
    this.rnc_emisor = this.environment.RNC_EMISOR || '';
  }

  parse(range: AnulacionParams[]) {
    const document_parsed: EcfXmlAnulacionJson = {
      ANECF: {
        Encabezado: {
          Version: this.version,
          RncEmisor: this.rnc_emisor,
          CantidadeNCFAnulados: 0,
          FechaHoraAnulacioneNCF: getCurrentFormattedDateTime(),
        },
        DetalleAnulacion: {
          Anulacion: [],
        },
      },
    };

    this.parseDetalleAnulacion(document_parsed, range);
    return document_parsed;
  }

  parseDetalleAnulacion(document_parsed: EcfXmlAnulacionJson, range: AnulacionParams[]) {
    const detalles = document_parsed.ANECF.DetalleAnulacion;

    document_parsed.ANECF.DetalleAnulacion = range.reduce((acc, curr, index) => {
      const type = curr.eNCFDesde.substring(1, 3);
      const eNCFDesde = curr.eNCFDesde;
      const eNCFHasta = curr.eNCFHasta || eNCFDesde;

      const desdeNumber = parseInt(eNCFDesde.substring(3, eNCFDesde.length));
      const hastaNumber = parseInt(eNCFHasta.substring(3, eNCFHasta.length));
      const cantidadNCFAnulados = hastaNumber - desdeNumber + 1;

      const anulacion = {
        NoLinea: index + 1,
        TipoeCF: type,
        TablaRangoSecuenciasAnuladaseNCF: {
          Secuencias: {
            SecuenciaeNCFDesde: eNCFDesde,
            SecuenciaeNCFHasta: eNCFHasta,
          },
        },
        CantidadeNCFAnulados: cantidadNCFAnulados,
      };

      document_parsed.ANECF.Encabezado.CantidadeNCFAnulados += cantidadNCFAnulados;
      acc.Anulacion.push(anulacion);

      return acc;
    }, detalles);
  }
}
