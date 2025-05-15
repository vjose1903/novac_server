import GoogleDriveUtils from '@utils/typescript/google/google_drive.utils';
import { validateXMLCertificate } from 'dgii-ecf';
import Queue from 'queue';

export class DgiiCommercialApprovalService {
  private static instance: DgiiCommercialApprovalService;
  private queue: Queue;
  private environment: any;
  private approve_received_folder: string;

  private googleDrive: GoogleDriveUtils;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): DgiiCommercialApprovalService {
    if (!DgiiCommercialApprovalService.instance) DgiiCommercialApprovalService.instance = new DgiiCommercialApprovalService();

    return DgiiCommercialApprovalService.instance;
  }

  private async initialize() {
    this.queue = new Queue({ concurrency: 5, autostart: true });
    this.environment = process.env;
    this.approve_received_folder = this.environment.APPROVE_RECEIVED_FOLDER_ID;

    this.googleDrive = await GoogleDriveUtils.getInstance();
  }

  public async validateApproval(data: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      try {
        const result = validateXMLCertificate(data.xml);

        await this.googleDrive.uploadFile(this.approve_received_folder, data.xml, data.fileName);

        resolve({ success: true, data: result, message: '' });
      } catch (error) {
        await this.googleDrive.uploadFile(this.approve_received_folder, data.xml, data.fileName);
        
        reject({ success: false, message: error.message || 'Error al validar el archivo XML.' });
      }
    });
  }

  public async addToQueue(data: any) {
    return new Promise<{ success: boolean; message?: any; data?: any }>(async (resolve, reject) => {
      try {
        this.queue.push(async () => {
          this.validateApproval(data)
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
