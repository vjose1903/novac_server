import * as fs from 'fs';
import * as path from 'path';
import ECF, { P12Reader, ENVIRONMENT, Signature, getCodeSixDigitfromSignature, generateEcfQRCodeURL, getCurrentFormattedDateTime } from 'dgii-ecf';
import { P12ReaderData } from '../../core/types/readerData.types';
import { guardarArchivoXML, leerArchivo, retryUntil, sleep } from '../typescript/functions';
import { InvoiceResponse, InvoiceSummaryResponse, TrackingStatusResponse, TrackStatusEnum } from 'dgii-ecf/dist/networking/types';
import { QrUrlDgiiData } from '@core/constants/dgii.const';
import { DateUtils } from '@vjose1903/dateutils';
const xmlFormatter = require('xml-formatter');
const { convertXML } = require('simple-xml-to-json');

// Función para leer un archivo y devolver su contenido como un string

async function getDgiiUtils(): Promise<{ certs: P12ReaderData; ecf: ECF }> {
  const environment = process.env;
  const env = ENVIRONMENT[environment.ENV as keyof typeof ENVIRONMENT];

  const secret = 'VICVAS01';

  const reader = new P12Reader(secret);
  const certs = reader.getKeyFromFile(path.resolve(__dirname, '../firma-digital.p12'));

  const ecf = new ECF(certs, env);

  return { certs, ecf };
}

async function getAuthToken(ecf: ECF) {
  const tokenData = await ecf.authenticate();
  // console.log("tokenData ", tokenData);
  return tokenData;
}

async function validateSendResponse(sendResponse: any, ecf: ECF) {
  return new Promise<TrackingStatusResponse>((resolve, reject) => {
    try {
      if (!('trackId' in sendResponse)) {
        resolve(sendResponse);
        return;
      }

      const taskGetStatus = () => ecf.statusTrackId(sendResponse.trackId);
      const reintentarSi = (response: TrackingStatusResponse) => response.estado === TrackStatusEnum.IN_PROCESS;
      const errorFunction = () => reject({ success: false, message: 'Error al obtener el estado de la factura.' });
      const returnResponse = (response: TrackingStatusResponse) => resolve(response);

      retryUntil(taskGetStatus, reintentarSi, returnResponse.bind(this), errorFunction);
    } catch (error) {
      reject({ success: false, message: error.message || 'Error al obtener el estado de la factura.' });
    }
  });
}

async function firmarXML(fileObj: { RNCEmisor: string; noEcf: string; file: string }, index: number) {
  try {
    const environment = process.env;
    const env = ENVIRONMENT[environment.ENV as keyof typeof ENVIRONMENT];

    const xmlPath = path.resolve(__dirname, `./tipos_fuera_sistema/${fileObj.file}`);
    let xml = leerArchivo(xmlPath);
    const fechaFirma = getCurrentFormattedDateTime();

    xml = xml.replace('<FechaHoraFirma></FechaHoraFirma>', `<FechaHoraFirma>${fechaFirma}</FechaHoraFirma>`);

    const { certs, ecf } = await getDgiiUtils();

    await getAuthToken(ecf);

    //Sign invoice
    const signature = new Signature(certs.key, certs.cert);

    //Create the name convention RNCEmisor + eCF.xml
    const fileName = `${fileObj.RNCEmisor}${fileObj.noEcf}.xml`;

    //Add the signature to the XML targetting the main wrapper in this case `ECF` (credito fiscal) it can be | ECF | ARECF | ACECF | ANECF | RFCE
    const signedXml = signature.signXml(xml, 'ECF');

    const myJson = convertXML(xml);

    // console.log('myJson ', JSON.stringify(myJson, null, 2));

    const montototal = obtenerMontoTotal(myJson);

    //SEND the document to the DGII
    const response = await ecf.sendElectronicDocument(signedXml, fileName); //Optional third parameter is buyerHost?:string to send the invoice to the buyer

    const responseConsult = await validateSendResponse(response, ecf);

    let qr_url_dgii_data: QrUrlDgiiData = { rncemisor: environment.RNC_EMISOR, encf: fileObj.noEcf, montototal: montototal, env: env };
    qr_url_dgii_data.codigoseguridad = getCodeSixDigitfromSignature(signedXml);

    qr_url_dgii_data.rncComprador = obtenerRNCComprador(myJson);
    qr_url_dgii_data.fechaEmision = DateUtils.format({ dateFormat: 'DD-MM-YYYY' });
    qr_url_dgii_data.fechaFirma = fechaFirma;

    const qr_url_dgii = generateEcfQRCodeURL(
      qr_url_dgii_data.rncemisor,
      qr_url_dgii_data.rncComprador,
      qr_url_dgii_data.encf,
      qr_url_dgii_data.montototal.toString(),
      qr_url_dgii_data.fechaEmision,
      qr_url_dgii_data.fechaFirma,
      qr_url_dgii_data.codigoseguridad,
      qr_url_dgii_data.env
    );

    saveResponse(fileObj.file, { envio: response, consulta: responseConsult, qr_url_dgii, qr_url_dgii_data }, index);

    // // Save the signedXml to a file
    const formattedXml = xmlFormatter(signedXml, { collapseContent: true, indentation: '  ', lineSeparator: '\n', prettyPrint: true });
    guardarArchivoXML(formattedXml, path.resolve(__dirname, `./tipos_fuera_sistema/firmados/${fileName}`));
    
    return responseConsult.estado == TrackStatusEnum.ACCEPTED
    
  } catch (error) {
    console.error(error);
  }
}

