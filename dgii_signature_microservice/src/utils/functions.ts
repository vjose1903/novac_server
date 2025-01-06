import * as fs from "fs";
import * as path from "path";

export function crearArchivoXML(content: string, fileName: string): void {
	fs.writeFile(fileName, content, (err) => {
		if (err) {
			console.error("Error al escribir el archivo:", err);
		} else {
			console.log(`El archivo ${fileName} ha sido creado exitosamente.`);
		}
	});
}

export function leerArchivo(ruta: string): string {
	return fs.readFileSync(ruta, "utf-8");
}

export function isEmpty(value: any): boolean {
	if (value === "" || value === null || value === undefined) {
		return true;
	}
	if (Array.isArray(value) && value.length === 0) {
		return true;
	}
	if (typeof value === "object" && Object.keys(value).length === 0) {
		return true;
	}
	return false;
}

export function sleep(time: number) {
	return new Promise<void>((resolve, reject) => {
		setTimeout(() => resolve(), time);
	});
}
