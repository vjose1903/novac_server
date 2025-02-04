import { DgiiService } from "../core/services/DgiiService.service"
import { sleep } from "./typescript/functions";


async function prueba() {
	const dgiiService = DgiiService.getInstance();

	await sleep(1000);
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	
	dgiiService.addToQueue({ RNCComprador: "1234567890", noEcf: "1" }).then(result => {

		console.log("@@@@@ result ", result);

	}).catch(error => {

		console.log("@@@@@ 1 error ", error);
		
	});

}

prueba()