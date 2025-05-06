import * as path from 'path';
import ECF, { ENVIRONMENT, Signature, Transformer, getCodeSixDigitfromSignature, generateFcQRCodeURL, convertECF32ToRFCE, generateEcfQRCodeURL } from 'dgii-ecf';
import { TrackStatusEnum, TrackingStatusResponse, InvoiceSummaryResponse, InvoiceResponse } from 'dgii-ecf/dist/networking/types';
import { crearArchivoXML, getProperty, hasValue, isEmpty, retryUntil } from '../../utils/typescript/functions';
const xmlFormatter = require('xml-formatter');
import Queue from 'queue';
import { ParseDocument } from '@utils/typescript/parseDocument';
import { FacturaI } from '@core/types/factura.types';
import { NotaI } from '@core/types/notas.types';
import { EcfXmlJson } from '@core/types/xml/xml_json';
import { codigo_modificacion_labelE, num_codigo_modificacion_to_label, tipoComprobanteE } from '@core/constants/factura.const';
import { rootElNameE } from '@core/constants/xml.const';
import { QrUrlDgiiData } from '@core/constants/dgii.const';
import { DateUtils } from '@vjose1903/dateutils';
import { DgiiAuthService } from './DgiiAuth.service';
import { DgiiAnulacionService } from './DgiiAnulacion.service';

export class DgiiEcfService {
  private static instance: DgiiEcfService;
  private ecf!: ECF;
  private signature!: Signature;
  private queue: Queue;
  private environment: any;
  private transformer: Transformer;
  private env: ENVIRONMENT;

  private authService: DgiiAuthService;
  private anulacionService: DgiiAnulacionService;

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

    this.anulacionService = DgiiAnulacionService.getInstance();

    // this.env = ENVIRONMENT.CERT;
    this.env = ENVIRONMENT[this.environment.ENV as keyof typeof ENVIRONMENT];
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
              const fc_extendido_file_name = fileName.replace('.xml', '_ext.xml');
              crearArchivoXML(signedXml, path.resolve(__dirname, `../../utils/paso-4/firmados/${fc_extendido_file_name}`));

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

            console.log('sendResponse ', sendResponse);

            this.validateSendResponse(sendResponse)
              .then(async response => {
                console.log('response validation ', response);
                // -------------------------------------------------------
                const formattedXml = xmlFormatter(signedXml, {
                  collapseContent: true,
                  indentation: '  ',
                  lineSeparator: '\n',
                  prettyPrint: true,
                });
                console.log('1');

                // -------------------------------------------------------
                // if (getProperty(response, 'estado') !== TrackStatusEnum.REJECTED) {
                if (parser.rnc_comprador) {
                  // const responseCustomerDirectory = await this.ecf.getCustomerDirectory(parser.rnc_comprador);
                  // console.log('\n\nresponseCustomerDirectory ', responseCustomerDirectory);
                }
                console.log('2');

                crearArchivoXML(formattedXml, path.resolve(__dirname, `../../utils/paso-4/firmados/${fileName}`));

                console.log('3');

                const data = {
                  fecha_hora_firma: factura.ECF.FechaHoraFirma,
                  security_code: qr_url_dgii_data.codigoseguridad,
                  xml_file_name: fileName,
                  secuenciaUtilizada: getProperty(response, 'secuenciaUtilizada'),
                  qr_url_dgii,
                };

                if (jsonData.TipoeCF == tipoComprobanteE.nota_de_credito || jsonData.TipoeCF == tipoComprobanteE.nota_de_debito) {
                  const codigo_modificacion = getProperty(factura?.ECF?.InformacionReferencia, 'CodigoModificacion');
                  if (codigo_modificacion) data['razon'] = codigo_modificacion_labelE[num_codigo_modificacion_to_label[`_${codigo_modificacion}`]];
                }
                console.log('data ', data);

                data['estado'] = 'estado' in response ? response?.estado : null;
                data['trackId'] = 'trackId' in response ? response?.trackId : null;

                resolve({ success: true, data, message: this.getMessage(response) });
              })
              .catch(error => {
                reject(error);
              });
          } catch (error) {
            console.error('error =================> ', error);
            const msg = this.getMessage(error);
            reject({ success: false, message: msg || 'Error al firmar y enviar el XML.', secuenciaUtilizada: false });
          }
        })
        .catch(error => {
          reject(error);
        });
    });
  }

  getMessage(response: TrackingStatusResponse | InvoiceSummaryResponse | InvoiceResponse) {
    if (isEmpty(response?.mensajes)) return '';

    const message_from_send = response.mensajes.reduce((acc, curr) => {
      const valor = getProperty(curr, 'valor');
      acc += `${acc.length > 0 ? ', ' : ''}${typeof curr === 'string' ? curr : valor}`;

      return acc;
    }, '');

    return message_from_send;
  }

  validateSendResponse(sendResponse: any) {
    return new Promise<TrackingStatusResponse | InvoiceSummaryResponse | InvoiceResponse>((resolve, reject) => {
      try {
        if (!('trackId' in sendResponse)) {
          resolve(sendResponse);
          return;
        }

        const taskGetStatus = () => this.ecf.statusTrackId(sendResponse.trackId);
        const reintentarSi = (response: TrackingStatusResponse) => response.estado === TrackStatusEnum.IN_PROCESS;
        const errorFunction = () => reject({ success: false, message: 'Error al obtener el estado de la factura.', secuenciaUtilizada: false });
        const returnResponse = (response: TrackingStatusResponse) => resolve(response);

        retryUntil(taskGetStatus, reintentarSi, returnResponse.bind(this), errorFunction);
      } catch (error) {
        reject({ success: false, message: error.message || 'Error al obtener el estado de la factura.' });
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
              reject({ success: false, message: error.message || 'Error procesando la solicitud.', secuenciaUtilizada: false });
            });
        });
      } catch (error) {
        reject({ success: false, message: error.message || 'Error al agregar a la cola.', secuenciaUtilizada: false });
      }
    });
  }
}
