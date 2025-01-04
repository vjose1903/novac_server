import * as fs from 'fs';
import * as path from 'path';
import { FirmaXMLService } from './core/services/firmaXML.service'; // Ajusta la ruta según tu estructura de proyecto
import ECF, { P12Reader, ENVIRONMENT, Signature,  } from 'dgii-ecf';
import { P12ReaderData } from './utils/types/readerData.types';

// Función para leer un archivo y devolver su contenido como un string
function leerArchivo(ruta: string): string {
	return fs.readFileSync(ruta, 'utf-8');
}


async function getDgiiUtils(): Promise<{certs: P12ReaderData, ecf: ECF}> {
	const secret = 'VICVAS01';
	
	
	const reader = new P12Reader(secret);
	const certs = reader.getKeyFromFile(
		path.resolve(__dirname, 'utils/firma-digital.p12')
	);

	const ecf = new ECF(certs, ENVIRONMENT.DEV);

	
	return { certs, ecf }
}

async function getAuthToken() {
	console.log("------ EJECUTANDO PRUEBA ------");
	
	const { ecf } = await getDgiiUtils()
	
	const tokenData = await ecf.authenticate();
	
	console.log("tokenData ", tokenData);
	
	// console.log('XML Firmado:', resultado.xmlFirmadoString);
	console.log("------ PRUEBA FINALIZADA ------");
	return tokenData
}


async function firmarXML() {
	console.log("------ EJECUTANDO PRUEBA ------");

	const rnc = '131996035';
	const noEcf = 'E310000000001';

	const xmlPath = path.resolve(__dirname, 'utils/paso-2/131996035E310000000001.xml')
	const xml = leerArchivo(xmlPath);

	const { certs, ecf } = await getDgiiUtils()

	//Sign invoice
	const signature = new Signature(certs.key, certs.cert);
	// Optional If the input is JSON transform it to XML
	// const transformer = new Transformer();
	// const xml = transformer.json2xml(JsonECF31Invoice);
	//------------------------------------------------

	//Create the name convention RNCEmisor + eCF.xml
	const fileName = `${rnc}${noEcf}.xml`;
	//Add the signature to the XML targetting the main wrapper in this case `ECF` (credito fiscal) it can be | ECF | ARECF | ACECF | ANECF | RFCE
	const signedXml = signature.signXml(xml, 'ECF');
	console.log("signedXml ", signedXml);
	
	//SEND the document to the DGII
	const response = await ecf.sendElectronicDocument(signedXml, fileName); //Optional third parameter is buyerHost?:string to send the invoice to the buyer

	console.log("response ", response);

	
	console.log("------ PRUEBA FINALIZADA ------");
}

// Ejecutar la prueba
// getAuthToken().catch(console.error);
firmarXML().catch(console.error);
