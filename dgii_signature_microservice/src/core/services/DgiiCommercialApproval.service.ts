import * as path from 'path';
import ECF, { ENVIRONMENT, Signature, Transformer, getCodeSixDigitfromSignature, generateFcQRCodeURL, convertECF32ToRFCE, generateEcfQRCodeURL, SenderReceiver, ReceivedStatus, validateXMLCertificate } from 'dgii-ecf';
import { TrackStatusEnum, TrackingStatusResponse, InvoiceSummaryResponse, InvoiceResponse } from 'dgii-ecf/dist/networking/types';
import { guardarArchivoXML, getProperty, hasValue, isEmpty, retryUntil } from '../../utils/typescript/functions';
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

export class DgiiCommercialApprovalService {
  private static instance: DgiiCommercialApprovalService;
  private ecf!: ECF;
  private signature!: Signature;
  private queue: Queue;
  private environment: any;
  private transformer: Transformer;
  private env: ENVIRONMENT;
  
  private senderReceiver: SenderReceiver;

  private authService: DgiiAuthService;
  private anulacionService: DgiiAnulacionService;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiCommercialApprovalService {
    if (!DgiiCommercialApprovalService.instance) DgiiCommercialApprovalService.instance = new DgiiCommercialApprovalService();
    return DgiiCommercialApprovalService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 5, autostart: true });
    this.environment = process.env;
    this.transformer = new Transformer();

    this.authService = DgiiAuthService.getInstance();
    this.ecf = this.authService.ecf;
    this.signature = this.authService.signature;


    this.senderReceiver = new SenderReceiver();

    this.anulacionService = DgiiAnulacionService.getInstance();

    // this.env = ENVIRONMENT.CERT;
    this.env = ENVIRONMENT[this.environment.ENV as keyof typeof ENVIRONMENT];
  }

  public async validateApproval(data: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>((resolve, reject) => {
      this.authService
        .validateTokenBeforeSend()
        .then(async () => {
          try {

            const result = validateXMLCertificate(data.xml);
            console.log('result ', result);
            
            resolve({ success: true, data: result, message: '' });
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

  public async addToQueue(data: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      try {
        this.queue.push(async () => {
          this.validateApproval(data)
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
