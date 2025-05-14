import ECF, { ENVIRONMENT, Signature, Transformer, getCodeSixDigitfromSignature, generateFcQRCodeURL, convertECF32ToRFCE, generateEcfQRCodeURL } from 'dgii-ecf';
import { TrackStatusEnum, TrackingStatusResponse, InvoiceSummaryResponse, InvoiceResponse } from 'dgii-ecf/dist/networking/types';
import { getProperty, isEmpty, retryUntil } from '../../utils/typescript/functions';
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
import GoogleDriveUtils from '@utils/typescript/google/google_drive.utils';

export class DgiiEcfService {
  private static instance: DgiiEcfService;
  private authService: DgiiAuthService;
  private googleDrive: GoogleDriveUtils;

  private ecf!: ECF;
  private signature!: Signature;
  private queue: Queue;
  private environment: any;
  private transformer: Transformer;
  private env: ENVIRONMENT;
  private emitted_folder: string;
  private acuse_recepcion_folder: string;
  private rnc_emisor: string;

  private jsonData: FacturaI | NotaI;

  private get isFCLessThan250K() {
    return this.jsonData.TipoeCF == tipoComprobanteE.factura_de_consumo && (this.jsonData as FacturaI).total_factura < 250000;
  }

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiEcfService {
    let isCreated = true;
    if (!DgiiEcfService.instance) {
      DgiiEcfService.instance = new DgiiEcfService();
      isCreated = false;
    }

    if (isCreated) console.log('\n\n------------------------ INSTANCIA DE DGII ECF SERVICE YA HA SIDO CREADA PREVIAMENTE ------------------------\n\n');
    return DgiiEcfService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 3, autostart: true });
    this.environment = process.env;
    this.emitted_folder = this.environment.EMITTED_FOLDER_ID;
    this.acuse_recepcion_folder = this.environment.ACUSE_RECEIVED_FOLDER_ID;
    this.rnc_emisor = this.environment.RNC_EMISOR;

    this.authService = DgiiAuthService.getInstance();
    await this.authService.validateToken();

    this.googleDrive = await GoogleDriveUtils.getInstance();

    this.transformer = new Transformer();

    this.ecf = this.authService.ecf;
    this.signature = this.authService.signature;

    this.env = ENVIRONMENT[this.environment.ENV as keyof typeof ENVIRONMENT];
  }

  public async firmarYEnviarXML() {
    return new Promise<{ success: boolean; message?: any; data?: any }>((resolve, reject) => {
      this.authService
        .validateToken()
        .then(async () => {
          let sendResponse = null;
          let fileName = `${this.environment.RNC_EMISOR}${this.jsonData.numero_comprobante}.xml`;
          let qr_url_dgii = '';
          let signedXml = '';
          let parser: ParseDocument;
          let factura: EcfXmlJson;
          let qr_url_dgii_data: QrUrlDgiiData;

          try {
            ({ factura, parser } = this.convertToEcfXmlJson());

            qr_url_dgii_data = { rncemisor: this.environment.RNC_EMISOR, encf: parser.eNCF, montototal: factura.ECF.Encabezado.Totales.MontoTotal, env: this.env };

            const xml = this.transformer.json2xml(factura);

            signedXml = this.signature.signXml(xml, rootElNameE.ECF);
            qr_url_dgii_data.codigoseguridad = getCodeSixDigitfromSignature(signedXml);

            if (this.isFCLessThan250K) {
              console.log(' ');
              console.log(' ');
              console.log(' =====================================================');
              console.log('    Factura de consumo con valor menor a 250,000');
              console.log(' =====================================================');
              console.log(' ');
              console.log(' ');
              const fc_extendido_file_name = fileName.replace('.xml', '_ext.xml');
              await this.googleDrive.uploadFile(this.emitted_folder, signedXml, fc_extendido_file_name);

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
          } catch (error) {
            console.error('error =================> ', error);
            const msg = this.getMessage(error);
            reject({ success: false, message: msg || 'Error al firmar y enviar el XML.', secuenciaUtilizada: false });
          }

          this.validateSendResponse(sendResponse)
            .then(async response => {
              console.log('response validation ', response);

              if (parser.rnc_comprador && !this.isFCLessThan250K && getProperty(response, 'estado') != TrackStatusEnum.REJECTED) {
                try {
                  const responseCustomerDirectory = await this.ecf.getCustomerDirectory(parser.rnc_comprador);
                  console.log('\n\nresponseCustomerDirectory ', responseCustomerDirectory);

                  if (responseCustomerDirectory.length > 0) {
                    const buyerHost = responseCustomerDirectory[0].urlRecepcion;

                    if (!this.isFCLessThan250K && buyerHost) {
                      const acuseRecepcion = (await this.ecf.sendElectronicDocument(signedXml, fileName, buyerHost)) as string;
                      const acuseFileName = fileName.replace(this.rnc_emisor, `${parser.rnc_comprador}`);
                      await this.googleDrive.uploadFile(this.acuse_recepcion_folder, acuseRecepcion, acuseFileName);
                    }
                  }
                } catch (error) {
                  console.error('Error al enviar documento al comprador:', error);
                }
              }

              const secuenciaUtilizada = getProperty(response, 'secuenciaUtilizada');

              try {
                console.log('2');

                await this.googleDrive.uploadFile(this.emitted_folder, signedXml, fileName);

                console.log('3');

                const data = {
                  fecha_hora_firma: factura.ECF.FechaHoraFirma,
                  security_code: qr_url_dgii_data.codigoseguridad,
                  xml_file_name: fileName,
                  secuenciaUtilizada,
                  qr_url_dgii,
                };

                if (this.jsonData.TipoeCF == tipoComprobanteE.nota_de_credito || this.jsonData.TipoeCF == tipoComprobanteE.nota_de_debito) {
                  const codigo_modificacion = getProperty(factura?.ECF?.InformacionReferencia, 'CodigoModificacion');
                  if (codigo_modificacion) data['razon'] = codigo_modificacion_labelE[num_codigo_modificacion_to_label[`_${codigo_modificacion}`]];
                }

                console.log('data ', data);

                data['estado'] = 'estado' in response ? response?.estado : null;
                data['trackId'] = 'trackId' in response ? response?.trackId : null;

                resolve({ success: true, data, message: this.getMessage(response) });
              } catch (error) {
                console.error('Error al guardar el archivo XML:', error);
                reject({ success: false, message: 'Error al guardar el archivo XML.', secuenciaUtilizada });
              }
            })
            .catch(error => {
              reject(error);
            });
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

  convertToEcfXmlJson(): { factura: EcfXmlJson; parser: ParseDocument } {
    const parser = new ParseDocument(this.jsonData);
    const factura: EcfXmlJson = parser.parse();
    return { factura, parser };
  }

  public async addToQueue(jsonData: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      try {
        this.queue.push(async () => {
          this.jsonData = jsonData;
          this.firmarYEnviarXML()
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
