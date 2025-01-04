import * as XLSX from "xlsx";
import * as fs from "fs";
import * as path from "path";

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
			const headers = (rawJson[0] as string[]).slice(1); // Ignorar el primer header
			// const rows = rawJson.slice(1); // Obtener todas las filas de datos
			const rows = [rawJson[15]]; // Obtener todas las filas de datos

			const result: JSONData[] = [];

			// Procesar las filas
			rows.forEach((row) => {
				const template: JSONData = createTemplate(); // Crear una copia del template base

				headers.forEach((header, colIndex) => {
					if (!header) return;

					header = header.trim(); // Limpieza del encabezado
					const value = row[colIndex + 1]; // Ajusta el índice para ignorar la primera columna

					// Ignorar los campos con el valor "#e"
					if (value === "#e") {
						return;
					}

					mapeoResult(template, header, value); // Mapea el valor a la estructura del template
				});

				result.push(template); // Agregar el template mapeado al arreglo
			});

			// Eliminar las propiedades y arreglos vacíos
			result.forEach(removeEmptyValues);

			resolve(result); // Resolver la promesa con el arreglo de templates mapeados
		} catch (error) {
			reject(error);
		}
	});
}

function mapeoResult(template, header, value) {
	// Mapeo dinámico de datos según la estructura
	const headerMatch = header.match(/(.*?)\[(\d+)\](?:\[(\d+)\])?/);
  // console.log("\n header ", header, "| value ",  value);
  
  
	if (headerMatch) {
    	let key = headerMatch[1].trim();
		const index1 = parseInt(headerMatch[2], 10) - 1; // Índices ajustados (base 1 -> base 0)
		const index2 = headerMatch[3] ? parseInt(headerMatch[3], 10) - 1 : null;
    console.log("\n key ", key, "| value ",  value);


		// Arreglos
		if (["FormaPago", "MontoPago"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase()) && !isEmpty(index1)) {
			if (isEmpty(template.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago[index1])) template.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago[index1] = {};
			
			template.ECF.Encabezado.IdDoc.TablaFormasPago.FormaDePago[ index1 ][key] = value;

		} else if (key === "TelefonoEmisor" && !isEmpty(index1)) {
			template.ECF.Encabezado.Emisor.TablaTelefonoEmisor.TelefonoEmisor[ index1 ] = value;

		} else if (["TipoImpuesto", "TasaImpuestoAdicional", "MontoImpuestoSelectivoConsumoEspecifico", "MontoImpuestoSelectivoConsumoAdvalorem", "OtrosImpuestosAdicionales"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase()) && !isEmpty(index1)) {
			if (isEmpty(index2)) {
				if ( isEmpty(template.ECF.Encabezado.Totales) ) template.ECF.Encabezado.Totales = {}; 
				if ( isEmpty(template.ECF.Encabezado.Totales.ImpuestosAdicionales) ) template.ECF.Encabezado.Totales.ImpuestosAdicionales = {}; 
				if ( isEmpty(template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional) ) template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional = []; 
				if ( isEmpty(template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional[index1]) ) template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional[index1] = {}; 

				template.ECF.Encabezado.Totales.ImpuestosAdicionales.ImpuestoAdicional[index1][key] = value
				
			}
		} else if (["TipoImpuestoOtraMoneda", "TasaImpuestoAdicionalOtraMoneda", "MontoImpuestoSelectivoConsumoEspecificoOtraMoneda", "MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda", "OtrosImpuestosAdicionalesOtraMoneda"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase()) && !isEmpty(index1)) {
			if ( isEmpty(template.ECF.Encabezado.OtraMoneda) ) template.ECF.Encabezado.OtraMoneda = {}; 
			if ( isEmpty(template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda) ) template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda = {}; 
			if ( isEmpty(template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda) ) template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda = {}; 
			if ( isEmpty(template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda[index1]) ) template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda[index1] = {}; 

			template.ECF.Encabezado.OtraMoneda.ImpuestosAdicionalesOtraMoneda.ImpuestoAdicionalOtraMoneda[index1][key] = value
		} else if (["NumeroLinea", "TipoCodigo", "CodigoItem", "IndicadorFacturacion", "IndicadorAgenteRetencionoPercepcion", "MontoITBISRetenido", "MontoISRRetenido", "NombreItem", "IndicadorBienoServicio", "DescripcionItem", "CantidadItem", "UnidadMedida", "CantidadReferencia", "UnidadReferencia", "Subcantidad", "CodigoSubcantidad", "GradosAlcohol", "PrecioUnitarioReferencia", "FechaElaboracion", "FechaVencimientoItem", "PrecioUnitarioItem", "DescuentoMonto", "TipoSubDescuento", "SubDescuentoPorcentaje", "MontoSubDescuento", "RecargoMonto", "TipoSubRecargo", "SubRecargoPorcentaje", "MontoSubRecargo", "TipoImpuesto", "PrecioOtraMoneda", "DescuentoOtraMoneda", "RecargoOtraMoneda", "MontoItemOtraMoneda", "MontoItem"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase()) && !isEmpty(index1) ) {

			if ( isEmpty(template.ECF.DetallesItems) ) template.ECF.DetallesItems = {}
			if ( isEmpty(template.ECF.DetallesItems.Item) ) template.ECF.DetallesItems.Item = []
			if ( isEmpty(template.ECF.DetallesItems.Item[index1]) ) template.ECF.DetallesItems.Item[index1] = {}
			
			if ( ["TipoCodigo", "CodigoItem"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase()) && !isEmpty(index2) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaCodigosItem) ) template.ECF.DetallesItems.Item[index1].TablaCodigosItem = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem) ) template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem = [];
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem[index2]) ) template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem[index2] = {};
				template.ECF.DetallesItems.Item[index1].TablaCodigosItem.CodigosItem[index2][key] = value;
			} else if ( ["IndicadorAgenteRetencionoPercepcion", "MontoITBISRetenido", "MontoISRRetenido"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase()) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].Retencion) ) template.ECF.DetallesItems.Item[index1].Retencion = {};
				template.ECF.DetallesItems.Item[index1].Retencion[key] = value;

			} else if ( ["Subcantidad", "CodigoSubcantidad"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase())  && !isEmpty(index2) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubcantidad) ) template.ECF.DetallesItems.Item[index1].TablaSubcantidad = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem) ) template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem = []
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem[index2]) ) template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem[index2] = {}
				template.ECF.DetallesItems.Item[index1].TablaSubcantidad.SubcantidadItem[index2][key] = value;

			} else if ( ["TipoSubDescuento", "SubDescuentoPorcentaje", "MontoSubDescuento"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase())  && !isEmpty(index2) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubDescuento) ) template.ECF.DetallesItems.Item[index1].TablaSubDescuento = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento) ) template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento = []
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento[index2]) ) template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento[index2] = {}
				template.ECF.DetallesItems.Item[index1].TablaSubDescuento.SubDescuento[index2][key] = value;

			} else if ( ["TipoSubRecargo", "SubRecargoPorcentaje", "MontoSubRecargo"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase())  && !isEmpty(index2) ) {
				if (key.toLowerCase() == "montosubrecargo") key = "MontoSubRecargo"
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubRecargo) ) template.ECF.DetallesItems.Item[index1].TablaSubRecargo = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo) ) template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo = []
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[index2]) ) template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[index2] = {}
				template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[index2][key] = value;

			} else if ( ["TipoImpuesto"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase())  && !isEmpty(index2) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional) ) template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional = {};
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional) ) template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional = []
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional[index2]) ) template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional[index2] = {}
				template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional.ImpuestoAdicional[index2][key] = value;

			} else if ( ["PrecioOtraMoneda", "DescuentoOtraMoneda", "RecargoOtraMoneda", "MontoItemOtraMoneda"].map((item)=>(item.toLowerCase())).includes(key.toLowerCase()) ) {
				if ( isEmpty(template.ECF.DetallesItems.Item[index1].OtraMonedaDetalle) ) template.ECF.DetallesItems.Item[index1].OtraMonedaDetalle = {};
				template.ECF.DetallesItems.Item[index1].OtraMonedaDetalle[key] = value;

			} else {
				template.ECF.DetallesItems.Item[index1][key] = value;
			}

		} else if ( key === "SubRecargo" && !isEmpty(index1) && !isEmpty(index2) ) {
			if ( !template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[ index2 ] ) {
				template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[ index2 ] = {};
			}

			template.ECF.DetallesItems.Item[index1].TablaSubRecargo.SubRecargo[ index2 ].MontoSubRecargo = value;
		} else if ( key === "ImpuestoAdicional" && !isEmpty(index1) && index2 === null ) {
			if ( !template.ECF.DetallesItems.Item[index1].TablaImpuestoAdicional .ImpuestoAdicional[index2] ) {
				template.ECF.DetallesItems.Item[ index1 ].TablaImpuestoAdicional.ImpuestoAdicional[index2] = {};
			}

			template.ECF.DetallesItems.Item[ index1 ].TablaImpuestoAdicional.ImpuestoAdicional[index2].TipoImpuesto = value;
		} else if (key === "DescuentoORecargo" && !isEmpty(index1)) {
			if (!template.ECF.DescuentosORecargos.DescuentoORecargo[index1]) {
				template.ECF.DescuentosORecargos.DescuentoORecargo[index1] = {};
			}
			template.ECF.DescuentosORecargos.DescuentoORecargo[ index1 ].DescripcionDescuentooRecargo = value;
		} else if (key === "Pagina" && !isEmpty(index1)) {
			if (!template.ECF.Paginacion.Pagina[index1]) { template.ECF.Paginacion.Pagina[index1] = {}; 
    }

			template.ECF.Paginacion.Pagina[index1].PaginaNo = value;
		}

		// Asignaciones directas
	} else {
		if (header === "TipoeCF") {
			template.ECF.Encabezado.IdDoc.TipoeCF = value;
		} else if (header === "ENCF") {
			template.ECF.Encabezado.IdDoc.eNCF = value;
		} else if (header === "FechaVencimientoSecuencia") {
			template.ECF.Encabezado.IdDoc.FechaVencimientoSecuencia = value;
		} else if (header === "IndicadorEnvioDiferido") {
			template.ECF.Encabezado.IdDoc.IndicadorEnvioDiferido = value;
		} else if (header === "IndicadorMontoGravado") {
			template.ECF.Encabezado.IdDoc.IndicadorMontoGravado = value;
		} else if (header === "IndicadorServicioTodoIncluido") {
			template.ECF.Encabezado.IdDoc.IndicadorServicioTodoIncluido = value;
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

		// SubTotales
		else if (["NumeroSubTotal", "DescripcionSubtotal", "Orden", "SubTotalMontoGravadoTotal", "SubTotalMontoGravadoI1", "SubTotalMontoGravadoI2", "SubTotalMontoGravadoI3", "SubTotaITBIS", "SubTotaITBIS1", "SubTotaITBIS2", "SubTotaITBIS3", "SubTotalImpuestoAdicional", "SubTotalExento", "MontoSubTotal", "Lineas"].map((item)=>(item.toLowerCase())).includes(header.toLowerCase())) {
			if ( !template.ECF.Subtotales ) template.ECF.Subtotales = {};
			if ( !template.ECF.Subtotales.Subtotal ) template.ECF.Subtotales.Subtotal = []
			if ( !template.ECF.Subtotales.Subtotal[0] ) template.ECF.Subtotales.Subtotal[0] = {}

			template.ECF.Subtotales.Subtotal[0][header] = value
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

		// Totales
		else if (header === "TotalImpuestos") {
			template.ECF.Totales.TotalImpuestos = value;
		} else if (header === "TotalDescuentos") {
			template.ECF.Totales.TotalDescuentos = value;
		} else if (header === "TotalRecargos") {
			template.ECF.Totales.TotalRecargos = value;
		} else if (header === "TotalItem") {
			template.ECF.Totales.TotalItem = value;
		}

		// Otros
		else if (header === "DescripcionPago") {
			template.ECF.Pagos.DescripcionPago = value;
		} else if (header === "NumeroPago") {
			template.ECF.Pagos.NumeroPago = value;
		} else if (header === "MetodoPago") {
			template.ECF.Pagos.MetodoPago = value;
		} else if (header === "TotalPago") {
			template.ECF.Pagos.TotalPago = value;
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

// Función auxiliar para verificar si un valor está vacío
function isEmpty(value: any): boolean {
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

// Ejemplo de uso
const filePath = path.join(__dirname, "datos.xlsx"); // Cambia esta ruta según tu directorio

parseExcelToCustomJson(filePath)
	.then((json) => {
		console.log("Datos convertidos:", JSON.stringify(json, null, 2));
	})
	.catch((error) => {
		console.error("Error al procesar el archivo:", error.message);
	});
