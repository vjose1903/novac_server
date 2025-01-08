import * as XLSX from "xlsx";
import * as fs from "fs";
import * as path from "path";
import { Transformer } from "dgii-ecf";
import { crearArchivoXML, isEmpty } from "../functions";

interface JSONData {
	[key: string]: any;
}

function parseExcelToCustomJson(filePath: string): Promise<JSONData[]> {
	return new Promise((resolve, reject) => {
		try {
			// Verifica si el archivo existe
			if (!fs.existsSync(filePath)) {
				return reject(
					new Error(`El archivo no existe en la ruta: ${filePath}`)
				);
			}

			// Lee el archivo .xlsx
			const fileBuffer = fs.readFileSync(filePath);

			// Convierte el archivo a un workbook
			const workbook = XLSX.read(fileBuffer, { type: "buffer" });
			const sheetName = workbook.SheetNames[0]; // Obtén la primera hoja
			const sheet = workbook.Sheets[sheetName];

			// Convierte la hoja a JSON como matriz
			const rawJson: unknown[][] = XLSX.utils.sheet_to_json(sheet, {
				header: 1,
			});

			// Ignorar el primer encabezado y obtener los datos relevantes
			const headers = rawJson[0] as string[]; // Ignorar el primer header
			const rows = rawJson.slice(1); // Obtener todas las filas de datos
			// const rows = [rawJson[2]];

			const result: JSONData[] = [];

			// Procesar las filas
			rows.forEach((row) => {
				const template: JSONData = createTemplate(); // Crear una copia del template base

				console.log(" ");
				console.log(" ");
				console.log(" ");

				for (let colIndex = 0; colIndex < headers.length; colIndex++) {
					let header = headers[colIndex];
					let nextHeader = headers[colIndex + 1];

					if (!header) break;

					header = header.trim(); // Limpieza del encabezado
					nextHeader = nextHeader ? nextHeader.trim() : ""; // Limpieza del encabezado
					const value = row[colIndex]; // Ajusta el índice para ignorar la primera columna

					// Ignorar los campos con el valor "#e"
					if (value !== "#e" && value !== null && value !== undefined && value !== '')	 {
						mapeoResult(template, header, value, nextHeader); // Mapea el valor a la estructura del template
					}
				}

				result.push(template); // Agregar el template mapeado al arreglo
			});

			// Eliminar las propiedades y arreglos vacíos
			result.forEach(removeEmptyValues);

			resolve(result); // Resolver la promesa con el arreglo de templates mapeados
		} catch (error) {
			console.error("Error", error);
			reject(error);
		}
	});
}

function mapeoResult(template, header, value, nextHeader) {
	// InformacionReferencia
	if (header === "Version") {
		template.DetalleAprobacionComercial.Version = value;
	} else if (header === "RNCEmisor") {
		template.DetalleAprobacionComercial.RNCEmisor = value;
	} else if (header === "eNCF") {
		template.DetalleAprobacionComercial.eNCF = value;
	} else if (header === "FechaEmision") {
		template.DetalleAprobacionComercial.FechaEmision = value;
	} else if (header === "MontoTotal") {
		template.DetalleAprobacionComercial.MontoTotal = value;
	} else if (header === "RNCComprador") {
		template.DetalleAprobacionComercial.RNCComprador = value;
	} else if (header === "Estado") {
		template.DetalleAprobacionComercial.Estado = value;
	} else if (header === "DetalleMotivoRechazo") {
		template.DetalleAprobacionComercial.DetalleMotivoRechazo = value;
	} else if (header === "FechaHoraAprobacionComercial") {
		template.DetalleAprobacionComercial.FechaHoraAprobacionComercial = value;
	}
}

function createTemplate(): JSONData {
	return {
		DetalleAprobacionComercial: {
			Version: "",
			RNCEmisor: "",
			eNCF: "",
			FechaEmision: "",
			MontoTotal: "",
			RNCComprador: "",
			Estado: "",
			DetalleMotivoRechazo: "",
			FechaHoraAprobacionComercial: "",
		},
	};
}

function removeEmptyValues(obj: any) {
	if (Array.isArray(obj)) {
		// Si es un arreglo, recorrer cada elemento y limpiarlo
		obj.forEach((item, index) => {
			removeEmptyValues(item); // Recursión para cada item
			// Si el item es un objeto vacío, eliminarlo
			if (isEmpty(item)) {
				obj.splice(index, 1);
			}
		});
	} else if (typeof obj === "object" && obj !== null) {
		// Si es un objeto, recorrer sus propiedades
		Object.keys(obj).forEach((key) => {
			removeEmptyValues(obj[key]); // Recursión para cada propiedad
			// Si la propiedad está vacía, eliminarla
			if (isEmpty(obj[key])) {
				delete obj[key];
			}
		});
	}
}

// Ejemplo de uso
const filePath = path.join(__dirname, "datos.xlsx"); // Cambia esta ruta según tu directorio

parseExcelToCustomJson(filePath)
	.then((arrayConverted) => {
		arrayConverted.forEach((json, index) => {
			const RNCEmisor = json.DetalleAprobacionComercial.RNCComprador;
			const eNCF = json.DetalleAprobacionComercial.eNCF;

			const transformer = new Transformer();
			const xml = transformer.json2xml(json);

			const fileName = `${index + 1}_${RNCEmisor}${eNCF}.xml`;
			const filePath = path.join(__dirname, `sin_firmar/${fileName}`);

			crearArchivoXML(xml, filePath);
		});
	})
	.catch((error) => {
		console.error("Error al procesar el archivo:", error.message);
	});
