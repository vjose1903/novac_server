const path = require('path');
const fs = require('fs');

const { google} = require('googleapis');
const rootDir = path.resolve(__dirname, '..', '..', '..');
const apikeys = require(`${rootDir}/config/initializers/google/google_api_credentials.json`);
const SCOPE = ['https://www.googleapis.com/auth/drive'];

export default class GoogleDriveUtils {
	private autorizationClient: any = undefined;
	constructor() {
	}

	async authorize() {
		if (this.autorizationClient === undefined) {
			this.autorizationClient = new google.auth.JWT(apikeys.client_email, null, apikeys.private_key, SCOPE);
			if (this.autorizationClient) await this.autorizationClient.authorize();
		}
	}

	private getDriveInstance() {
		return google.drive({version: 'v3', auth: this.autorizationClient});
	}

	async checkFileExistence(folderId: string | Array<string>, fileName: string): Promise<Array<{ id: string }>> {
		return new Promise<Array<{ id: string }>>(async (resolve, rejected) => {
			try {
				const drive = this.getDriveInstance();
				const query = `parents = '${folderId}'`;
				// const query = `parents = '${folderId}' and name = '${fileName}'`;
				const response = await drive.files.list({ q: query, fields: 'files(id)' });
				resolve(response.data.files);
			} catch (err) {
				rejected(err);
			}
		});
	}

	uploadFile(folderId: string | Array<string>, filepath: string, fileName: string, mimeType= "application/sql") {
		return new Promise(async (resolve, rejected) => {

			console.log(" ")
			console.log("folderId ", folderId)
			console.log("filepath ", filepath)
			console.log("fileName ", fileName)
			console.log("mimeType ", mimeType)

			const drive = this.getDriveInstance();
			const fileMetaData = { name: `${fileName}`, parents: [folderId] }
			const media = { body: fs.createReadStream(filepath), mimeType: mimeType };

			drive.files.create({ resource: fileMetaData, media, fields: 'id' }, (error: any , file: any) => {
				if (error) rejected(error)
				else resolve(file);
			});

		});
	}

	async replaceFile(fileName: string, fileId: string, folderId: string | Array<string>) {
		return new Promise(async (resolve, rejected) => {

			const drive = this.getDriveInstance()
			const fileMetaData = { name: `${fileName}` }
			const media = { body: fs.createReadStream(`${rootDir}/db/${fileName}` ), mimeType: 'application/sql'};

			drive.files.update({ fileId, addParents: [folderId], resource: fileMetaData, media, fields: 'id' }, (error: any, file: any) => {
				if (error) rejected(error);
				else resolve(file);
			});

		});
	}


}