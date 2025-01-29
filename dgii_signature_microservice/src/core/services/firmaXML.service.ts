import * as fs from 'fs';
import * as path from 'path';
import ECF, { P12Reader, ENVIRONMENT, Signature } from 'dgii-ecf';
import { P12ReaderData, CommercialApprovalEnum } from '../../utils/types/readerData.types';
import { crearArchivoXML, sleep } from '../../utils/functions';
const xmlFormatter = require('xml-formatter');
import Queue from 'queue';
import { TokenData } from '../../utils/types/token.types';

export class DgiiService {
  private static instance: DgiiService;
  private ecf!: ECF;
  private signature!: Signature;
  private authToken: TokenData | null = null;
  private isAuthenticating: boolean = false;
  private authQueue: { resolve: () => void; reject: (error: any) => void }[] = [];
  private queue: Queue;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiService {
    if (!DgiiService.instance) DgiiService.instance = new DgiiService();
    return DgiiService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 1, autostart: true });
    await this.loadCertificates();
    await this.authenticate();
  }

  private async loadCertificates() {
    try {
      const secret = 'VICVAS01';
      const reader = new P12Reader(secret);
      const certs = reader.getKeyFromFile(path.resolve(__dirname, '../firma-digital.p12'));

      this.ecf = new ECF(certs, ENVIRONMENT.CERT);
      this.signature = new Signature(certs.key, certs.cert);
    } catch (error) {
      console.error('Error cargando certificados:', error);
      throw new Error('No se pudieron cargar los certificados.');
    }
  }

  private async authenticate() {
    if (this.isAuthenticating) {
      return new Promise<void>((resolve, reject) => this.authQueue.push({ resolve, reject }));
    }

    this.isAuthenticating = true;

    try {
      this.authToken = await this.ecf.authenticate();
      this.authQueue.forEach(task => task.resolve());
      this.authQueue = [];
    } catch (error) {
      this.authQueue.forEach(task => task.reject(error));
      this.authQueue = [];

      console.error('Error en la autenticación:', error);
      throw new Error('Error autenticando con la DGII.');
    } finally {
      this.isAuthenticating = false;
    }
  }

  private isTokenExpired(): boolean {
    if (!this.authToken) return true;
    return new Date(this.authToken.expira) <= new Date();
  }

  private validateToken() {
    const tokenIsValid = this.authToken && typeof this.authToken.token === 'string' && typeof this.authToken.expira === 'string' && typeof this.authToken.expedido === 'string';

    return !this.authToken || !tokenIsValid || this.isTokenExpired();
  }

  public async firmarYEnviarXML(jsonData: any) {
    try {
      if (!this.validateToken()) {
        await this.authenticate();

        if (!this.validateToken()) {
          return { success: false, error: 'Error de autenticación. No se pudo obtener un token válido.' };
        }
      }

      const xml = '';

      const fileName = `${jsonData.RNCComprador}${jsonData.noEcf}.xml`;

      const signedXml = this.signature.signXml(xml, 'ACECF');
      const formattedXml = xmlFormatter(signedXml, {
        collapseContent: true,
        indentation: '  ',
        lineSeparator: '\n',
        prettyPrint: true,
      });

      const response = await this.ecf.sendCommercialApproval(signedXml, fileName);
      await sleep(2000);

      crearArchivoXML(formattedXml, path.resolve(__dirname, `./firmados/${fileName}`));

      return { success: true, response };
    } catch (error) {
      console.error(error);
      return { success: false, error: 'Error en el proceso de firma y envío.' };
    }
  }

  public async addToQueue(jsonData: any) {
    return new Promise(async (resolve, reject) => {
      try {
        this.queue.push(async () => {
          try {
            const result = await this.firmarYEnviarXML(jsonData);

            if (result.success) resolve(result);
            else reject(result);
          } catch (error) {
            reject({ success: false, error: error.message || 'Error procesando la solicitud.' });
          }
        });
      } catch (error) {
        reject({ success: false, error: error.message || 'Error al agregar a la cola.' });
      }
    });
  }
}
