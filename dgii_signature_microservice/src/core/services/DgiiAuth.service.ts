import * as path from 'path';
import ECF, { P12Reader, ENVIRONMENT, Signature } from 'dgii-ecf';
import { hasValue, isEmpty } from '../../utils/typescript/functions';
import fs from 'fs';
import { TokenData } from '../types/token.types';
import { DateUtils } from '@vjose1903/dateutils';

export class DgiiAuthService {
  public authToken: TokenData | null = null;

  private _ecf!: ECF;
  private _signature!: Signature;
  private static instance: DgiiAuthService;
  private environment: any;
  private isAuthenticating: boolean = false;
  private authQueue: { resolve: (result: { success: boolean; message?: string }) => void; reject: (error: any) => void }[] = [];
  private env: ENVIRONMENT;
  private tokenRefreshIntervalId: NodeJS.Timeout | null = null;

  get ecf() {
    return this._ecf;
  }

  get signature() {
    return this._signature;
  }

  public static getInstance(): DgiiAuthService {
    let isCreated = true;
    if (!DgiiAuthService.instance) {
      isCreated = false;
      console.log('\n\n------------------------ INICIALIZANDO INSTANCIA DE DGII AUTH SERVICE ------------------------\n\n');
      DgiiAuthService.instance = new DgiiAuthService();
      DgiiAuthService.instance.startTokenRefreshInterval();
      console.log('\n\n------------------------ INSTANCIA DE DGII AUTH SERVICE CREADA ------------------------\n\n');
    }

    if (isCreated) console.log('\n\n------------------------ INSTANCIA DE DGII AUTH SERVICE YA HA SIDO CREADA PREVIAMENTE ------------------------\n\n');
    return DgiiAuthService.instance;
  }

  private constructor() {
    this.initialize();
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

  private startTokenRefreshInterval() {
    if (this.tokenRefreshIntervalId) {
      clearInterval(this.tokenRefreshIntervalId);
    }

    this.tokenRefreshIntervalId = setInterval(async () => {
      try {
        if (this.tokenExpiresInMinutes() < 5) {
          console.log('Token próximo a expirar, renovando...');
          await this.authenticate();
          console.log('Token renovado correctamente');
        }
      } catch (error) {
        console.error('Error al renovar el token automáticamente:', error);
      }
    }, 600000);

    console.log('Intervalo de renovación de token iniciado');
  }

  private tokenExpiresInMinutes(): number {
    if (!this.authToken?.expira) return 0;

    const expireTime = new Date(this.authToken.expira).getTime();
    const currentTime = new Date().getTime();
    return Math.max(0, (expireTime - currentTime) / (1000 * 60));
  }

  public async testAuthentication() {
    return new Promise<TokenData>((resolve, reject) => {
      console.log('HAY TOKEN PREVIO', hasValue(this.authToken));
      this.authenticate()
        .then(result => {
          const response = { ...this.authToken };
          const tokenLength = response.token.length;
          response.token = `${response.token.substring(0, 5)}******${response.token.substring(tokenLength - 5, tokenLength)}`;
          console.log(' ');

          resolve(response);
        })
        .catch(error => {
          console.error('Test de autenticación fallido:', error);
          reject(error);
        });
    });
  }

  private async authenticate() {
    return new Promise<{ success: boolean; message?: string }>((resolvePrincipal, rejectPrincipal) => {
      if (this.isAuthenticating) {
        this.authQueue.push({ resolve: resolvePrincipal, reject: rejectPrincipal });
        return;
      }

      this.isAuthenticating = true;

      // Implementar función de reintento
      const maxRetries = 3;
      const retryDelay = 2000; // 2 segundos
      let retryCount = 0;

      const attemptAuthentication = () => {
        this.ecf
          .authenticate()
          .then(authToken => {
            this.authToken = authToken;
            this.authToken.expira = DateUtils.format({ date: DateUtils.add(30, 'minutes'), dateFormat: 'YYYY-MM-DD', include_hour: true, hourFormat: 'HH:mm:ss', separator: ' ' });

            this.authQueue.forEach(task => task.resolve({ success: true }));
            this.authQueue = [];
            resolvePrincipal({ success: true });
          })
          .catch(error => {
            // Lógica de reintento
            if (retryCount < maxRetries) {
              console.log(`Intento de autenticación falló. Reintentando (${retryCount + 1}/${maxRetries})...`);
              retryCount++;
              setTimeout(attemptAuthentication, retryDelay);
              return;
            }

            // Si se han agotado los reintentos, se rechaza la promesa
            const result = {
              success: false,
              message: error?.message || 'Error de autenticación. Servicio de la DGII no disponible después de varios intentos.',
              rollback: true,
            };

            this.authQueue.forEach(task => task.reject(result));
            this.authQueue = [];
            rejectPrincipal(result);
          })
          .finally(() => {
            if (retryCount >= maxRetries || this.authToken) {
              this.isAuthenticating = false;
            }
          });
      };

      // Iniciar el proceso de autenticación con reintentos
      attemptAuthentication();
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

    console.log('============================================== NO EXISTE TOKEN O EXPIRO ==============================================');

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

  public shutdown(): void {
    if (this.tokenRefreshIntervalId) {
      clearInterval(this.tokenRefreshIntervalId);
      this.tokenRefreshIntervalId = null;
    }
    this.authToken = null;
    DgiiAuthService.instance = null;
    console.log('DgiiAuthService ha sido desmontado correctamente');
  }
}
