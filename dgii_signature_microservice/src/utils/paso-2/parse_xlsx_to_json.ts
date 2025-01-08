import * as XLSX from "xlsx";
import * as fs from "fs";
import * as path from "path";
import  { Transformer } from 'dgii-ecf';
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
			const rawJson: unknown[][] = XLSX.utils.sheet_to_json(sheet, { header: 1, });

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
					nextHeader = nextHeader ?  nextHeader.trim() : ''; // Limpieza del encabezado
					const value = row[colIndex]; // Ajusta el índice para ignorar la primera columna
					

					// Ignorar los campos con el valor "#e"
					if (value !== "#e") {
						mapeoResult(template, header, value,  nextHeader); // Mapea el valor a la estructura del template
					}

				}
				
				
				addFechaHoraFirma(template)
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

function addFechaHoraFirma(template) {
	const date = new Date();

	// Restar 2 horas
	date.setHours(date.getHours() - 2);

	// Formatear la fecha al formato deseado
	const day = String(date.getDate()).padStart(2, '0');
	const month = String(date.getMonth() + 1).padStart(2, '0'); // Los meses van de 0 a 11
	const year = date.getFullYear();
	const hours = String(date.getHours()).padStart(2, '0');
	const minutes = String(date.getMinutes()).padStart(2, '0');
	const seconds = String(date.getSeconds()).padStart(2, '0');

	const formattedDate = `${day}-${month}-${year} ${hours}:${minutes}:${seconds}`;

	// Asignar el valor formateado al objeto
	template.ECF.FechaHoraFirma = formattedDate;
}

