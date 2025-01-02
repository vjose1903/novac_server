import * as fs from 'fs';
import * as path from 'path';
import { FirmaXMLService } from './core/services/firmaXML.service'; // Ajusta la ruta según tu estructura de proyecto

// Función para leer un archivo y devolver su contenido como un string
function leerArchivo(ruta: string): string {
	return fs.readFileSync(ruta, 'utf-8');
}

// Función principal para ejecutar la prueba
async function ejecutarPrueba() {
	console.log("------ EJECUTANDO PRUEBA ------");
	
	// Leer el archivo XML
	// const xml = leerArchivo(path.join(__dirname, 'utils/test.xml'));
	const xml = leerArchivo(path.join(__dirname, 'utils/ecf.xml'));
	
	// Leer el archivo de certificado
	const certificadoBuffer = fs.readFileSync(path.join(__dirname, 'utils/firma-digital.p12'));

	const password = 'VICVAS01'; // Reemplaza con la contraseña de tu certificado
	
	// Crear una instancia del servicio de firma
	const firmaService = new FirmaXMLService();
	
	// Firmar el XML
	const resultado = firmaService.Firmar(xml, certificadoBuffer, password);
	
	// Mostrar el resultado
	console.log('XML Firmado:', resultado.xmlFirmadoString);
	console.log("------ PRUEBA FINALIZADA ------");
}

// Ejecutar la prueba
ejecutarPrueba().catch(console.error);
