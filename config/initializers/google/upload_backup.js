const path = require('path');
const GoogleDriveUtils = require('./google.drive.utils');

const args = process.argv.slice(2);
const fileName = args[0];
const folderId = args[1];

const rootDir = path.resolve(__dirname, '..', '..', '..');
const backupPath = `${rootDir}/db/${fileName}`;

async function uploadBackup() {
	try {
		const googleDrive = new GoogleDriveUtils();
		await googleDrive.authorize();

		let previousBackupId = await googleDrive.checkFileExistence(folderId, fileName);
		previousBackupId = previousBackupId.shift();

		if (previousBackupId) {
			console.log("\n************************************************************");
			console.log("*         BACKUP EXISTE PROCEDIENDO A SOBREESCRIBIR        *");
			console.log("************************************************************\n");

			await googleDrive.replaceFile(folderId, backupPath, fileName, previousBackupId.id);
		} else {
			console.log("\n*********************************************************");
			console.log("*         BACKUP NO EXISTE PROCEDIENDO A GUARDAR        *");
			console.log("*********************************************************\n");

			await googleDrive.uploadFile(folderId, backupPath, fileName);
		}

		console.log("\n************************************************");
		console.log("*         BACKUP GUARDADO CORRECTAMENTE        *");
		console.log("************************************************\n");

	} catch (err) {
		console.log("\n****************************************************");
		console.log("*         ERROR SUBIENDO EL BACKUP AL DRIVE        *");
		console.log("****************************************************\n");

		console.error('\n', err, '\n');
		process.exitCode = 1;
	}
}

uploadBackup();
