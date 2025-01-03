import * as fs from 'fs';
import * as path from 'path';
import { FirmaXMLService } from './core/services/firmaXML.service'; // Ajusta la ruta según tu estructura de proyecto
import ECF, { P12Reader, ENVIRONMENT  } from 'dgii-ecf';

// Función para leer un archivo y devolver su contenido como un string
function leerArchivo(ruta: string): string {
	return fs.readFileSync(ruta, 'utf-8');
}

// Función principal para ejecutar la prueba
async function getAuthToken() {
	console.log("------ EJECUTANDO PRUEBA ------");
	const secret = 'VICVAS01';


const reader = new P12Reader(secret);
const certs = reader.getKeyFromFile(
  path.resolve(__dirname, 'utils/firma-digital.p12')
);


const auth = new ECF(certs, ENVIRONMENT.DEV);
console.log("auth ", auth);
const tokenData = await auth.authenticate();

console.log("tokenData ", tokenData);

// console.log('XML Firmado:', resultado.xmlFirmadoString);
console.log("------ PRUEBA FINALIZADA ------");
return tokenData
}


async function getAutehToken() {
	console.log("------ EJECUTANDO PRUEBA ------");
	const secret = 'VICVAS01';


const reader = new P12Reader(secret);
const certs = reader.getKeyFromFile(
  path.resolve(__dirname, 'utils/firma-digital.p12')
);


const auth = new ECF(certs, ENVIRONMENT.DEV);
console.log("auth ", auth);
const tokenData = await auth.authenticate();

console.log("tokenData ", tokenData);


	// console.log('XML Firmado:', resultado.xmlFirmadoString);
	console.log("------ PRUEBA FINALIZADA ------");
}

// Ejecutar la prueba
getAuthToken().catch(console.error);
