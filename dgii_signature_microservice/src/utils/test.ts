import * as path from "path";

import ECF, { P12Reader, ENVIRONMENT, Signature } from "dgii-ecf";

async function prueba() {
	const secret = "VICVAS01";

	const reader = new P12Reader(secret);
	const certs = reader.getKeyFromFile(
		path.resolve(__dirname, "./firma-digital.p12")
	);

	// const ecf = new ECF(certs, ENVIRONMENT.DEV);
	const ecf = new ECF(certs, ENVIRONMENT.CERT);

	const tokenData = await ecf.authenticate();

	console.log(tokenData);

    console.log(new Date())
}

prueba()