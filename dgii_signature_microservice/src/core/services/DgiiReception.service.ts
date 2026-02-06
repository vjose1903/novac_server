import ECF, { Signature, SenderReceiver, ReceivedStatus } from 'dgii-ecf';
import { TrackStatusEnum, TrackingStatusResponse, InvoiceSummaryResponse, InvoiceResponse } from 'dgii-ecf/dist/networking/types';
import { getProperty, isEmpty, retryUntil } from '../../utils/typescript/functions';
import Queue from 'queue';
import { ParseDocument } from '@utils/typescript/parseDocument';
import { EcfXmlJson } from '@core/types/xml/xml_json';
import { rootElNameE } from '@core/constants/xml.const';
import { DgiiAuthService } from './DgiiAuth.service';
import GoogleDriveUtils from '@utils/typescript/google/google_drive.utils';

export class DgiiReceptionService {
  private static instance: DgiiReceptionService;
  private queue: Queue;
  private environment: any;
  private received_folder: string;
  private acuse_emitted_folder: string;

  private senderReceiver: SenderReceiver;
  private authService: DgiiAuthService;
  private googleDrive: GoogleDriveUtils;

  // Getters dinámicos para obtener siempre las referencias actualizadas
  private get ecf(): ECF {
    return this.authService.ecf;
  }

  private get signature(): Signature {
    return this.authService.signature;
  }

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiReceptionService {
    if (!DgiiReceptionService.instance) DgiiReceptionService.instance = new DgiiReceptionService();
    return DgiiReceptionService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 5, autostart: true });
    this.environment = process.env;
    this.received_folder = this.environment.RECEIVED_FOLDER_ID;
    this.acuse_emitted_folder = this.environment.ACUSE_EMITTED_FOLDER_ID;

    this.authService = DgiiAuthService.getInstance();
    await this.authService.validateToken();

    this.googleDrive = await GoogleDriveUtils.getInstance();

    this.senderReceiver = new SenderReceiver();
  }

  public async processReception(data: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>((resolve, reject) => {
      this.authService
        .validateToken()
        .then(async () => {
          try {
            const xml = data.xml;
            const fileName = data.fileName;

            const ecfData = this.senderReceiver.getECFDataFromXML(xml, this.environment.RNC_EMISOR, ReceivedStatus['e-CF Recibido']);
            const signedXml = this.signature.signXml(ecfData, rootElNameE.ARECF);

            await this.googleDrive.uploadFile(this.received_folder, xml, fileName);
            await this.googleDrive.uploadFile(this.acuse_emitted_folder, signedXml, fileName.replace('.xml', '_emitted.xml'));

            resolve({ success: true, data: signedXml, message: '' });
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

        retryUntil({
          task: () => this.ecf.statusTrackId(sendResponse.trackId),
          retryWhen: (response: TrackingStatusResponse) => response.estado === TrackStatusEnum.IN_PROCESS,
          onSuccess: resolve,
          onError: () => reject({ success: false, message: 'Error al obtener el estado de la factura.', secuenciaUtilizada: false }),
          delayBetweenRetries: 200,
          retryMax: 15,
          useBackoff: true,
          maxBackoffDelay: 2000,
        });
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
          this.processReception(data)
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
