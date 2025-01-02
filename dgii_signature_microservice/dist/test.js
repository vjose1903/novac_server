"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
// Función para leer un archivo y devolver su contenido como un string
function leerArchivo(ruta) {
    return fs.readFileSync(ruta, 'utf-8');
}
// Función principal para ejecutar la prueba
function ejecutarPrueba() {
    return __awaiter(this, void 0, void 0, function* () {
        console.log("ANDO AQUIII");
        console.log("path: ", path.join(__dirname, 'utils/test.xml'));
        // Leer el archivo XML
        // const xml = leerArchivo(path.join(__dirname, 'test.xml'));
        // // Leer el archivo de certificado
        // const certificadoBuffer = fs.readFileSync(path.join(__dirname, 'firma-digital.p12'));
        // const password = 'VICVAS01'; // Reemplaza con la contraseña de tu certificado
        // // Crear una instancia del servicio de firma
        // const firmaService = new FirmaXMLService();
        // // Firmar el XML
        // const resultado = firmaService.Firmar(xml, certificadoBuffer, password);
        // // Mostrar el resultado
        // console.log('XML Firmado:', resultado.xmlFirmadoString);
    });
}
// Ejecutar la prueba
ejecutarPrueba().catch(console.error);
