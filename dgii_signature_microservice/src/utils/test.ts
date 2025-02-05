import { DgiiService } from "../core/services/DgiiService.service"
import { sleep } from "./typescript/functions";
import { ParseDocument } from "./typescript/parseDocument";
import { factura_32 } from "./factura_32";

async function prueba() {
	const parser = new ParseDocument();
	const factura = parser.parse(factura_32);
	console.log("factura >> ", JSON.stringify(factura, null, 2));
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