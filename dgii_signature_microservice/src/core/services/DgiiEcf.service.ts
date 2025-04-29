import * as path from 'path';
import ECF, { ENVIRONMENT, Signature, Transformer, getCodeSixDigitfromSignature, generateFcQRCodeURL, convertECF32ToRFCE, generateEcfQRCodeURL } from 'dgii-ecf';
import { TrackStatusEnum, TrackingStatusResponse } from 'dgii-ecf/dist/networking/types';
import { crearArchivoXML, retryUntil } from '../../utils/typescript/functions';
const xmlFormatter = require('xml-formatter');
import Queue from 'queue';
import { ParseDocument } from '@utils/typescript/parseDocument';
import { FacturaI } from '@core/types/factura.types';
import { NotaI } from '@core/types/notas.types';
import { EcfXmlJson } from '@core/types/xml/xml_json';
import { tipoComprobanteE } from '@core/constants/factura.const';
import { rootElNameE } from '@core/constants/xml.const';
import { QrUrlDgiiData } from '@core/constants/dgii.const';
import { DateUtils } from '@vjose1903/dateutils';
import { DgiiAuthService } from './DgiiAuth.service';

export class DgiiEcfService {
  private static instance: DgiiEcfService;
  private ecf!: ECF;
  private signature!: Signature;
  private queue: Queue;
  private environment: any;
  private transformer: Transformer;
  private env: ENVIRONMENT;

  private authService: DgiiAuthService;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiEcfService {
    if (!DgiiEcfService.instance) DgiiEcfService.instance = new DgiiEcfService();
    return DgiiEcfService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 3, autostart: true });
    this.environment = process.env;
    this.transformer = new Transformer();
    this.authService = DgiiAuthService.getInstance();
    this.ecf = this.authService.ecf;
    this.signature = this.authService.signature;

    // this.env = ENVIRONMENT.CERT;
    this.env = this.environment.ENV;
  }

  public async firmarYEnviarXML(jsonData: FacturaI | NotaI) {
    return new Promise<{ success: boolean; message?: any; data?: any }>((resolve, reject) => {
      this.authService
        .validateTokenBeforeSend()
        .then(async () => {
          try {
            const { factura, parser } = this.convertToEcfXmlJson(jsonData);
            let fileName = `${this.environment.RNC_EMISOR}${jsonData.numero_comprobante}.xml`;
            let sendResponse = null;
            let qr_url_dgii = '';

            let qr_url_dgii_data: QrUrlDgiiData = { rncemisor: this.environment.RNC_EMISOR, encf: parser.eNCF, montototal: factura.ECF.Encabezado.Totales.MontoTotal, env: this.env };

            const xml = this.transformer.json2xml(factura);

            let signedXml = this.signature.signXml(xml, rootElNameE.ECF);
            qr_url_dgii_data.codigoseguridad = getCodeSixDigitfromSignature(signedXml);

            if (jsonData.TipoeCF == tipoComprobanteE.factura_de_consumo && (jsonData as FacturaI).total_factura < 250000) {
              console.log(' ');
              console.log(' ');
              console.log(' =====================================================');
              console.log('    Factura de consumo con valor menor a 250,000');
              console.log(' =====================================================');
              console.log(' ');
              console.log(' ');

              const { xml } = convertECF32ToRFCE(signedXml);

              signedXml = this.signature.signXml(xml, rootElNameE.RFCE);

              sendResponse = await this.ecf.sendSummary(signedXml, fileName);

              qr_url_dgii = generateFcQRCodeURL(qr_url_dgii_data.rncemisor, qr_url_dgii_data.encf, qr_url_dgii_data.montototal, qr_url_dgii_data.codigoseguridad, qr_url_dgii_data.env);
            } else {
              sendResponse = await this.ecf.sendElectronicDocument(signedXml, fileName);

              qr_url_dgii_data.rncComprador = factura.ECF.Encabezado?.Comprador?.RNCComprador || '';
              qr_url_dgii_data.fechaEmision = DateUtils.format({ dateFormat: 'DD-MM-YYYY' });
              qr_url_dgii_data.fechaFirma = factura.ECF.FechaHoraFirma;

              qr_url_dgii = generateEcfQRCodeURL(
                qr_url_dgii_data.rncemisor,
                qr_url_dgii_data.rncComprador,
                qr_url_dgii_data.encf,
                qr_url_dgii_data.montototal.toString(),
                qr_url_dgii_data.fechaEmision,
                qr_url_dgii_data.fechaFirma,
                qr_url_dgii_data.codigoseguridad,
                qr_url_dgii_data.env
              );
            }

            this.validateSendResponse(sendResponse)
              .then(async response => {
                console.log('response ', response);

                // -------------------------------------------------------
                const formattedXml = xmlFormatter(signedXml, {
                  collapseContent: true,
                  indentation: '  ',
                  lineSeparator: '\n',
                  prettyPrint: true,
                });
                // -------------------------------------------------------

                if (parser.rnc_comprador) {
                  const responseCustomerDirectory = await this.ecf.getCustomerDirectory(parser.rnc_comprador);
                  // this.ecf.voidENCF();
                  console.log('responseCustomerDirectory ', responseCustomerDirectory);
                }

                crearArchivoXML(formattedXml, path.resolve(__dirname, `../../utils/paso-4/firmados/${fileName}`));

                const message_from_send = response.mensajes.reduce((acc, curr) => {
                  acc += `${acc.length > 0 ? ', ' : ''}${curr.valor}`;

                  return acc;
                }, '');

                const data = {
                  estado: response.estado,
                  message: message_from_send,
                  fecha_hora_firma: factura.ECF.FechaHoraFirma,
                  trackId: sendResponse.trackId,
                  security_code: qr_url_dgii_data.codigoseguridad,
                  xml_file_name: fileName,
                  qr_url_dgii,
                };

                // return { success: true, response };
                resolve({ success: true, data });
              })
              .catch(error => {
                reject(error);
              });
          } catch (error) {
            console.error(error);
            reject(error);
          }
        })
        .catch(error => {
          reject(error);
        });
    });
  }

  validateSendResponse(sendResponse: any) {
    return new Promise<TrackingStatusResponse>((resolve, reject) => {
      try {
        if (!('trackId' in sendResponse)) {
          resolve(null);
          return;
        }

        const taskGetStatus = () => this.ecf.statusTrackId(sendResponse.trackId);
        const reintentarSi = (response: TrackingStatusResponse) => response.estado === TrackStatusEnum.IN_PROCESS;
        const noTableLoaded = () => reject({ success: false, message: 'Error al obtener el estado de la factura.' });

        const returnResponse = (response: TrackingStatusResponse) => {
          resolve(response);
        };

        retryUntil(taskGetStatus, reintentarSi, returnResponse.bind(this), noTableLoaded);
      } catch (error) {
        reject(error);
      }
    });
  }

  convertToEcfXmlJson(jsonData: any): { factura: EcfXmlJson; parser: ParseDocument } {
    const parser = new ParseDocument(jsonData);
    const factura: EcfXmlJson = parser.parse();
    return { factura, parser };
  }

  public async addToQueue(jsonData: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      try {
        this.queue.push(async () => {
          this.firmarYEnviarXML(jsonData)
            .then(result => {
              if (result && result.success) resolve(result);
              else reject(result);
            })
            .catch(error => {
              reject({ success: false, message: error.message || 'Error procesando la solicitud.' });
            });
        });
      } catch (error) {
        reject({ success: false, message: error.message || 'Error al agregar a la cola.' });
      }
    });
  }
}