function mapeoResult(template, header, value, nextHeader) {
	// Mapeo dinámico de datos según la estructura
	const headerMatch = header.match(/(.*?)\[(\d+)\](?:\[(\d+)\])?/);
//   console.log("\n header ", header, "| value ",  value);
	if (headerMatch) {
		
		let key = headerMatch[1].trim();
		const index1 = parseInt(headerMatch[2], 10) - 1; // Índices ajustados (base 1 -> base 0)
		const index2 = headerMatch[3] ? parseInt(headerMatch[3], 10) - 1 : null;

		const lowerCaseKey = key.toLowerCase();
		const lowerCaseNextHeader = nextHeader.toLowerCase();
		
		// Arreglos
		if (["FormaPago", "MontoPago"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) && !isEmpty(index1)) {
			if (isEmpty(template.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago[index1])) template.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago[index1] = {};
			
			template.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago[ index1 ][key] = value;

		} else if (key === "TelefonoEmisor" && !isEmpty(index1)) {
			template.ECF.Encabezado.Emisor.TablaTelefonoEmisor.TelefonoEmisor[ index1 ] = value;

		} else if (["TipoImpuesto", "TasaImpuestoAdicional", "MontoImpuestoSelectivoConsumoEspecifico", "MontoImpuestoSelectivoConsumoAdvalorem", "OtrosImpuestosAdicionales"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) && !isEmpty(index1) && isEmpty(index2)) {
			if (isEmpty(index2)) {
				if ( isEmpty(template.ECF.Encabezado.Totales) ) template.ECF.Encabezado.Totales = {}; 
				if ( isEmpty(template.ECF.Encabezado.Totales.ImpuestosAdicionales) ) template.ECF.Encabezado.Totales.ImpuestosAdicionales = {}; 
				if ( isEmpty(template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional) ) template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional = []; 
				if ( isEmpty(template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional[index1]) ) template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional[index1] = {}; 

				template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional[index1][key] = value
			} 
		} else if (["TipoImpuestoOtraMoneda", "TasaImpuestoAdicionalOtraMoneda", "MontoImpuestoSelectivoConsumoEspecificoOtraMoneda", "MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda", "OtrosImpuestosAdicionalesOtraMoneda"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) && !isEmpty(index1)) {
			if ( isEmpty(template.ECF.Encabezado.OtraMoneda) ) template.ECF.Encabezado.OtraMoneda = {}; 
			if ( isEmpty(template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda) ) template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda = {}; 
			if ( isEmpty(template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda) ) template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda = {}; 
			if ( isEmpty(template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda[index1]) ) template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda[index1] = {}; 

			template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda[index1][key] = value

		} else if (((lowerCaseKey == "NumeroLinea".toLowerCase()) && (lowerCaseNextHeader.includes('TipoCodigo'.toLowerCase()))) || ["TipoCodigo", "CodigoItem", "IndicadorFacturacion", "IndicadorAgenteRetencionoPercepcion", "MontoITBISRetenido", "MontoISRRetenido", "NombreItem", "IndicadorBienoServicio", "DescripcionItem", "CantidadItem", "UnidadMedida", "CantidadReferencia", "UnidadReferencia", "Subcantidad", "CodigoSubcantidad", "GradosAlcohol", "PrecioUnitarioReferencia", "FechaElaboracion", "FechaVencimientoItem", "PrecioUnitarioItem", "DescuentoMonto", "TipoSubDescuento", "SubDescuentoPorcentaje", "MontoSubDescuento", "RecargoMonto", "TipoSubRecargo", "SubRecargoPorcentaje", "MontoSubRecargo", "TipoImpuesto", "PrecioOtraMoneda", "DescuentoOtraMoneda", "RecargoOtraMoneda", "MontoItemOtraMoneda", "MontoItem",].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) && !isEmpty(index1) ) {

			if ( isEmpty(template.ECF.DetallesItems) ) template.ECF.DetallesItems = {}
			if ( isEmpty(template.ECF.DetallesItems.Item) ) template.ECF.DetallesItems.Item = []
			if ( isEmpty(template.ECF.DetallesItems.Item[index1]) ) template.ECF.DetallesItems.Item[index1] = {}
			
			if ( ["TipoCodigo", "CodigoItem"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) && !isEmpty(index2) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaCodigosItem) ) template.ECF.DetallesItems.Item[index1].TablaCodigosItem = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem) ) template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem = [];
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem[index2]) ) template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem[index2] = {};
				template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem[index2][key] = value;
			} else if ( ["IndicadorAgenteRetencionoPercepcion", "MontoITBISRetenido", "MontoISRRetenido"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].Retencion) ) template.ECF.DetallesItems.Item[index1].Retencion = {};
				template.ECF.DetallesItems.Item[index1].Retencion[key] = value;

			} else if ( ["Subcantidad", "CodigoSubcantidad"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey)  && !isEmpty(index2) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubcantidad) ) template.ECF.DetallesItems.Item[index1].TablaSubcantidad = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem) ) template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem = []
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem[index2]) ) template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem[index2] = {}
				template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem[index2][key] = value;

			} else if ( ["TipoSubDescuento", "SubDescuentoPorcentaje", "MontoSubDescuento"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey)  && !isEmpty(index2) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubDescuento) ) template.ECF.DetallesItems.Item[index1].TablaSubDescuento = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento) ) template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento = []
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento[index2]) ) template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento[index2] = {}
				template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento[index2][key] = value;

			} else if ( ["TipoSubRecargo", "SubRecargoPorcentaje", "MontoSubRecargo"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey)  && !isEmpty(index2) ) {
				if (lowerCaseKey == "montosubrecargo") key = "MontoSubRecargo"
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubRecargo) ) template.ECF.DetallesItems.Item[index1].TablaSubRecargo = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo) ) template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo = []
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[index2]) ) template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[index2] = {}
				template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[index2][key] = value;

			} else if ( ["TipoImpuesto"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) && !isEmpty(index2) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional) ) template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional) ) template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional = []
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional[index2]) ) template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional[index2] = {}
				template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional[index2][key] = value;

			} else if ( ["PrecioOtraMoneda", "DescuentoOtraMoneda", "RecargoOtraMoneda", "MontoItemOtraMoneda"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].OtraMonedaDetalle) ) template.ECF.DetallesItems.Item[index1].OtraMonedaDetalle = {};
				template.ECF.DetallesItems.Item[index1].OtraMonedaDetalle[key] = value;

			} else {
				template.ECF.DetallesItems.Item[index1][key] = value;
			}

		} else if ( (lowerCaseKey == "NumeroLinea".toLowerCase() && lowerCaseNextHeader.includes('TipoAjuste'.toLowerCase())) || ["TipoAjuste", "IndicadorNorma1007", "DescripcionDescuentooRecargo", "TipoValor", "ValorDescuentooRecargo", "MontoDescuentooRecargo", "MontoDescuentooRecargoOtraMoneda", "IndicadorFacturacionDescuentooRecargo",].map((item)=>(item.toLowerCase())).includes(lowerCaseKey)  && !isEmpty(index1)) {
			if ( !template.ECF.DescuentosORecargos ) template.ECF.DescuentosORecargos = {};
			if ( !template.ECF.DescuentosORecargos.DescuentoORecargo ) template.ECF.DescuentosORecargos.DescuentoORecargo = [];
			if ( !template.ECF.DescuentosORecargos.DescuentoORecargo[index1] ) template.ECF.DescuentosORecargos.DescuentoORecargo[index1] = {};

			template.ECF.DescuentosORecargos.DescuentoORecargo[index1][key] = value;

		} else if ( ["PaginaNo", "NoLineaDesde", "NoLineaHasta", "SubtotalMontoGravadoPagina", "SubtotalMontoGravado1Pagina", "SubtotalMontoGravado2Pagina", "SubtotalMontoGravado3Pagina", "SubtotalExentoPagina", "SubtotalItbisPagina", "SubtotalItbis1Pagina", "SubtotalItbis2Pagina", "SubtotalItbis3Pagina", "SubtotalImpuestoAdicionalPagina", "SubtotalImpuestoSelectivoConsumoEspecificoPagina", "SubtotalOtrosImpuesto", "MontoSubtotalPagina", "SubtotalMontoNoFacturablePagina"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey)  && !isEmpty(index1)) {
			if ( !template.ECF.Paginacion ) template.ECF.Paginacion = {};
			if ( !template.ECF.Paginacion.Pagina ) template.ECF.Paginacion.Pagina = [];
			if ( !template.ECF.Paginacion.Pagina[index1] ) template.ECF.Paginacion.Pagina[index1] = {};
			
			if (["SubtotalImpuestoSelectivoConsumoEspecificoPagina", "SubtotalOtrosImpuesto"].map((item)=>(item.toLowerCase())).includes(lowerCaseKey) ) {
				if ( !template.ECF.Paginacion.Pagina[index1].SubtotalImpuestoAdicional ) template.ECF.Paginacion.Pagina[index1].SubtotalImpuestoAdicional = {};
				template.ECF.Paginacion.Pagina[index1].SubtotalImpuestoAdicional[key] = value;	
			} else {
				template.ECF.Paginacion.Pagina[index1][key] = value;
			}
		} 

		// Asignaciones directas
	} else {

		// Encabezado
		if (header === "Version") {
			template.ECF.Encabezado.Version = '1.0';	
		}

		// IdDoc
		else if (header === "TipoeCF") {
			template.ECF.Encabezado.IdDoc.TipoeCF = value;
			
		} else if (header === "ENCF" || header === "eNCF") {
			template.ECF.Encabezado.IdDoc.eNCF = value;
			
		} else if (header === "FechaVencimientoSecuencia") {
			template.ECF.Encabezado.IdDoc.FechaVencimientoSecuencia = value;
			
		} else if (header === "IndicadorNotaCredito") {
			template.ECF.Encabezado.IdDoc.IndicadorNotaCredito = value;
			
		} else if (header === "IndicadorEnvioDiferido") {
			template.ECF.Encabezado.IdDoc.IndicadorEnvioDiferido = value;
			
		} else if (header === "IndicadorMontoGravado") {
			template.ECF.Encabezado.IdDoc.IndicadorMontoGravado = value;
			
		} else if (header === "TipoIngresos") {
			template.ECF.Encabezado.IdDoc.TipoIngresos = value;
			
		} else if (header === "TipoPago") {
			template.ECF.Encabezado.IdDoc.TipoPago = value;
			
		} else if (header === "FechaLimitePago") {
			template.ECF.Encabezado.IdDoc.FechaLimitePago = value;
			
		} else if (header === "TerminoPago") {
			template.ECF.Encabezado.IdDoc.TerminoPago = value;
			
		} else if (header === "TipoCuentaPago") {
			template.ECF.Encabezado.IdDoc.TipoCuentaPago = value;
			
		} else if (header === "NumeroCuentaPago") {
			template.ECF.Encabezado.IdDoc.NumeroCuentaPago = value;
			
		} else if (header === "BancoPago") {
			template.ECF.Encabezado.IdDoc.BancoPago = value;
			
		} else if (header === "FechaDesde") {
			template.ECF.Encabezado.IdDoc.FechaDesde = value;
			
		} else if (header === "FechaHasta") {
			template.ECF.Encabezado.IdDoc.FechaHasta = value;
			
		} else if (header === "TotalPaginas") {
			template.ECF.Encabezado.IdDoc.TotalPaginas = value;
			
		}

		// Emisor
		else if (header === "RNCEmisor") {
			template.ECF.Encabezado.Emisor.RNCEmisor = value;
			
		} else if (header === "RazonSocialEmisor") {
			template.ECF.Encabezado.Emisor.RazonSocialEmisor = value;
			
		} else if (header === "NombreComercial") {
			template.ECF.Encabezado.Emisor.NombreComercial = value;
			
		} else if (header === "Sucursal") {
			template.ECF.Encabezado.Emisor.Sucursal = value;
			
		} else if (header === "DireccionEmisor") {
			template.ECF.Encabezado.Emisor.DireccionEmisor = value;
			
		} else if (header === "Municipio") {
			template.ECF.Encabezado.Emisor.Municipio = value;
			
		} else if (header === "Provincia") {
			template.ECF.Encabezado.Emisor.Provincia = value;
			
		} else if (header === "CorreoEmisor") {
			template.ECF.Encabezado.Emisor.CorreoEmisor = value;
			
		} else if (header === "WebSite") {
			template.ECF.Encabezado.Emisor.WebSite = value;
			
		} else if (header === "ActividadEconomica") {
			template.ECF.Encabezado.Emisor.ActividadEconomica = value;
			
		} else if (header === "CodigoVendedor") {
			template.ECF.Encabezado.Emisor.CodigoVendedor = value;
			
		} else if (header === "NumeroFacturaInterna") {
			template.ECF.Encabezado.Emisor.NumeroFacturaInterna = value;
			
		} else if (header === "NumeroPedidoInterno") {
			template.ECF.Encabezado.Emisor.NumeroPedidoInterno = value;
			
		} else if (header === "ZonaVenta") {
			template.ECF.Encabezado.Emisor.ZonaVenta = value;
			
		} else if (header === "RutaVenta") {
			template.ECF.Encabezado.Emisor.RutaVenta = value;
			
		} else if (header === "InformacionAdicionalEmisor") {
			template.ECF.Encabezado.Emisor.InformacionAdicionalEmisor = value;
			
		} else if (header === "FechaEmision") {
			template.ECF.Encabezado.Emisor.FechaEmision = value;
			
		}

		// Comprador
		else if (header === "RNCComprador") {
			template.ECF.Encabezado.Comprador.RNCComprador = value;
			
		} else if (header === "IdentificadorExtranjero") {
			template.ECF.Encabezado.Comprador.IdentificadorExtranjero = value;
			
		} else if (header === "RazonSocialComprador") {
			template.ECF.Encabezado.Comprador.RazonSocialComprador = value;
			
		} else if (header === "ContactoComprador") {
			template.ECF.Encabezado.Comprador.ContactoComprador = value;
			
		} else if (header === "CorreoComprador") {
			template.ECF.Encabezado.Comprador.CorreoComprador = value;
			
		} else if (header === "DireccionComprador") {
			template.ECF.Encabezado.Comprador.DireccionComprador = value;
			
		} else if (header === "MunicipioComprador") {
			template.ECF.Encabezado.Comprador.MunicipioComprador = value;
			
		} else if (header === "ProvinciaComprador") {
			template.ECF.Encabezado.Comprador.ProvinciaComprador = value;
			
		} else if (header === "FechaEntrega") {
			template.ECF.Encabezado.Comprador.FechaEntrega = value;
			
		} else if (header === "ContactoEntrega") {
			template.ECF.Encabezado.Comprador.ContactoEntrega = value;
			
		} else if (header === "DireccionEntrega") {
			template.ECF.Encabezado.Comprador.DireccionEntrega = value;
			
		} else if (header === "TelefonoAdicional") {
			template.ECF.Encabezado.Comprador.TelefonoAdicional = value;
			
		} else if (header === "FechaOrdenCompra") {
			template.ECF.Encabezado.Comprador.FechaOrdenCompra = value;
			
		} else if (header === "NumeroOrdenCompra") {
			template.ECF.Encabezado.Comprador.NumeroOrdenCompra = value;
			
		} else if (header === "CodigoInternoComprador") {
			template.ECF.Encabezado.Comprador.CodigoInternoComprador = value;
			
		} else if (header === "ResponsablePago") {
			template.ECF.Encabezado.Comprador.ResponsablePago = value;
			
		} else if (header === "InformacionAdicionalComprador") {
			template.ECF.Encabezado.Comprador.InformacionAdicionalComprador = value;
			
		} 

		// InformacionesAdicionales
		else if (header === "FechaEmbarque") {
			template.ECF.Encabezado.InformacionesAdicionales.FechaEmbarque = value;
			
		} else if (header === "NumeroEmbarque") {
			template.ECF.Encabezado.InformacionesAdicionales.NumeroEmbarque = value;
			
		} else if (header === "NumeroContenedor") {
			template.ECF.Encabezado.InformacionesAdicionales.NumeroContenedor = value;
			
		} else if (header === "NumeroReferencia") {
			template.ECF.Encabezado.InformacionesAdicionales.NumeroReferencia = value;
			
		} else if (header === "PesoBruto") {
			template.ECF.Encabezado.InformacionesAdicionales.PesoBruto = value;
			
		} else if (header === "PesoNeto") {
			template.ECF.Encabezado.InformacionesAdicionales.PesoNeto = value;
			
		} else if (header === "UnidadPesoBruto") {
			template.ECF.Encabezado.InformacionesAdicionales.UnidadPesoBruto = value;
			
		} else if (header === "UnidadPesoNeto") {
			template.ECF.Encabezado.InformacionesAdicionales.UnidadPesoNeto = value;
			
		} else if (header === "CantidadBulto") {
			template.ECF.Encabezado.InformacionesAdicionales.CantidadBulto = value;
			
		} else if (header === "UnidadBulto") {
			template.ECF.Encabezado.InformacionesAdicionales.UnidadBulto = value;
			
		} else if (header === "VolumenBulto") {
			template.ECF.Encabezado.InformacionesAdicionales.VolumenBulto = value;
			
		} else if (header === "UnidadVolumen") {
			template.ECF.Encabezado.InformacionesAdicionales.UnidadVolumen = value;
			
		} 

		// Transporte
		else if (header === "Conductor") {
			template.ECF.Encabezado.Transporte.Conductor = value;
			
		} else if (header === "DocumentoTransporte") {
			template.ECF.Encabezado.Transporte.DocumentoTransporte = value;
			
		} else if (header === "Ficha") {
			template.ECF.Encabezado.Transporte.Ficha = value;
			
		} else if (header === "Placa") {
			template.ECF.Encabezado.Transporte.Placa = value;
			
		} else if (header === "RutaTransporte") {
			template.ECF.Encabezado.Transporte.RutaTransporte = value;
			
		} else if (header === "ZonaTransporte") {
			template.ECF.Encabezado.Transporte.ZonaTransporte = value;
			
		} else if (header === "NumeroAlbaran") {
			template.ECF.Encabezado.Transporte.NumeroAlbaran = value;
			
		} 

		// Totales
		else if (header === "MontoGravadoTotal") {
			template.ECF.Encabezado.Totales.MontoGravadoTotal = value;
			
		} else if (header === "MontoGravadoI1") {
			template.ECF.Encabezado.Totales.MontoGravadoI1 = value;
			
		} else if (header === "MontoGravadoI2") {
			template.ECF.Encabezado.Totales.MontoGravadoI2 = value;
			
		} else if (header === "MontoGravadoI3") {
			template.ECF.Encabezado.Totales.MontoGravadoI3 = value;
			
		} else if (header === "MontoExento") {
			template.ECF.Encabezado.Totales.MontoExento = value;
			
		} else if (header === "ITBIS1") {
			template.ECF.Encabezado.Totales.ITBIS1 = value;
			
		} else if (header === "ITBIS2") {
			template.ECF.Encabezado.Totales.ITBIS2 = value;
			
		} else if (header === "ITBIS3") {
			template.ECF.Encabezado.Totales.ITBIS3 = value;
			
		} else if (header === "TotalITBIS") {
			template.ECF.Encabezado.Totales.TotalITBIS = value;
			
		} else if (header === "TotalITBIS1") {
			template.ECF.Encabezado.Totales.TotalITBIS1 = value;
			
		} else if (header === "TotalITBIS2") {
			template.ECF.Encabezado.Totales.TotalITBIS2 = value;
			
		} else if (header === "TotalITBIS3") {
			template.ECF.Encabezado.Totales.TotalITBIS3 = value;
			
		} else if (header === "MontoImpuestoAdicional") {
			template.ECF.Encabezado.Totales.MontoImpuestoAdicional = value;
			
		} else if (header === "MontoTotal") {
			template.ECF.Encabezado.Totales.MontoTotal = value;
			
		} else if (header === "MontoNoFacturable") {
			template.ECF.Encabezado.Totales.MontoNoFacturable = value;
			
		} else if (header === "MontoPeriodo") {
			template.ECF.Encabezado.Totales.MontoPeriodo = value;
			
		} else if (header === "SaldoAnterior") {
			template.ECF.Encabezado.Totales.SaldoAnterior = value;
			
		} else if (header === "MontoAvancePago") {
			template.ECF.Encabezado.Totales.MontoAvancePago = value;
			
		} else if (header === "ValorPagar") {
			template.ECF.Encabezado.Totales.ValorPagar = value;
			
		} else if (header === "TotalITBISRetenido") {
			template.ECF.Encabezado.Totales.TotalITBISRetenido = value;
			
		} else if (header === "TotalISRRetencion") {
			template.ECF.Encabezado.Totales.TotalISRRetencion = value;
			
		} else if (header === "TotalITBISPercepcion") {
			template.ECF.Encabezado.Totales.TotalITBISPercepcion = value;
			
		} else if (header === "TotalISRPercepcion") {
			template.ECF.Encabezado.Totales.TotalISRPercepcion = value;
			
		}

		// OtraMoneda
		else if (header === "TipoMoneda") {
			template.ECF.Encabezado.OtraMoneda.TipoMoneda = value;
			
		} else if (header === "TipoCambio") {
			template.ECF.Encabezado.OtraMoneda.TipoCambio = value;
			
		} else if (header === "MontoGravadoTotalOtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.MontoGravadoTotalOtraMoneda = value;
			
		} else if (header === "MontoGravado1OtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.MontoGravado1OtraMoneda = value;
			
		} else if (header === "MontoGravado2OtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.MontoGravado2OtraMoneda = value;
			
		} else if (header === "MontoGravado3OtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.MontoGravado3OtraMoneda = value;
			
		} else if (header === "MontoExentoOtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.MontoExentoOtraMoneda = value;
			
		} else if (header === "TotalITBISOtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.TotalITBISOtraMoneda = value;
			
		} else if (header === "TotalITBIS1OtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.TotalITBIS1OtraMoneda = value;
			
		} else if (header === "TotalITBIS2OtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.TotalITBIS2OtraMoneda = value;
			
		} else if (header === "TotalITBIS3OtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.TotalITBIS3OtraMoneda = value;
			
		} else if (header === "MontoImpuestoAdicionalOtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.MontoImpuestoAdicionalOtraMoneda = value;
			
		} else if (header === "MontoTotalOtraMoneda") {
			template.ECF.Encabezado.OtraMoneda.MontoTotalOtraMoneda = value;
			
		}

		// SubTotales
		else if (["NumeroSubTotal", "DescripcionSubtotal", "Orden", "SubTotalMontoGravadoTotal", "SubTotalMontoGravadoI1", "SubTotalMontoGravadoI2", "SubTotalMontoGravadoI3", "SubTotaITBIS", "SubTotaITBIS1", "SubTotaITBIS2", "SubTotaITBIS3", "SubTotalImpuestoAdicional", "SubTotalExento", "MontoSubTotal", "Lineas",].map((item)=>(item.toLowerCase())).includes(header.toLowerCase())) {
			if ( !template.ECF.Subtotales ) template.ECF.Subtotales = {};
			if ( !template.ECF.Subtotales.Subtotal ) template.ECF.Subtotales.Subtotal = []
			if ( !template.ECF.Subtotales.Subtotal[0] ) template.ECF.Subtotales.Subtotal[0] = {}

			template.ECF.Subtotales.Subtotal[0][header] = value
		}

		// InformacionReferencia
		else if (header === "NCFModificado") {
			template.ECF.InformacionReferencia.NCFModificado = value;
		} else if (header === "RNCOtroContribuyente") {
			template.ECF.InformacionReferencia.RNCOtroContribuyente = value;
		} else if (header === "FechaNCFModificado") {
			template.ECF.InformacionReferencia.FechaNCFModificado = value;
		} else if (header === "CodigoModificacion") {
			template.ECF.InformacionReferencia.CodigoModificacion = value;
		} else if (header === "RazonModificacion") {
			template.ECF.InformacionReferencia.RazonModificacion = value;
		} 
	}
}

