import ECF, { Signature, Transformer } from 'dgii-ecf';
const xmlFormatter = require('xml-formatter');
import Queue from 'queue';
import { rootElNameE } from '@core/constants/xml.const';
import { DgiiAuthService } from './DgiiAuth.service';
import { ParseAnulacion } from '@utils/typescript/parseAnulacion';
import { AnulacionParams } from '@core/types/anulacion.types';

export class DgiiAnulacionService {
  private static instance: DgiiAnulacionService;
  private ecf!: ECF;
  private signature!: Signature;
  private queue: Queue;
  private transformer: Transformer;

  private authService: DgiiAuthService;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiAnulacionService {
    if (!DgiiAnulacionService.instance) DgiiAnulacionService.instance = new DgiiAnulacionService();
    return DgiiAnulacionService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 3, autostart: true });
    this.transformer = new Transformer();

    this.authService = DgiiAuthService.getInstance();
    await this.authService.validateToken();
    
    this.ecf = this.authService.ecf;
    this.signature = this.authService.signature;
  }

  public async firmarYEnviarXML(anulacionParams: AnulacionParams[]) {
    return new Promise<{ success: boolean; message?: any; data?: any }>((resolve, reject) => {
      this.authService
        .validateToken()
        .then(async () => {
          try {
            const anulacion = new ParseAnulacion().parse(anulacionParams);

            let fileName = 'anulacion.xml';
            const xml = this.transformer.json2xml(anulacion);
            let signedXml = this.signature.signXml(xml, rootElNameE.ANECF);

            this.ecf
              .voidENCF(signedXml, fileName)
              .then(sendResponse => {
                const message_from_send = sendResponse.mensajes.reduce((acc, curr) => {
                  acc += `${acc.length > 0 ? ', ' : ''}${curr}`;

                  return acc;
                }, '');

                const data = { message: message_from_send };

                resolve({ success: true, data });
              })
              .catch(error => {
                reject({ success: false, message: error.mensajes.join(', ') || 'Error al firmar y enviar el XML.' });
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

  public async addToQueue(anulacionParams: AnulacionParams[]) {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      try {
        this.queue.push(async () => {
          this.firmarYEnviarXML(anulacionParams)
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
