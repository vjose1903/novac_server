import ECF, { ENVIRONMENT, Signature, Transformer, getCodeSixDigitfromSignature, generateFcQRCodeURL, convertECF32ToRFCE, generateEcfQRCodeURL } from 'dgii-ecf';
import { TrackStatusEnum, TrackingStatusResponse, InvoiceSummaryResponse, InvoiceResponse } from 'dgii-ecf/dist/networking/types';
import { getProperty, hasValue, isEmpty, retryUntil } from '../../utils/typescript/functions';
import Queue from 'queue';
import { ParseDocument } from '@utils/typescript/parseDocument';
import { FacturaI } from '@core/types/factura.types';
import { NotaI } from '@core/types/notas.types';
import { EcfXmlJson } from '@core/types/xml/xml_json';
import { codigo_modificacion_labelE, num_codigo_modificacion_to_label, tipoComprobanteE } from '@core/constants/factura.const';
import { rootElNameE } from '@core/constants/xml.const';
import { QrUrlDgiiData } from '@core/constants/dgii.const';
import { DgiiAuthService } from './DgiiAuth.service';
import GoogleDriveUtils from '@utils/typescript/google/google_drive.utils';

export class DgiiEcfService {
  private static instance: DgiiEcfService;
  private authService: DgiiAuthService;
  private googleDrive: GoogleDriveUtils;

  private ecf!: ECF;
  private signature!: Signature;
  private queue: Queue;
  private environment: any;
  private transformer: Transformer;
  private env: ENVIRONMENT;
  private emitted_folder: string;
  private acuse_recepcion_folder: string;
  private rnc_emisor: string;

  private jsonData: FacturaI | NotaI;