function createTemplate(): JSONData {
	return {
		ECF: {
			Encabezado: {
				Version: "",
				IdDoc: {
					TipoeCF: "",
					eNCF: "",
					FechaVencimientoSecuencia: "",
					IndicadorEnvioDiferido: "",
					IndicadorMontoGravado: "",
					IndicadorServicioTodoIncluido: "",
					TipoIngresos: "",
					TipoPago: "",
					FechaLimitePago: "",
					TerminoPago: "",
					TablaFormasPago: {
						FormaDePago: [],
					},
					TipoCuentaPago: "",
					NumeroCuentaPago: "",
					BancoPago: "",
					FechaDesde: "",
					FechaHasta: "",
					TotalPaginas: "",
				},
				Emisor: {
					RNCEmisor: "",
					RazonSocialEmisor: "",
					NombreComercial: "",
					Sucursal: "",
					DireccionEmisor: "",
					Municipio: "",
					Provincia: "",
					TablaTelefonoEmisor: {
						TelefonoEmisor: [],
					},
					CorreoEmisor: "",
					WebSite: "",
					ActividadEconomica: "",
					CodigoVendedor: "",
					NumeroFacturaInterna: "",
					NumeroPedidoInterno: "",
					ZonaVenta: "",
					RutaVenta: "",
					InformacionAdicionalEmisor: "",
					FechaEmision: "",
				},
				Comprador: {
					RNCComprador: "",
					RazonSocialComprador: "",
					ContactoComprador: "",
					CorreoComprador: "",
					DireccionComprador: "",
					MunicipioComprador: "",
					ProvinciaComprador: "",
					FechaEntrega: "",
					ContactoEntrega: "",
					DireccionEntrega: "",
					TelefonoAdicional: "",
					FechaOrdenCompra: "",
					NumeroOrdenCompra: "",
					CodigoInternoComprador: "",
					ResponsablePago: "",
					InformacionAdicionalComprador: "",
					IdentificadorExtranjero: "",
				},
				InformacionesAdicionales: {
					FechaEmbarque: "",
					NumeroEmbarque: "",
					NumeroContenedor: "",
					NumeroReferencia: "",
					PesoBruto: "",
					PesoNeto: "",
					UnidadPesoBruto: "",
					UnidadPesoNeto: "",
					CantidadBulto: "",
					UnidadBulto: "",
					VolumenBulto: "",
					UnidadVolumen: "",
				},
				Transporte: {
					Conductor: "",
					DocumentoTransporte: "",
					Ficha: "",
					Placa: "",
					RutaTransporte: "",
					ZonaTransporte: "",
					NumeroAlbaran: "",
				},
				Totales: {
					MontoGravadoTotal: "",
					MontoGravadoI1: "",
					MontoGravadoI2: "",
					MontoGravadoI3: "",
					MontoExento: "",
					ITBIS1: "",
					ITBIS2: "",
					ITBIS3: "",
					TotalITBIS: "",
					TotalITBIS1: "",
					TotalITBIS2: "",
					TotalITBIS3: "",
					MontoImpuestoAdicional: "",
					ImpuestosAdicionales: {
						ImpuestoAdicional: [],
					},
					MontoTotal: "",
					MontoNoFacturable: "",
					MontoPeriodo: "",
					SaldoAnterior: "",
					MontoAvancePago: "",
					ValorPagar: "",
					TotalITBISRetenido: "",
					TotalISRRetencion: "",
					TotalITBISPercepcion: "",
					TotalISRPercepcion: "",
				},
				OtraMoneda: {
					TipoMoneda: "",
					TipoCambio: "",
					MontoGravadoTotalOtraMoneda: "",
					MontoGravado1OtraMoneda: "",
					MontoGravado2OtraMoneda: "",
					MontoGravado3OtraMoneda: "",
					MontoExentoOtraMoneda: "",
					TotalITBISOtraMoneda: "",
					TotalITBIS1OtraMoneda: "",
					TotalITBIS2OtraMoneda: "",
					TotalITBIS3OtraMoneda: "",
					MontoImpuestoAdicionalOtraMoneda: "",
					ImpuestosAdicionalesOtraMoneda: {
						ImpuestoAdicionalOtraMoneda: [],
					},
					MontoTotalOtraMoneda: "",
				},
			},
			DetallesItems: {
				Item: [],
			},
			Subtotales: {
				Subtotal: [],
			},
			DescuentosORecargos: {
				DescuentoORecargo: [],
			},
			Paginacion: {
				Pagina: [],
			},
			InformacionReferencia: {
				NCFModificado: "",
				RNCOtroContribuyente: "",
				FechaNCFModificado: "",
				CodigoModificacion: "",
			},
			FechaHoraFirma: "",
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
const filePath = path.join(__dirname, "../paso-2/datos.xlsx"); // Cambia esta ruta según tu directorio

parseExcelToCustomJson(filePath).then((arrayConverted) => {
	arrayConverted.forEach((json, index) => {
		const RNCEmisor = json.ECF.Encabezado.Emisor.RNCEmisor;
		const eNCF = json.ECF.Encabezado.IdDoc.eNCF;
		
		const transformer = new Transformer();
		const xml = transformer.json2xml(json);

		const fileName = `${index+1}_${RNCEmisor}${eNCF}.xml`;
		const filePath = path.join(__dirname, `../paso-2/sin_firmar/${fileName}`)

		crearArchivoXML(xml, filePath);
	})
})
.catch((error) => {
	console.error("Error al procesar el archivo:", error.message);
});
