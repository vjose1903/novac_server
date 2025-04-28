import * as fs from 'fs';
import * as path from 'path';
import ECF, { P12Reader, ENVIRONMENT, Signature, Transformer, getCodeSixDigitfromSignature, generateFcQRCodeURL } from 'dgii-ecf';
import { P12ReaderData, CommercialApprovalEnum } from '../types/readerData.types';
import { crearArchivoXML, isEmpty, sleep } from '../../utils/typescript/functions';
const xmlFormatter = require('xml-formatter');
import Queue from 'queue';
import { TokenData } from '../types/token.types';
import { ParseDocument } from '@utils/typescript/parseDocument';
import { FacturaI } from '@core/types/factura.types';
import { NotaI } from '@core/types/notas.types';
import { EcfXmlJson } from '@core/types/xml/xml_json';

export class DgiiService {
  private static instance: DgiiService;
  private ecf!: ECF;
  private signature!: Signature;
  private authToken: TokenData | null = null;
  private isAuthenticating: boolean = false;
  private authQueue: { resolve: (result: { success: boolean; message?: string }) => void; reject: (error: any) => void }[] = [];
  private queue: Queue;
  private environment: any;
  private transformer: Transformer;
  private env: ENVIRONMENT;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiService {
    if (!DgiiService.instance) DgiiService.instance = new DgiiService();
    return DgiiService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 3, autostart: true });
    this.environment = process.env;
    this.transformer = new Transformer();
    // this.env = ENVIRONMENT.CERT;
    this.env = ENVIRONMENT.DEV;

    await this.loadCertificates();
    // await this.authenticate();
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
    return new Date(this.authToken.expira) <= new Date();
  }

  private tokenIsInvalid() {
    if (isEmpty(this.authToken)) return true;

    const tokenIsValid = typeof this.authToken.token === 'string' && typeof this.authToken.expira === 'string' && typeof this.authToken.expedido === 'string';

    if (!tokenIsValid) return true;

    const expired = this.isTokenExpired();

    return expired;
  }

  private async validateTokenBeforeSend() {
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

  public async firmarYEnviarXML(jsonData: FacturaI | NotaI) {
    return new Promise<{ success: boolean; message?: any; data?: any }>((resolve, reject) => {
      this.validateTokenBeforeSend()
        .then(async () => {
          try {
            const parser = new ParseDocument(jsonData);

            const factura: EcfXmlJson = parser.parse();

            let fileName = `${this.environment.RNC_EMISOR}${jsonData.numero_comprobante}.xml`;
            // TODO: colocar en el servidor un key para identificar el tipo de documento
            // switch (jsonData.TipoeCF) {
            //     case :
            //         return this.parseFactura(document);
            //     default:
            //         throw new Error(`Tipo de documento no soportado: ${document.tipo}`);
            // }

            const xml = this.transformer.json2xml(factura);

            // console.log('xml ', xml);

            const signedXml = this.signature.signXml(xml, 'ECF');

            // -------------------------------------------------------
            const formattedXml = xmlFormatter(signedXml, {
              collapseContent: true,
              indentation: '  ',
              lineSeparator: '\n',
              prettyPrint: true,
            });
            // -------------------------------------------------------

            const response = await this.ecf.sendElectronicDocument(signedXml, fileName);
            console.log('response ', response);

            await sleep(2000);
            const responseConsult = await this.ecf.statusTrackId(response.trackId);

            if (parser.rnc_comprador) {
              const responseCustomerDirectory = await this.ecf.getCustomerDirectory(parser.rnc_comprador);
              console.log('responseCustomerDirectory ', responseCustomerDirectory);
            }

            console.log('responseConsult ', responseConsult);
            

            crearArchivoXML(formattedXml, path.resolve(__dirname, `../../utils/paso-4/firmados/${fileName}`));

            const securityCode = getCodeSixDigitfromSignature(signedXml);


            const qr_url_dgii_data = {
              rncemisor: this.environment.RNC_EMISOR,
              rncComprador: this.environment.RNC_EMISOR,
              encf:'',
              montototal: response.trackId,
              fechaEmision: response.trackId,
              fechaFirma: response.trackId,
              codigoseguridad: securityCode,
              env: this.env,
            }

            const data = {
              fecha_hora_firma: factura.ECF.FechaHoraFirma,
              trackId: response.trackId,
              security_code: securityCode,
              xml_file_name: fileName,
              // TODO: continuar aqui
              // qr_url_dgii: generateFcQRCodeURL(),
            }
            // return { success: true, response };
            resolve({ success: true, data: { token: this.authToken, info: data } });
          } catch (error) {
            reject(error);
          }
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