  private get isFCLessThan250K() {
    return this.jsonData.TipoeCF == tipoComprobanteE.factura_de_consumo && (this.jsonData as FacturaI).total_factura < 250000;
  }

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiEcfService {
    let isCreated = true;
    if (!DgiiEcfService.instance) {
      DgiiEcfService.instance = new DgiiEcfService();
      isCreated = false;
    }

    if (isCreated) console.log('\n\n------------------------ INSTANCIA DE DGII ECF SERVICE YA HA SIDO CREADA PREVIAMENTE ------------------------\n\n');
    return DgiiEcfService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 3, autostart: true });
    this.environment = process.env;
    this.emitted_folder = this.environment.EMITTED_FOLDER_ID;
    this.acuse_recepcion_folder = this.environment.ACUSE_RECEIVED_FOLDER_ID;
    this.rnc_emisor = this.environment.RNC_EMISOR;

    this.authService = DgiiAuthService.getInstance();
    await this.authService.validateToken();

    this.googleDrive = await GoogleDriveUtils.getInstance();

    this.transformer = new Transformer();

    this.ecf = this.authService.ecf;
    this.signature = this.authService.signature;

    this.env = ENVIRONMENT[this.environment.ENV as keyof typeof ENVIRONMENT];
  }

  public async firmarYEnviarXML() {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      try {
        await this.authService.validateToken();

        const { factura, parser } = this.convertToEcfXmlJson();
        const fileName = `${this.environment.RNC_EMISOR}${this.jsonData.numero_comprobante}.xml`;

        const qr_url_dgii_data = this.initializeQrData(factura, parser);
        const { signedXml, signedExtendedXml } = await this.signDocuments(factura, qr_url_dgii_data);

        console.log(" . ");
        console.log(" . ");
        console.log(" ANTES ");
        
        const sendResponse = await this.sendDocument(signedXml, fileName);
        console.log(" . ");
        console.log(" . ");
        console.log(" LUEGO ");
        console.log(" . ");
        console.log(" . ");
        const qr_url_dgii = this.generateQrUrl(qr_url_dgii_data, factura, parser);

        // Subir archivo extendido en background si es necesario
        this.uploadExtendedFileIfNeeded(fileName, signedExtendedXml);

        const response = await this.validateSendResponse(sendResponse);

        // Enviar al comprador si es necesario
        await this.sendToCustomerIfNeeded(parser, response, signedXml, fileName);

        // Subir archivo principal en background
        this.uploadMainFile(fileName, signedXml);

        const data = this.buildResponseData(factura, qr_url_dgii_data, fileName, qr_url_dgii, response);
        const message = this.getMessage(response);

        resolve({ success: true, data, message });
      } catch (error) {
        console.log(" ");
        console.log(" ");
        console.log(" ");
        console.log("error -----------> ", error);
        console.log(" ");
        console.log(" ");
        console.log(" ");
        
        const raw_msg = this.getMessage(error);
        const msg = hasValue(raw_msg) ? `DGII mensaje: ${raw_msg}` : 'Error al firmar y enviar el XML.';
        reject({ success: false, message: msg, secuenciaUtilizada: false, ...error });
      }
    });
  }

  private initializeQrData(factura: EcfXmlJson, parser: ParseDocument): QrUrlDgiiData {
    return {
      rncemisor: this.environment.RNC_EMISOR,
      encf: parser.eNCF,
      montototal: factura.ECF.Encabezado.Totales.MontoTotal,
      env: this.env,
    };
  }

  private async signDocuments(factura: EcfXmlJson, qr_url_dgii_data: QrUrlDgiiData): Promise<{ signedXml: string; signedExtendedXml: string }> {
    const xml = this.transformer.json2xml(factura);
    let signedXml = this.signature.signXml(xml, rootElNameE.ECF);
    qr_url_dgii_data.codigoseguridad = getCodeSixDigitfromSignature(signedXml);

    let signedExtendedXml = '';

    if (this.isFCLessThan250K) {
      const { xml: rfcXml } = convertECF32ToRFCE(signedXml);
      signedExtendedXml = signedXml;
      signedXml = this.signature.signXml(rfcXml, rootElNameE.RFCE);
    }

    return { signedXml, signedExtendedXml };
  }

  private async sendDocument(signedXml: string, fileName: string): Promise<any> {
    const maxRetries = 5;
    let retryCount = 0;
    const retryDelay = 1000; // 1 segundos entre reintentos

    const attemptSend = async (): Promise<any> => {
      try {
        if (this.isFCLessThan250K) {
          return await this.ecf.sendSummary(signedXml, fileName);
        } else {
          return await this.ecf.sendElectronicDocument(signedXml, fileName);
        }
      } catch (error) {
        // Verificar si es el error código 03 específico
        const isCode03Error = this.isCode03CertificateError(error);
        
        if (isCode03Error && retryCount < maxRetries) {
          retryCount++;
          console.log(`Error código 03 detectado. Reintentando envío (${retryCount}/${maxRetries})...`);
          
          // Esperar antes del siguiente intento
          await new Promise(resolve => setTimeout(resolve, retryDelay));
          
          // Reintentar
          return attemptSend();
        }
        
        // Si no es código 03 o ya agotamos los reintentos, lanzar el error
        throw error;
      }
    };

    return attemptSend();
  }

  private isCode03CertificateError(error: any): boolean {
    if (!error || !error.mensajes) return false;

    // Verificar si algún mensaje tiene el código '03' y el texto específico
    return error.mensajes.some((mensaje: any) => 
      mensaje.codigo === '03' && 
      mensaje.valor === 'El certificado utilizado no es válido, favor validar su composición y volver a intentarlo.'
    );
  }

  private generateQrUrl(qr_url_dgii_data: QrUrlDgiiData, factura: EcfXmlJson, parser: ParseDocument): string {
    if (this.isFCLessThan250K) {
      return generateFcQRCodeURL(qr_url_dgii_data.rncemisor, qr_url_dgii_data.encf, qr_url_dgii_data.montototal, qr_url_dgii_data.codigoseguridad, qr_url_dgii_data.env);
    } else {
      qr_url_dgii_data.rncComprador = factura.ECF.Encabezado?.Comprador?.RNCComprador || '';
      qr_url_dgii_data.fechaEmision = parser.fecha_emision;
      qr_url_dgii_data.fechaFirma = factura.ECF.FechaHoraFirma;

      return generateEcfQRCodeURL(
        qr_url_dgii_data.rncemisor,
        qr_url_dgii_data.rncComprador,
        qr_url_dgii_data.encf,
        qr_url_dgii_data.montototal.toString(),
        qr_url_dgii_data.fechaEmision,
        qr_url_dgii_data.fechaFirma,
        qr_url_dgii_data.codigoseguridad,
        qr_url_dgii_data.env
      );
    }
  }

  private uploadExtendedFileIfNeeded(fileName: string, signedExtendedXml: string): void {
    if (this.isFCLessThan250K && signedExtendedXml) {
      const fc_extendido_file_name = fileName.replace('.xml', '_ext.xml');
      setTimeout(() => {
        this.googleDrive.uploadFile(this.emitted_folder, signedExtendedXml, fc_extendido_file_name).catch(error => console.error('Error al subir archivo extendido:', error));
      }, 0);
    }
  }

  private async sendToCustomerIfNeeded(parser: ParseDocument, response: any, signedXml: string, fileName: string): Promise<void> {
    if (!parser.rnc_comprador || this.isFCLessThan250K || getProperty(response, 'estado') === TrackStatusEnum.REJECTED) return;

    try {
      const responseCustomerDirectory = await this.ecf.getCustomerDirectory(parser.rnc_comprador);

      if (responseCustomerDirectory.length > 0 && this.env === ENVIRONMENT.PROD) {
        const buyerHost = responseCustomerDirectory[0].urlRecepcion;

        if (buyerHost) {
          const acuseRecepcion = (await this.ecf.sendElectronicDocument(signedXml, fileName, buyerHost)) as string;
          const acuseFileName = fileName.replace(this.rnc_emisor, `${parser.rnc_comprador}`);

          setTimeout(() => {
            this.googleDrive.uploadFile(this.acuse_recepcion_folder, acuseRecepcion, acuseFileName).catch(error => console.error('Error al subir acuse de recepción:', error));
          }, 0);
        }
      }
    } catch (error) {
      console.error('Error al enviar documento al comprador:', error);
    }
  }

  private uploadMainFile(fileName: string, signedXml: string): void {
    setTimeout(() => {
      this.googleDrive.uploadFile(this.emitted_folder, signedXml, fileName).catch(error => console.error('Error al guardar el archivo XML:', error));
    }, 0);
  }

  private buildResponseData(factura: EcfXmlJson, qr_url_dgii_data: QrUrlDgiiData, fileName: string, qr_url_dgii: string, response: any): any {
    const data: any = {
      fecha_hora_firma: factura.ECF.FechaHoraFirma,
      security_code: qr_url_dgii_data.codigoseguridad,
      xml_file_name: fileName,
      secuenciaUtilizada: getProperty(response, 'secuenciaUtilizada') || false,
      qr_url_dgii,
      estado: 'estado' in response ? response?.estado : null,
      trackId: 'trackId' in response ? response?.trackId : null,
    };

    if (this.jsonData.TipoeCF === tipoComprobanteE.nota_de_credito || this.jsonData.TipoeCF === tipoComprobanteE.nota_de_debito) {
      const codigo_modificacion = getProperty(factura?.ECF?.InformacionReferencia, 'CodigoModificacion');
      if (codigo_modificacion) {
        data.razon = codigo_modificacion_labelE[num_codigo_modificacion_to_label[`_${codigo_modificacion}`]];
      }
    }

    return data;
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

  convertToEcfXmlJson(): { factura: EcfXmlJson; parser: ParseDocument } {
    const parser = new ParseDocument(this.jsonData);
    const factura: EcfXmlJson = parser.parse();
    return { factura, parser };
  }

  public async addToQueue(jsonData: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      try {
        this.queue.push(async () => {
          this.jsonData = jsonData;
          this.firmarYEnviarXML()
            .then(result => {
              if (result && result.success) resolve(result);
              else reject(result);
            })
            .catch(error => {
              error ??= {};
              error.success ??= false;
              error.message ??= 'Error procesando la solicitud.';
              error.secuenciaUtilizada ??= false;

              reject(error);
            });
        });
      } catch (error) {
        reject({ success: false, message: error.message || 'Error al agregar a la cola.', secuenciaUtilizada: false, rollback: true });
      }
    });
  }
}
