import * as path from 'path';
import ECF, { P12Reader, ENVIRONMENT, Signature, Transformer } from 'dgii-ecf';
import { isEmpty } from '../../utils/typescript/functions';
const xmlFormatter = require('xml-formatter');
import Queue from 'queue';
import { TokenData } from '../types/token.types';

export class DgiiAuthService {
  public authToken: TokenData | null = null;
  public ecf!: ECF;
  public signature!: Signature;

  private static instance: DgiiAuthService;
  private environment: any;
  private isAuthenticating: boolean = false;
  private authQueue: { resolve: (result: { success: boolean; message?: string }) => void; reject: (error: any) => void }[] = [];
  private env: ENVIRONMENT;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiAuthService {
    if (!DgiiAuthService.instance) DgiiAuthService.instance = new DgiiAuthService();
    return DgiiAuthService.instance;
  }

  private async initialize() {
    this.environment = process.env;
    this.env = this.environment.ENV;

    await this.loadCertificates();
  }

  private async loadCertificates() {
    try {
      const secret = 'VICVAS01';
      const reader = new P12Reader(secret);
      const certs = reader.getKeyFromFile(path.resolve(__dirname, '../../utils/firma-digital.p12'));

      this.ecf = new ECF(certs, this.env);
      this.signature = new Signature(certs.key, certs.cert);
    } catch (error) {
      console.error('Error cargando certificados:', error);
      throw new Error('No se pudieron cargar los certificados.');
    }
  }

  private async authenticate() {
    return new Promise<{ success: boolean; message?: string }>((resolvePrincipal, rejectPrincipal) => {
      console.log(' ----- authenticate ----- ');

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

    console.log('new Date(this.authToken.expira).getTime()', new Date(this.authToken.expira).getTime());
    console.log('new Date().getTime()', new Date().getTime());
    console.log('new Date(this.authToken.expira).getTime() <= new Date().getTime()', new Date(this.authToken.expira).getTime() <= new Date().getTime());

    return new Date(this.authToken.expira).getTime() <= new Date().getTime();
  }

  private tokenIsInvalid() {
    if (isEmpty(this.authToken)) return true;

    const tokenIsValid = typeof this.authToken.token === 'string' && typeof this.authToken.expira === 'string' && typeof this.authToken.expedido === 'string';

    if (!tokenIsValid) return true;

    const expired = this.isTokenExpired();

    return expired;
  }

  public async validateTokenBeforeSend() {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      console.log(' ');
      console.log(' ');
      console.log('this.authToken ', this.authToken);
      console.log('tokenIsInvalid ', this.tokenIsInvalid());
      console.log(' ');
      console.log(' ');

      if (this.tokenIsInvalid()) {
        this.authenticate()
          .then(result => {
            if (this.tokenIsInvalid()) {
              reject({ success: false, message: 'Error de autenticación. No se pudo obtener un token válido.' });
            }
            resolve(result);
          })
          .catch(error => {
            reject(error);
          });
      } else {
        resolve({ success: true });
      }
    });
  }
}
