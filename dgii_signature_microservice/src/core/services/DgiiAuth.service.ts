import * as path from 'path';
import ECF, { P12Reader, ENVIRONMENT, Signature } from 'dgii-ecf';
import { hasValue, isEmpty } from '../../utils/typescript/functions';
import fs from 'fs';
import { TokenData } from '../types/token.types';

export class DgiiAuthService {
  public authToken: TokenData | null = null;

  private _ecf!: ECF;
  private _signature!: Signature;
  private static instance: DgiiAuthService;
  private environment: any;
  private isAuthenticating: boolean = false;
  private authQueue: { resolve: (result: { success: boolean; message?: string }) => void; reject: (error: any) => void }[] = [];
  private env: ENVIRONMENT;

  get ecf() {
    return this._ecf;
  }

  get signature() {
    return this._signature;
  }

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiAuthService {
    let isCreated = true;
    if (!DgiiAuthService.instance) {
      isCreated = false;
      console.log('\n\n------------------------ INICIALIZANDO INSTANCIA DE DGII AUTH SERVICE ------------------------\n\n');
      DgiiAuthService.instance = new DgiiAuthService();
      console.log('\n\n------------------------ INSTANCIA DE DGII AUTH SERVICE CREADA ------------------------\n\n');
    }
    
    if (isCreated) console.log('\n\n------------------------ INSTANCIA DE DGII AUTH SERVICE YA HA SIDO CREADA PREVIAMENTE ------------------------\n\n');
    return DgiiAuthService.instance;
  }

  private async initialize() {
    this.environment = process.env;
    this.env = ENVIRONMENT[this.environment.ENV as keyof typeof ENVIRONMENT];
    
    await this.loadCertificates();
  }

  private async loadCertificates() {
    try {
      const certPath = path.resolve(__dirname, '../../utils/firma-digital.p12');

      if (!fs.existsSync(certPath)) {
        throw new Error(`El archivo de certificado no existe en la ruta: ${certPath}`);
      }

      const reader = new P12Reader('VICVAS01');
      const certs = reader.getKeyFromFile(certPath);

      if (!this.env || typeof this.env !== 'string') {
        console.warn('Entorno no válido no se pudo cargar el entorno de la aplicación');
        throw new Error(`Entorno no válido no se pudo cargar el entorno de la aplicación`);
      }

      this._ecf = new ECF(certs, this.env);
      this._signature = new Signature(certs.key, certs.cert);
    } catch (error) {
      console.error('Error cargando certificados:', error);
      throw new Error(`No se pudieron cargar los certificados: ${error.message}`);
    }
  }

  public async testAuthentication() {
    try {
      console.log('HAY TOKEN PREVIO', hasValue(this.authToken));
      const result = await this.authenticate();
      console.log('Test de autenticación exitoso:', result);
      console.log('Token actual:', this.authToken);
      console.log(' ');
      console.log(' ');
      console.log(' ');

      return result;
    } catch (error) {
      console.error('Test de autenticación fallido:', error);
      throw error;
    }
  }

  private async authenticate() {
    return new Promise<{ success: boolean; message?: string }>((resolvePrincipal, rejectPrincipal) => {

      if (this.isAuthenticating) {
        this.authQueue.push({ resolve: resolvePrincipal, reject: rejectPrincipal });
        return;
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
          const result = {
            success: false,
            message: error?.message || 'Error de autenticación. Servicio de la DGII no disponible.',
          };
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

    console.log(' ');
    console.log(' ');
    console.log('--------------------------------------------------------------');
    console.log('                 DEPURACION DE TOKEN EXPIRADO                 ');
    console.log('--------------------------------------------------------------');
    console.log(' ');
    console.log('new Date(this.authToken.expira)', new Date(this.authToken.expira));
    console.log('new Date(this.authToken.expira).getTime()', new Date(this.authToken.expira).getTime());
    console.log('');
    console.log('new Date()', new Date());
    console.log('new Date().getTime()', new Date().getTime());
    console.log('new Date(this.authToken.expira).getTime() <= new Date().getTime()', new Date(this.authToken.expira).getTime() <= new Date().getTime());
    console.log(' ');
    console.log('--------------------------------------------------------------');
    console.log(' ');
    console.log(' ');

    return new Date(this.authToken.expira).getTime() <= new Date().getTime();
  }

  private tokenIsInvalid() {
    if (isEmpty(this.authToken)) return true;

    const tokenIsValid = typeof this.authToken.token === 'string' && typeof this.authToken.expira === 'string' && typeof this.authToken.expedido === 'string';

    return !tokenIsValid || this.isTokenExpired();
  }

  public async validateToken() {
    if (!this.tokenIsInvalid()) return { success: true };

    console.log("============================================== NO EXISTE TOKEN O EXPIRO ==============================================");
    
    try {
      await this.authenticate();
      if (this.tokenIsInvalid()) {
        throw { success: false, message: 'Error de autenticación. No se pudo obtener un token válido.', secuenciaUtilizada: false };
      }
      return { success: true };
    } catch (error) {
      throw error;
    }
  }
}
