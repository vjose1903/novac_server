import * as path from 'path';
import * as fs from 'fs';
import * as mime from 'mime-types';
import { google, drive_v3 } from 'googleapis';
import * as os from 'os';
import { ENVIRONMENT } from 'dgii-ecf';
import Queue from 'queue';

const rootDir = path.resolve(__dirname, '..', '..');
const apikeys = require(`${rootDir}/google_api_credentials.json`);
const SCOPE = ['https://www.googleapis.com/auth/drive'];

interface DriveFile {
  id: string;
}

class GoogleDriveUtils {
  private authorizationClient?: any;
  private drive?: drive_v3.Drive;
  private static instance: GoogleDriveUtils;
  private initialized: Promise<void>;
  private env: ENVIRONMENT;
  private uploadQueue: Queue;

  private constructor() {
    this.initialized = this.initialize();
    this.uploadQueue = new Queue({ concurrency: 1, autostart: true });
  }

  static async getInstance(): Promise<GoogleDriveUtils> {
    let isCreated = true;
    if (!GoogleDriveUtils.instance) {
      isCreated = false;
      console.log('\n\n------------------------ INICIALIZANDO INSTANCIA DE GOOGLE DRIVE UTILS ------------------------\n\n');
      GoogleDriveUtils.instance = new GoogleDriveUtils();
      await GoogleDriveUtils.instance.initialized;
      console.log('\n\n------------------------ INSTANCIA DE GOOGLE DRIVE UTILS CREADA ------------------------\n\n');
    }

    if (isCreated) console.log('\n\n------------------------ INSTANCIA DE GOOGLE DRIVE UTILS YA HA SIDO CREADA PREVIAMENTE ------------------------\n\n');
    return GoogleDriveUtils.instance;
  }

  private async initialize() {
    this.env = ENVIRONMENT[process.env.ENV as keyof typeof ENVIRONMENT];
    await this.authorize();
  }

  private async authorize(): Promise<void> {
    if (!this.authorizationClient) {
      this.authorizationClient = new google.auth.JWT({
        email: apikeys.client_email,
        key: apikeys.private_key,
        scopes: SCOPE,
      });

      await this.authorizationClient.authorize();
      this.drive = google.drive({ version: 'v3', auth: this.authorizationClient });
    }
  }

  private getDriveInstance(): drive_v3.Drive {
    if (!this.drive) {
      throw new Error('Drive no inicializado. El Singleton debería estar autorizado.');
    }
    return this.drive;
  }

  private async performUpload(folderId: string, fileContent: string, fileName: string): Promise<DriveFile> {
    const drive = this.getDriveInstance();
    const fileMetaData = { name: fileName, parents: [folderId] };
    const filePath = path.resolve(os.tmpdir(), fileName);

    try {
      console.log(`Procesando upload: ${fileName} (${this.uploadQueue.length} en cola)`);

      // Escribir el archivo en el directorio temporal del sistema
      await fs.promises.writeFile(filePath, fileContent);

      const mimeType = mime.lookup(filePath) || 'application/xml';
      const media = { body: fs.createReadStream(filePath), mimeType };

      // Usar promisify para convertir el callback a promesa
      const { data } = await drive.files.create({ requestBody: fileMetaData, media, fields: 'id' });

      console.log(' ');
      console.log('*****************************');
      console.log('*****************************');
      console.log('*****************************');
      console.log('ARCHIVO SUBIDO CORRECTAMENTE');
      console.log(`       ${fileName}`);
      console.log('*****************************');
      console.log('*****************************');
      console.log('*****************************');

      return data as DriveFile;
    } catch (error) {
      throw error;
    } finally {
      // Asegurar que el archivo temporal sea eliminado
      try {
        await fs.promises.unlink(filePath);
      } catch (err) {
        console.error(`Error al eliminar archivo temporal ${filePath}:`, err);
      }
    }
  }

  async uploadFile(folderId: string, fileContent: string, fileName: string): Promise<DriveFile> {
    return new Promise<DriveFile>((resolve, reject) => {
      this.uploadQueue.push(async () => {
        try {
          const result = await this.performUpload(folderId, fileContent, fileName);
          resolve(result);
        } catch (error) {
          console.error(`Error en upload de ${fileName}:`, error);
          reject(error);
        }
      });
    });
  }

  async checkFileExistence(folderId: string, fileName: string): Promise<any[]> {
    try {
      const drive = this.getDriveInstance();
      const query = `parents = '${folderId}' and name = '${fileName}'`;
      const response = await drive.files.list({ q: query, fields: 'files(id)' });
      return response.data.files || [];
    } catch (err) {
      throw err;
    }
  }
}

export default GoogleDriveUtils;
