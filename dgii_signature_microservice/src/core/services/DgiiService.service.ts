import * as fs from 'fs';
import * as path from 'path';
import ECF, { P12Reader, ENVIRONMENT, Signature } from 'dgii-ecf';
import { P12ReaderData, CommercialApprovalEnum } from '../../utils/types/readerData.types';
import { crearArchivoXML, isEmpty, sleep } from '../../utils/typescript/functions';
// const xmlFormatter = require('xml-formatter');
import Queue from 'queue';
import { TokenData } from '../../utils/types/token.types';

export class DgiiService {
  private static instance: DgiiService;
  private ecf!: ECF;
  private signature!: Signature;
  private authToken: TokenData | null = null;
  private isAuthenticating: boolean = false;
  private authQueue: { resolve: (result: { success: boolean; message?: string }) => void; reject: (error: any) => void }[] = [];
  private queue: Queue;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiService {
    if (!DgiiService.instance) DgiiService.instance = new DgiiService();
    return DgiiService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 3, autostart: true });
    await this.loadCertificates();
    // await this.authenticate();
  }

  private async loadCertificates() {
    try {
      const secret = 'VICVAS01';
      const reader = new P12Reader(secret);
      const certs = reader.getKeyFromFile(path.resolve(__dirname, '../../utils/firma-digital.p12'));

      this.ecf = new ECF(certs, ENVIRONMENT.CERT);
      this.signature = new Signature(certs.key, certs.cert);
    } catch (error) {
      console.error('Error cargando certificados:', error);
      throw new Error('No se pudieron cargar los certificados.');
    }
  }

  private async authenticate() {
    return new Promise<{ success: boolean; message?: string }>((resolvePrincipal, rejectPrincipal) => {
      if (this.isAuthenticating) {
        return this.authQueue.push({ resolve: resolvePrincipal, reject: rejectPrincipal });
      }

      this.isAuthenticating = true;

      this.ecf
        .authenticate()
        .then(authToken => {
          this.authToken = authToken;

          this.authQueue.forEach(task => task.resolve({ success: true }));
          this.authQueue = [];
          resolvePrincipal({ success: true });
        })
        .catch(error => {
          const result = { success: false, message: error?.message || 'Error de autenticación. Servicio de la DGII no disponible.' };
          this.authQueue.forEach(task => task.reject(result));
          this.authQueue = [];
          rejectPrincipal(result);
        })
        .finally(() => {
          this.isAuthenticating = false;
        });
    });
  }

  private isTokenExpired(): boolean {
    if (isEmpty(this.authToken)) return true;
    return new Date(this.authToken.expira) <= new Date();
  }

  private tokenIsValid() {
    if (isEmpty(this.authToken)) return true;

    const tokenIsValid = typeof this.authToken.token === 'string' && typeof this.authToken.expira === 'string' && typeof this.authToken.expedido === 'string';

    if (!tokenIsValid) return true;

    const expired = this.isTokenExpired();

    return expired;
  }

  private async validateTokenBeforeSend() {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      if (this.tokenIsValid()) {
        this.authenticate()
          .then(result => {
            if (this.tokenIsValid()) {
              reject({ success: false, message: 'Error de autenticación. No se pudo obtener un token válido.' });
            }
          })
          .catch(error => {
            reject(error);
          });
      } else {
        resolve({ success: true });
      }
    });
  }

  public async firmarYEnviarXML(jsonData: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>((resolve, reject) => {
      this.validateTokenBeforeSend()
        .then(() => {
          // const xml = '';

          // const fileName = `${jsonData.RNCComprador}${jsonData.noEcf}.xml`;

          // const signedXml = this.signature.signXml(xml, 'ACECF');
          // const formattedXml = xmlFormatter(signedXml, {
          //   collapseContent: true,
          //   indentation: '  ',
          //   lineSeparator: '\n',
          //   prettyPrint: true,
          // });

          // const response = await this.ecf.sendCommercialApproval(signedXml, fileName);
          // await sleep(2000);

          // crearArchivoXML(formattedXml, path.resolve(__dirname, `./firmados/${fileName}`));

          // return { success: true, response };
          resolve({ success: true });
        })
        .catch(error => {
          reject(error);
        });
    });
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
