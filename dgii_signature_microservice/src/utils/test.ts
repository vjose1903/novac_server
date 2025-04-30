import { DgiiEcfService } from '../core/services/DgiiEcf.service';
import { sleep } from './typescript/functions';
import { ParseDocument } from './typescript/parseDocument';
import { factura_31 } from './factura_31';
import { DateUtils } from '@vjose1903/dateutils';
import { nota_credito } from './nota_cred';
import ECF, { ENVIRONMENT, getCurrentFormattedDateTime, P12Reader } from 'dgii-ecf';
import { ParseAnulacion } from './typescript/parseAnulacion';
import { DgiiAnulacionService } from '@core/services/DgiiAnulacion.service';
import path from 'path';
import { P12ReaderData } from '@core/types/readerData.types';
import { DgiiAuthService } from '@core/services/DgiiAuth.service';

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

  // const parser_factura = new ParseDocument(factura_31);
  // const factura = parser_factura.parse();
  // console.log('>>>> ', DateUtils.getLastDayOfYear({ format: 'DD-MM-YYYY' }));

  // const parser_nota = new ParseDocument(nota_credito);
  // const nota = parser_nota.parse();
  // console.log('factura >> ', JSON.stringify(factura, null, 2));
  // const dgiiService = DgiiService.getInstance();

  // await sleep(1000);
  // console.log(" ");
  // console.log(" ");
  // console.log(" ");
  // console.log(" ");

  // dgiiService.addToQueue({ RNCComprador: "1234567890", noEcf: "1" }).then(result => {

  // 	console.log("@@@@@ result ", result);

  // }).catch(error => {

  // 	console.log("@@@@@ 1 error ", error);

  // });
}

prueba();
