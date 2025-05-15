import { ENVIRONMENT } from 'dgii-ecf';
import GoogleDriveUtils from './typescript/google/google_drive.utils';
import path from 'path';
import * as fs from 'fs';

console.log(' ');
console.log(' ');
console.log(' ');
console.log(' ');
console.log('process.env.ENV', ENVIRONMENT[process.env.ENV as keyof typeof ENVIRONMENT]);
console.log(' ');
console.log(' ');
console.log(' ');
console.log(' ');

async function prueba() {
  const googleDrive = await GoogleDriveUtils.getInstance();
  const emmitedFolderId = process.env.EMITTED_FOLDER_ID;
  const receivedFolderId = process.env.RECEIVED_FOLDER_ID;
  
  const filePath = path.resolve(__dirname, 'paso-4', 'firmados', '131996035E310000000051.xml');
  const fileName = '131996035E310000000051.xml';
  
  // Validar que el archivo exista antes de intentar subirlo
  if (fs.existsSync(filePath)) {

    const fileContent = fs.readFileSync(filePath, 'utf-8');


    const res = await googleDrive.uploadFile(emmitedFolderId, fileContent, fileName);
    console.log('res', res);
  } else {
    console.error(`Error: El archivo no existe en la ruta ${filePath}`);
  }
}

prueba();
