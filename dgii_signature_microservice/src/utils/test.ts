import { DgiiEcfService } from '../core/services/DgiiEcf.service';
import { getProperty, sleep } from './typescript/functions';
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
import { num_codigo_modificacion_to_label } from '@core/constants/factura.const';
import { codigo_modificacion_labelE } from '@core/constants/factura.const';

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
  // const fecha_vencimiento_certificacion = DateUtils.addDays(30);
  // const fecha = DateUtils.format({ date: fecha_vencimiento_certificacion, dateFormat: 'DD-MM-YYYY' });
  // console.log('fecha >> ', fecha);
  const data = {test: '3'};
  const codigo_modificacion = getProperty(data, 'test');
  if (codigo_modificacion) data['razon'] = codigo_modificacion_labelE[num_codigo_modificacion_to_label[`_${codigo_modificacion}`]];

  console.log('data >> ', data);
  
  // const authService = DgiiAuthService.getInstance();
  // await authService.testAuthentication();

  // authService.testAuthentication();

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
