import * as fs from "fs";
import * as path from "path";
import ECF, { P12Reader, ENVIRONMENT, Signature } from "dgii-ecf";
import { P12ReaderData } from "../../core/types/readerData.types";
import { crearArchivoXML, leerArchivo, sleep } from "../typescript/functions";
import { TrackStatusEnum } from "dgii-ecf/dist/networking/types";
const xmlFormatter = require('xml-formatter');


// Función para leer un archivo y devolver su contenido como un string


async function getDgiiUtils(env: ENVIRONMENT = ENVIRONMENT.CERT): Promise<{ certs: P12ReaderData; ecf: ECF }> {
	const secret = "VICVAS01";

	const reader = new P12Reader(secret);
	const certs = reader.getKeyFromFile(
		path.resolve(__dirname, "../firma-digital.p12")
	);

	// const ecf = new ECF(certs, ENVIRONMENT.DEV);
	const ecf = new ECF(certs, env);

	return { certs, ecf };
}

async function getAuthToken(ecf: ECF) {
	const tokenData = await ecf.authenticate();
	// console.log("tokenData ", tokenData);
	return tokenData;
}

async function firmarXML(fileObj: { RNCEmisor: string; noEcf: string; file: string }, index: number) {
	try {
		const xmlPath = path.resolve( __dirname, `./sin_firmar/${fileObj.file}` );
		const xml = leerArchivo(xmlPath);

		const { certs, ecf } = await getDgiiUtils();

		await getAuthToken(ecf);

		//Sign invoice
		const signature = new Signature(certs.key, certs.cert);
		// Optional If the input is JSON transform it to XML
		// const transformer = new Transformer();
		// const xml = transformer.json2xml(JsonECF31Invoice);
		//------------------------------------------------

		//Create the name convention RNCEmisor + eCF.xml
		const fileName = `${fileObj.RNCEmisor}${fileObj.noEcf}.xml`;

		//Add the signature to the XML targetting the main wrapper in this case `ECF` (credito fiscal) it can be | ECF | ARECF | ACECF | ANECF | RFCE
		const signedXml = signature.signXml(xml, "ECF");

		//SEND the document to the DGII
		const response = await ecf.sendElectronicDocument(signedXml, fileName); //Optional third parameter is buyerHost?:string to send the invoice to the buyer
		await sleep(2000);
		const responseConsult = await ecf.statusTrackId(response.trackId);


		saveResponse(fileObj.file, {envio: response, consulta: responseConsult}, index)

		// Save the signedXml to a file
		const formattedXml = xmlFormatter(signedXml, { collapseContent: true, indentation: '  ', lineSeparator: '\n', prettyPrint: true, });
		crearArchivoXML(formattedXml, path.resolve( __dirname, `./firmados/${fileName}` ));

		return responseConsult.estado == TrackStatusEnum.ACCEPTED
	} catch (error) {
		console.error(error);
	}


}





function saveResponse(filename: string, response: any, index: number) {
	const resultsPath = path.resolve( __dirname, `./firmados/results.txt` );
	let results = leerArchivo(resultsPath);

	results += `\n\n(${index}): ${filename}\n${JSON.stringify(response, null, 2)}`;

	crearArchivoXML(results, resultsPath);
}

function getXMLS(): Promise< { RNCEmisor: string; noEcf: string; file: string }[] > {
	return new Promise((resolve, reject) => {
		const directoryPath = path.resolve(__dirname, "./sin_firmar/");
		const regex = /^\d+_(\d+)(E\d{12})\.xml$/;

		const result = [];

		fs.readdir(directoryPath, (err, files) => {
			if (err) {
				console.error("Error leyendo el directorio:", err);
				reject(err);
				return;
			}

			const sortedFiles = files.sort((a, b) =>
				a.localeCompare(b, undefined, { numeric: true })
		);

		sortedFiles.forEach((file) => {
			const match = file.match(regex);

			if (match) {
				const RNCEmisor = match[1];
				const noEcf = match[2];

				result.push({ RNCEmisor, noEcf, file });
			} else {
				console.log(`Archivo: ${file} no cumple con el patrón esperado.`);
			}
		});

		resolve(result);
	});
});
}

function paso2() {
	getXMLS()
	.then(async (files) => {
		for (let index = 0; index < files.length; index++) {
			const file = files[index];
			const isAccepted = await firmarXML(file, index + 1 )
			console.log("\n\nfile: ", file.file, ", ESTADO: ", isAccepted);

			if (!isAccepted) {
				break;
			}

		}

	})
	.catch(console.error);
}

// Ejecutar la prueba
// getAuthToken().catch(console.error);
paso2();


// testing()


// async function testing() {
// 	const { certs, ecf } = await getDgiiUtils();

// 	await getAuthToken(ecf);

// 	const responseConsult = await ecf.statusTrackId('455b6452-49b5-4909-8651-05a87de57ba2');
// 	console.log("responseConsult ", responseConsult);

// }


