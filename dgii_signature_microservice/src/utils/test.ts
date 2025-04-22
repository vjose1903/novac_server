import { DgiiService } from '../core/services/DgiiService.service';
import { sleep } from './typescript/functions';
import { ParseDocument } from './typescript/parseDocument';
import { factura_31 } from './factura_31';
import { DateUtils } from '@vjose1903/dateutils';
import { nota_credito } from './nota_cred';


console.log(' ');
console.log(' ');
console.log(' ');
console.log(' ');
console.log('process.env.ENVIRONMENT', process.env.ENVIRONMENT);
console.log(' ');
console.log(' ');
console.log(' ');
console.log(' ');

async function prueba() {
  const parser = new ParseDocument();
  // const factura = parser.parse(factura_31);
  const factura = parser.parse(nota_credito);
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
