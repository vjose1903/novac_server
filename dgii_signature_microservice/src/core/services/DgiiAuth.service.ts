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

      const reader = new P12Reader(this.environment.SIGNATURE_PSW);
      const certs = reader.getKeyFromFile(certPath);

      if (!this.env || typeof this.env !== 'string') {
        console.warn('Entorno no vรกlido no se pudo cargar el entorno de la aplicaciรณn');
        throw new Error(`Entorno no vรกlido no se pudo cargar el entorno de la aplicaciรณn`);
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

    // Verificar cada 2 minutos (120000ms) en lugar de 10 minutos
    // Esto asegura que el token se renueve antes de expirar incluso tras inactividad
    this.tokenRefreshIntervalId = setInterval(async () => {
      try {
        const minutesRemaining = this.tokenExpiresInMinutes();
        
        // Renovar si expira en menos de 10 minutos o si el token es invรกlido
        if (this.tokenIsInvalid() || minutesRemaining < 10) {
          console.log(`Token requiere renovaciรณn (minutos restantes: ${minutesRemaining.toFixed(1)})`);
          await this.authenticate();
          console.log('Token renovado correctamente por intervalo automรกtico');
        }
      } catch (error) {
        console.error('Error al renovar el token automรกticamente:', error);
      }
    }, 120000); // 2 minutos

    console.log('Intervalo de renovaciรณn de token iniciado (cada 2 minutos)');
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
          console.error('Test de autenticaciรณn fallido:', error);
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

      // Implementar funciรณn de reintento
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
            // Lรณgica de reintento
            if (retryCount < maxRetries) {
              console.log(`Intento de autenticaciรณn fallรณ. Reintentando (${retryCount + 1}/${maxRetries})...`);
              retryCount++;
              setTimeout(attemptAuthentication, retryDelay);
              return;
            }

            // Si se han agotado los reintentos, se rechaza la promesa
            const result = {
              success: false,
              message: error?.message || 'Error de autenticaciรณn. Servicio de la DGII no disponible despuรฉs de varios intentos.',
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

      // Iniciar el proceso de autenticaciรณn con reintentos
      attemptAuthentication();
    });
  }

  private isTokenExpired(): boolean {
    if (isEmpty(this.authToken)) return true;
    return new Date(this.authToken.expira).getTime() <= Date.now();
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
        throw { success: false, message: 'Error de autenticaciรณn. No se pudo obtener un token vรกlido.', secuenciaUtilizada: false };
      }
      return { success: true };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Fuerza la renovaciรณn del token independientemente de su estado actual.
   * ร�til cuando se detectan errores de autenticaciรณn en operaciones.
   */
  public async forceTokenRenewal(): Promise<{ success: boolean; message?: string }> {
    console.log('============================================== FORZANDO RENOVACIร�N DE TOKEN ==============================================');
    
    // Invalidar el token actual
    this.authToken = null;
    
    try {
      await this.authenticate();
      if (this.tokenIsInvalid()) {
        throw { success: false, message: 'Error de autenticaciรณn. No se pudo obtener un token vรกlido tras renovaciรณn forzada.', secuenciaUtilizada: false };
      }
      console.log('Token renovado exitosamente');
      return { success: true };
    } catch (error) {
      console.error('Error al forzar renovaciรณn del token:', error);
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
