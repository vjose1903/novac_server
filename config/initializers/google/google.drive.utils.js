const path = require("path");
const fs = require("fs");
const mime = require("mime-types");
const { google } = require("googleapis");

const rootDir = path.resolve(__dirname, "..", "..", "..");
const apikeys = require(`${rootDir}/config/initializers/google/google_api_credentials.json`);
const SCOPE = ["https://www.googleapis.com/auth/drive"];

class GoogleDriveUtils {
	authorizationClient = undefined;
	drive = undefined;

	constructor() {}

	async authorize() {
		if (!this.authorizationClient) {
			this.authorizationClient = new google.auth.JWT({
				email: apikeys.client_email,
				key: apikeys.private_key,
				scopes: SCOPE,
			});

			await this.authorizationClient.authorize();
			this.drive = google.drive({ version: "v3", auth: this.authorizationClient });
		}
	}

	getDriveInstance() {
		if (!this.drive) {
			throw new Error("Drive no inicializado. Debe autorizar primero.");
		}
		return this.drive;
	}

	async checkFileExistence(folderId, fileName) {
		try {
			const drive = this.getDriveInstance();
			const query = `parents = '${folderId}' and name = '${fileName}'`;
			const response = await drive.files.list({ q: query, fields: "files(id)" });
			return response.data.files || [];
		} catch (err) {
			throw err;
		}
	}

	createFileMedia(filePath) {
		const fileStream = fs.createReadStream(filePath);
		const mimeType = mime.lookup(filePath) || "application/sql";

		return { body: fileStream, mimeType };
	}

	async uploadFile(folderId, filePath, fileName) {
		try {
			// Verificar que el archivo exista
			if (!fs.existsSync(filePath)) {
				throw new Error(`El archivo ${filePath} no existe`);
			} else {
				const drive = this.getDriveInstance();
				const fileMetaData = { name: fileName, parents: [folderId] };
				const media = await this.createFileMedia(filePath);

				return new Promise((resolve, reject) => {
					drive.files.create( { requestBody: fileMetaData, media, fields: "id", }, (error, file) => {
							if (error) reject(error);
							else resolve(file.data);
						}
					);
				});
			}
		} catch (error) {
			throw error;
		}
	}

	async replaceFile(folderId, filePath, fileName, fileId) {
		try {
			// Verificar que el archivo exista
			if (!fs.existsSync(filePath)) {
				throw new Error(`El archivo ${filePath} no existe`);
			} else {
				const drive = this.getDriveInstance();
				const fileMetaData = { name: fileName };
				const media = await this.createFileMedia(filePath);

				return new Promise((resolve, reject) => {
					drive.files.update( { fileId, addParents: [folderId], requestBody: fileMetaData, media, fields: "id", }, (error, file) => {
							if (error) reject(error);
							else resolve(file.data);
						}
					);
				});
			}
		} catch (error) {
			throw error;
		}
	}
}

module.exports = GoogleDriveUtils;