function obtenerMontoTotal(ecfData) {
  try {
    // Navegar a través del objeto para llegar a la sección Totales
    const totales = ecfData.ECF.children[0].Encabezado.children.find(item => Object.keys(item)[0] === 'Totales')?.Totales;
    // Buscar el elemento MontoTotal dentro de los children de Totales
    const montoTotalObj = totales.children.find(item => Object.keys(item)[0] === 'MontoTotal');

    // Extraer y retornar el contenido
    return montoTotalObj.MontoTotal.content;
  } catch (error) {
    return 'No se pudo obtener el monto total: ' + error.message;
  }
}

function obtenerRNCComprador(ecfData) {
  try {
    // Navegar a través del objeto para llegar a la sección Totales
    const comprador = ecfData.ECF.children[0].Encabezado.children.find(item => Object.keys(item)[0] === 'Comprador')?.Comprador;
    // Buscar el elemento MontoTotal dentro de los children de Totales
    const rncCompradorObj = comprador.children.find(item => Object.keys(item)[0] === 'RNCComprador');

    // Extraer y retornar el contenido
    return rncCompradorObj.RNCComprador.content;
  } catch (error) {
    return '';
  }
}

function saveResponse(filename: string, response: any, index: number) {
  const resultsPath = path.resolve(__dirname, `./tipos_fuera_sistema/firmados/results.txt`);
  let results = leerArchivo(resultsPath);

  results += `\n\n(${index}): ${filename}\n${JSON.stringify(response, null, 2)}`;

  guardarArchivoXML(results, resultsPath);
}

function getXMLS(): Promise<{ RNCEmisor: string; noEcf: string; file: string }[]> {
  return new Promise((resolve, reject) => {
    const directoryPath = path.resolve(__dirname, './tipos_fuera_sistema/');
    const regex = /^(\d+)(E\d{12})\.xml$/;

    const result = [];

    fs.readdir(directoryPath, (err, files) => {
      if (err) {
        console.error('Error leyendo el directorio:', err);
        reject(err);
        return;
      }

      const sortedFiles = files.sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));

      sortedFiles.forEach(file => {
        if (file != 'firmados') {
          console.log('file ', file);
            
          const match = file.match(regex);

          if (match) {
            const RNCEmisor = match[1];
            const noEcf = match[2];

            result.push({ RNCEmisor, noEcf, file });
          } else {
            console.log(`Archivo: ${file} no cumple con el patrón esperado.`);
          }
        }
      });

      resolve(result);
    });
  });
}

function paso4() {
  getXMLS()
    .then(async files => {
      for (let index = 0; index < files.length; index++) {
        const file = files[index];
        const isAccepted = await firmarXML(file, index + 1);
        console.log('\n\nfile: ', file.file, ', ESTADO: ', isAccepted);

        if (!isAccepted) {
          break;
        }
      }
    })
    .catch(console.error);
}

paso4();
