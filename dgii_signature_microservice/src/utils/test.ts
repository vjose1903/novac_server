import { DgiiService } from "../core/services/DgiiService.service"
import { sleep } from "./functions";


async function prueba() {
	const dgiiService = DgiiService.getInstance();

	await sleep(1000);
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	console.log(" ");
	
	dgiiService.addToQueue({
		RNCComprador: "1234567890",
		noEcf: "1",
	});

	dgiiService.addToQueue({
		RNCComprador: "1234567890",
		noEcf: "2",
	});

	dgiiService.addToQueue({
		RNCComprador: "1234567890",
		noEcf: "3",
	});

	dgiiService.addToQueue({
		RNCComprador: "1234567890",
		noEcf: "4",
	});

	dgiiService.addToQueue({
		RNCComprador: "1234567890",
		noEcf: "5",
	});
}

prueba()