const path = require('path');
const fs = require('fs');
const mime = require('mime-types');
const { google } = require('googleapis');

const rootDir = path.resolve(__dirname, '..', '..', '..');
const apikeys = require(`${rootDir}/config/initializers/google/google_api_credentials.json`);
const SCOPE = ['https://www.googleapis.com/auth/drive'];

class GoogleDriveUtils {
	autorizationClient = undefined;
	constructor() {}

	async authorize() {
		if (this.autorizationClient === undefined) {
			this.autorizationClient = new google.auth.JWT(apikeys.client_email, null, apikeys.private_key, SCOPE);
			if (this.autorizationClient) await this.autorizationClient.authorize();
		}
	}

	getDriveInstance() {
		return google.drive({version: 'v3', auth: this.autorizationClient});
	}

	async checkFileExistence(folderId, fileName) {
		return new Promise(async (resolve, rejected) => {
			try {
				const drive = this.getDriveInstance();
				const query = `parents = '${folderId}' and name = '${fileName}'`;
				const response = await drive.files.list({ q: query, fields: 'files(id)' });
				resolve(response.data.files);
			} catch (err) {
				rejected(err);
			}
		});
	}

	createFileMedia(filePath) {
		return new Promise((resolve, reject) => {
			const fileStream = fs.createReadStream(filePath);
			const mimeType = mime.lookup(filePath) || "application/sql";

			resolve({ body: fileStream, mimeType: mimeType });
		});
	}

	uploadFile(folderId, filepath, fileName) {
		return new Promise(async (resolve, rejected) => {
			const drive = this.getDriveInstance();
			const fileMetaData = { name: `${fileName}`, parents: [folderId] };
			const media = await this.createFileMedia(filepath);

			drive.files.create({ resource: fileMetaData, media, fields: 'id' }, (error, file) => {
				if (error) rejected(error);
				else resolve(file);
			});
		});
	}

	async replaceFile(folderId, filepath, fileName, fileId) {
		return new Promise(async (resolve, rejected) => {
			const drive = this.getDriveInstance();
			const fileMetaData = { name: `${fileName}` };
			const media = await this.createFileMedia(filepath);

			drive.files.update({ fileId, addParents: [folderId], resource: fileMetaData, media, fields: 'id' }, (error, file) => {
				if (error) rejected(error);
				else resolve(file);
			});
		});
	}
}

module.exports = GoogleDriveUtils;