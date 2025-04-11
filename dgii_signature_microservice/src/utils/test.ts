import { DgiiService } from "../core/services/DgiiService.service"
import { sleep } from "./typescript/functions";
import { ParseDocument } from "./typescript/parseDocument";
import { factura_32 } from "./factura_32";
import { DateUtils } from '@vjose1903/dateutils';

async function prueba() {
	console.log(DateUtils.diffDays(factura_32.fecha_equivalente, new Date()));
	console.log(DateUtils.format({ date: factura_32.fecha_equivalente, dateFormat: 'DD-MM-YYYY' }));
	// const parser = new ParseDocument();
	// const factura = parser.parse(factura_32);
	// console.log("factura >> ", JSON.stringify(factura, null, 2));
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

prueba()