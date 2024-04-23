import * as path from "path";
import * as fs from "fs";

const rootDir = path.resolve(__dirname, '..', '..', '..');
import GoogleDriveUtils from "./google.drive.utils";

const args = process.argv.slice(2);

if (args.length < 2) {
	console.error('Se requieren al menos dos argumentos');
	process.exit(1);
}

const fileName = args[0];
const folderId = args[1];

async function uploadBackup() {
	const googleDrive = new GoogleDriveUtils();
	await googleDrive.authorize();


	// const previousBackupId = await googleDrive.checkFileExistence('12yOuHzoKqTUxJopJlItqexSgAzzfFu8L', fileName);
	// console.log("previousBackupId ", previousBackupId)

	await googleDrive.uploadFile(folderId, `${rootDir}/config/initializers/google/${fileName}`, fileName, 'text/plain')
	//
	// googleDrive.uploadFile(folderId, fileName, `${rootDir}/db/${fileName}`)

}

function successUpload() {
	console.log("\n************************************************");
	console.log("*         BACKUP GUARDADO CORRECTAMENTE        *");
	console.log("************************************************\n");
}

function errorUpload() {
	console.log("\n****************************************************");
	console.log("*         ERROR SUBIENDO EL BACKUP AL DRIVE        *");
	console.log("****************************************************\n");
}

uploadBackup()

// node config/initializers/google/upload_backup.js test.txt 1RzMbNCVAhqkNzH0mTO8f27-kfq1oum6a