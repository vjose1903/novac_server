import { getCurrentFormattedDateTime } from 'dgii-ecf';
import { EcfXmlAnulacionJson } from '@core/types/xml/xml_anulacion_json';

export class ParseAnulacion {
  private version: string;
  private rnc_emisor: string;
  private environment: any;

  constructor() {
    this.environment = process.env;
    this.version = this.environment.XML_VERSION || '1.0';
    this.rnc_emisor = this.environment.RNC_EMISOR || '';
  }

  parse(eNCFDesde: string, eNCFHasta?: string) {
    eNCFHasta ||= eNCFDesde;

    const type = eNCFDesde.substring(0, 3);
    const desdeNumber = parseInt(eNCFDesde.substring(3, eNCFDesde.length));
    const hastaNumber = parseInt(eNCFHasta.substring(3, eNCFHasta.length));

    const cantidadNCFAnulados = hastaNumber - desdeNumber + 1;
    const document_parsed: EcfXmlAnulacionJson = {
      ANECF: {
        Encabezado: {
          Version: this.version,
          RncEmisor: this.rnc_emisor,
          CantidadeNCFAnulados: cantidadNCFAnulados,
          FechaHoraAnulacioneNCF: getCurrentFormattedDateTime(),
        },
        DetalleAnulacion: {
          Anulacion: [
            {
              NoLinea: 1,
              TipoeCF: type,
              TablaRangoSecuenciasAnuladaseNCF: {
                SecuenciaeNCFDesde: eNCFDesde,
                SecuenciaeNCFHasta: eNCFHasta,
              },
              CantidadeNCFAnulados: cantidadNCFAnulados,
            },
          ],
        },
      },
    };
    return document_parsed;
  }
}
