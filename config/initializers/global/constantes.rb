
PROJECT_PATH     = File.join Rails.root, "/"
PUBLIC_PATH      = File.join Rails.root, "public"
ENCRIPT_SECRET   = "1234567890ABCDEF"
HTTP_STATUS_CODE = Rack::Utils::SYMBOL_TO_STATUS_CODE



DIAS             = ["Lunes", "Martes", "Miercoles", "Jueves",  "Viernes", "Sabado", "Domingo"]


module Identificador
	CLIENTE_ID = "1"
	USER_ID = "2"
	TOTAL_FACTURA = "3"
	FECHA_EQUIVALENTE = "4"
	CANTIDAD_ARTICULOS = "5"

	def self.cliente_id
		return CLIENTE_ID
	end

	def self.user_id
		return USER_ID
	end

	def self.total_factura
		return TOTAL_FACTURA
	end

	def self.fecha_equivalente
		return FECHA_EQUIVALENTE
	end

	def self.cantidad_articulos
		return CANTIDAD_ARTICULOS
	end
end

module TipoArticulos
	VETERINARIA         = "1"
	MATERIA_PRIMA       = "2"
	PRODUCTO_TERMINADO  = "3"
	OTRO                = "4"

	def self.veterinaria
		return VETERINARIA
	end

	def self.materia_prima
		return MATERIA_PRIMA
	end

	def self.producto_terminado
		return PRODUCTO_TERMINADO
	end

	def self.otro
		return OTRO
	end

end

module Documentos
	CEDULA = "cedula"
	RNC = "rnc"

	def self.cedula
		return CEDULA
	end

	def self.rnc
		return RNC
	end

end

DOCUMENTOS_DE_IDENTIDAD_VALIDOS = [Documentos.cedula, Documentos.rnc]

module FacturasParams

  CLIENTE_ID = "cliente_id"
  NUMERO_COMPROBANTE = "numero_comprobante"
  NUMERO_FACTURA = "numero_factura"
  LAST_50 = "last_50"

  PARAMETROS = { :_1_ => CLIENTE_ID, :_2_ => NUMERO_COMPROBANTE, :_3_ => NUMERO_FACTURA, :_4_ => LAST_50 }

  def self.get_campo_by_param(param)
    return PARAMETROS[:"_#{param}_"]
  end

  def self.parse_valor_by_param(param, valor=nil)
    valor = param == "1" || param == "3" ? valor.to_i : valor.upcase unless param == "4"
    return valor
  end


  def self.cliente_id
    return CLIENTE_ID
  end

  def self.numero_comprobante
    return NUMERO_COMPROBANTE
  end

  def self.numero_factura
    return NUMERO_FACTURA
  end

  def self.last_50
    return LAST_50
  end

end


module TiposNotas

	CREDITO = "nota_credito"
	DEBITO  = "nota_debito"

	def self.credito
		return CREDITO
	end

	def self.debito
		return DEBITO
	end

	def self.get_tipo(tipo)
		return tipo == TiposNotasId.credito ? self.credito : self.debito
	end

end


module TiposNotasId

	CREDITO = 5
	DEBITO  = 4

	def self.credito
		return CREDITO
	end

	def self.debito
		return DEBITO
	end
end


module OperadoresMovimiento

	ENTRADA = "entrada"
	ENTRADA_OPERADOR = "+"

	SALIDA  = "salida"
	SALIDA_OPERADOR = "-"


	def self.entrada
		return ENTRADA
	end

	def self.salida
		return SALIDA
	end

	def self.return_operador(tipo)
		return tipo == ENTRADA ? ENTRADA_OPERADOR : SALIDA_OPERADOR
	end

	def self.return_tipo(tipo)
		return tipo == ENTRADA_OPERADOR ? ENTRADA : SALIDA
	end



end



PROVINCIAS_MUNICIPIOS=[
  { nombre: "Distrito Nacional", municipios: ["Santo Domingo Centro (DN)", "Santo Domingo Este", "Santo Domingo Oeste", "Santo Domingo Norte", "Boca Chica", "San Antonio DE Guerra", "Los Alcarrizos", "Pedro Brand"] },
  { nombre: "San Pedro de Macorís", municipios: ["San Pedro DE Macoris", "Los Llanos", "Ramon Santana", "Consuelo", "Quisqueya", "Guayacanes"] },
  { nombre: "La Romana", municipios: ["La Romana", "Guaymate", "Villa Hermosa"] },
  { nombre: "La Altagracia", municipios: ["Higuey", "San Rafael Del Yuma" ] },
  { nombre: "El Seibo", municipios: ["El Seibo", "Miches"] },
  { nombre: "Hato Mayor", municipios: ["Hato Mayor", "Sabana De La Mar", "El Valle"] },
  { nombre: "Duarte",	municipios: ["San Francisco De Macoris", "Arenoso", "Castillo", "Pimentel", "Villa Riva", "Las Guaranas", "Eugenio Maria De Hostos"] },
  { nombre: "Samaná",	municipios: ["Samaná", "Sanchez", "Las Terrenas"] },
  { nombre: "Maria Trinidad Sánchez",	municipios: ["Nagua", "Cabrera", "El Factor", "Rio San Juan"] },
  { nombre: "Salcedo",	municipios: ["Salcedo", "Tenares", "Villa Tapia"] },
  { nombre: "La Vega",	municipios: ["La Vega", "Constanza", "Jarabacoa", "Jima Abajo"] },
  { nombre: "Monseñor Nouel",	municipios: ["Bonao", "Maimon", "Piedra Blanca"] },
  { nombre: "Sánchez Ramirez",	municipios: ["Cotui", "Cevicos", "Fantino", "La Mata"] },
  { nombre: "Santiago",	municipios: ["Santiago", "Bisono", "Janico", "Licey Al Medio", "San Jose De Las Matas", "Tamboril", "Villa Gonzalez", "Puñal", "Sabana Iglesia"] },
  { nombre: "Espaillat",	municipios: ["Moca", "Cayetano Germosen", "Gaspar Hernandez", "Jamao Al Norte"] },
  { nombre: "Puerto Plata",	municipios: ["Puerto plata", "altamira", "guananico", "imbert", "Los hidalgos", "luperon", "sosua", "Villa isabela", "Villa montellano"] },
  { nombre: "Valverde",	municipios: ["Mao", "Esperanza", "Laguna Salada"] },
  { nombre: "Monte Cristi",	municipios: ["Monte Cristi", "Castañuelas", "Guayubin", "Las Matas De Santa Cruz", "Pepillo Salcedo", "Villa Vasquez"] },
  { nombre: "Dajabón",	municipios: ["Dajabon", "Loma De Cabrera", "Partido", "Restauracion", "El Pino"] },
  { nombre: "Santiago Rodríguez",	municipios: ["San Ignacio De Sabaneta", "Villa Los Almacigos", "Moncion"] },
  { nombre: "Azua",	municipios: ["Azua", "Las Charcas", "Las Yayas De Viajama", "Padre Las Casas", "Peralta", "Sabana Yegua", "Pueblo Viejo", "Tabara Arriba", "Guayabal", "Estebania"] },
  { nombre: "San Juan de la Maguana",	municipios: ["San Juan", "Bohechio", "El Cercado", "Juan De Herrera", "Las Matas De Farfan", "Vallejuelo"] },
  { nombre: "Elías Piña",	municipios: ["Comendador", "Banica", "El Llano", "Hondo Valle", "Pedro Santana", "Juan Santiago"] },
  { nombre: "Barahona",	municipios: ["Barahona", "Cabral", "Enriquillo", "Paraiso", "Vicente Noble", "El Peñon", "La Cienaga", "Fundacion", "Las Salinas", "Polo", "Jaquimeyes"] },
  { nombre: "Bahoruco",	municipios: ["Neiba", "Galvan", "Tamayo", "Villa Jaragua", "Los Rios"] },
  { nombre: "Independencia",	municipios: ["Jimani", "Duverge", "La Descubierta", "Postrer Rio", "Cristobal", "Mella"] },
  { nombre: "Perdenales",	municipios: ["Pedernales", "Oviedo"] },
  { nombre: "San Cristóbal",	municipios: ["San Cristobal", "Sabana Grande De Palenque", "Bajos De Haina", "Cambita Garabitos", "Villa Altagracia", "Yaguate", "San Gregorio De Nigua", "Los Cacaos"] },
  { nombre: "Monte Plata",	municipios: ["Monte Plata", "Bayaguana", "Sabana Grande De Boya", "Yamasa", "Peralvillo"] },
  { nombre: "San José de Ocoa",	municipios: ["San Jose De Ocoa", "Sabana Larga", "Rancho Arriba"] },
  { nombre: "Peravia",	municipios: ["Bani", "Nizao"] }
]

ACCIONES_COMUNES = [
	{nombre:"crear",       descripcion: "create",    metodo: "create"},
	{nombre:"ver todos",   descripcion: "read_all",  metodo: "index"},
	{nombre:"buscar uno",  descripcion: "read_one",  metodo: "show"},
	{nombre:"editar",      descripcion: "update",    metodo: "update"},
]

ACCION_DESTROY = [{ nombre:"eliminar", descripcion: "destroy", metodo: "destroy"}]


G_PERMISOS = [
	{ nombre:"articulos",                     mostrar_front: true,     descripcion: "articulo",                controlador: "Articulos",                      acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"ver inventario", descripcion: "get_stock", metodo: "getStock"}, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getArticulosFiltrados"}, {nombre:"verificar si excede", descripcion: "check_excede",metodo: "checkIfExcede"}, {nombre:"ver formulas", descripcion: "read_formula",metodo: nil}, {nombre:"editar formular",descripcion: "update_formula", metodo: nil} ]},
	{ nombre:"conduces",                      mostrar_front: true,     descripcion: "conduce",                 controlador: "CabeceraConduces",               acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"facturas venta",                mostrar_front: true,     descripcion: "factura_venta",           controlador: "CabeceraFacturas",               acciones: [*ACCIONES_COMUNES, {nombre:"buscar facturas por parametros", descripcion: "get_facturas_by_params", metodo: "getFacturasByParams"}, {nombre:"comprobar serial", descripcion: "comprobar_serial", metodo: "comprobarSerial"}, {nombre:"verificar si puede editar", descripcion: "verificate_can_update_id", metodo: "verificateCanUpdateById"}, {nombre:"buscar viajes sin completar", descripcion: "get_viajes_sin_completar", metodo: "getViajesSinCompletar"}, {nombre:"buscar facturas por cliente y estado", descripcion: "get_facturas_by_cliente_estado", metodo: "getFacturasByClienteIdAndEstado"}, {nombre:"cancelar factura", descripcion: "cancelar_factura", metodo: "cancelarFactura"}, {nombre:"seleccionar camion en facturacion", descripcion: "seleccionar_camion_en_facturacion", metodo: nil}]},
	{ nombre:"facturas compra",               mostrar_front: true,     descripcion: "factura_compra",          controlador: "CabeceraFacturas",               acciones: [*ACCIONES_COMUNES, {nombre:"buscar facturas por parametros", descripcion: "get_facturas_by_params", metodo: "getFacturasByParams"}, {nombre:"comprobar serial", descripcion: "comprobar_serial", metodo: "comprobarSerial"}, {nombre:"verificar si puede editar", descripcion: "verificate_can_update_id", metodo: "verificateCanUpdateById"}, {nombre:"buscar facturas por suplidor y estado", descripcion: "get_facturas_by_suplidor_estado", metodo: "getFacturasBySuplidorIdAndEstado"}, {nombre:"cancelar factura", descripcion: "cancelar_factura", metodo: "cancelarFactura"}]},
	{ nombre:"notas crédito",                 mostrar_front: true,     descripcion: "nota_credito",            controlador: "Nota",                           acciones: [*ACCIONES_COMUNES, {nombre:"cancelar nota", descripcion: "cancelar_nota", metodo: "cancelarNota"}, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getNotasFiltradas"}]},
	{ nombre:"notas débito",                  mostrar_front: true,     descripcion: "nota_debito",             controlador: "Nota",                           acciones: [*ACCIONES_COMUNES, {nombre:"cancelar nota", descripcion: "cancelar_nota", metodo: "cancelarNota"}, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getNotasFiltradas"}]},
	{ nombre:"facturas en notas",             mostrar_front: true,     descripcion: "facturas_aplicadas",      controlador: "FacturaAplicada",                acciones: [{nombre:"buscar cantidad devuelto", descripcion: "get_cantidad_devuelto", metodo: "getCantidadDevuelto"}]},
	{ nombre:"clientes",                      mostrar_front: true,     descripcion: "cliente",                 controlador: "Clientes",                       acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getClientesFiltrados"} ]},
	{ nombre:"costos fletes",                 mostrar_front: true,     descripcion: "costo_flete",             controlador: "CostoFletes",                    acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"detalles factura",              mostrar_front: true,     descripcion: "detalle_factura",         controlador: "DetalleFacturas",                acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"historicos producciones",       mostrar_front: true,     descripcion: "historico_produccion",    controlador: "HistoricoProduccions",           acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"imagenes",                      mostrar_front: true,     descripcion: "imagen",                  controlador: "Imagenes",                       acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"cuadres caja",                  mostrar_front: true,     descripcion: "cuadre_caja",             controlador: "CuadreCajas",                    acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"verificar cuadre del dia", descripcion: "check_today_cuadre", metodo: "checkTodayCuadre"} ]},
	{ nombre:"mantenimientos articulos",      mostrar_front: true,     descripcion: "mantenimiento_articulo",  controlador: "MantenimientoArticulos",         acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar articulo por fecha", descripcion: "get_one_articulo_date", metodo: "getOneArticuloByDate"} ]},
	{ nombre:"marcas",                        mostrar_front: true,     descripcion: "marca",                   controlador: "Marcas",                         acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getMarcasFiltradas"} ]},
	{ nombre:"modelos",                       mostrar_front: true,     descripcion: "modelo",                  controlador: "Modelos",                        acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"ver modelos por marca", descripcion: "get_modelos_by_marca", metodo: "getModelosPorMarca"}, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getModelosFiltrados"} ]},
	{ nombre:"movimientos de inventarios",    mostrar_front: true,     descripcion: "movimiento_inventario",   controlador: "MovimientosInventarios",         acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"municipios",                    mostrar_front: true,     descripcion: "municipio",               controlador: "Municipios",                     acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY]},
	{ nombre:"producciones",                  mostrar_front: true,     descripcion: "produccion",              controlador: "Producciones",                   acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getProduccionesFiltradas"} ]},
	{ nombre:"provincias",                    mostrar_front: true,     descripcion: "provincia",               controlador: "Provincias",                     acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"recibos ingreso",               mostrar_front: true,     descripcion: "recibo_ingreso",          controlador: "RecibosIngresos",                acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getRecibosFiltrados"}, {nombre:"revertir recibo", descripcion: "revertir_recibo", metodo: "revertirRecibos"} ]},
	{ nombre:"reportes",                      mostrar_front: true,     descripcion: "reporte",                 controlador: "Reportes",                       acciones: [{nombre:"ver reportes", descripcion: "get_reportes", metodo: "getReportes"} ]},
	{ nombre:"comprobantes fiscales",         mostrar_front: true,     descripcion: "secuencia_comprobante",   controlador: "SecuenciaComprobantes",          acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getSecuenciaComprobantesFiltrados"}, {nombre:"buscar comprobanrte por estado", descripcion: "get_paquete_rnc_estado", metodo: "getPaqueteRncByEstado"} ]},
	{ nombre:"suplidores",                    mostrar_front: true,     descripcion: "suplidor",                controlador: "Suplidores",                     acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar nombres de suplidores", descripcion: "get_nombres_suplidores", metodo: "getNombresSuplidores"}, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getSuplidoresFiltrados"} ]},
	{ nombre:"tipos articulos",               mostrar_front: true,     descripcion: "tipo_articulo",           controlador: "TipoArticulos",                  acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"tipos facturas",                mostrar_front: true,     descripcion: "tipo_factura",            controlador: "TipoFacturas",                   acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"tipos recibos",                 mostrar_front: true,     descripcion: "tipo_recibo",             controlador: "TipoRecibos",                    acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:"empleados",                     mostrar_front: true,     descripcion: "user",                    controlador: "Users",                          acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getUsuariosFiltrados"} ]},
	{ nombre:"vehiculos",                     mostrar_front: true,     descripcion: "vehiculo",                controlador: "Vehiculos",                      acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getVehiculosFiltrados"}  ]},
	{ nombre:"sesion de usuario",             mostrar_front: true,     descripcion: "device",                  controlador: "devise_token_auth/sessions",     acciones: [{nombre:"iniciar sesión", descripcion: "login", metodo: "create"}]},
	{ nombre:"roles",                         mostrar_front: true,     descripcion: "role",                    controlador: "Roles",                          acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:"buscar filtrados", descripcion: "get_filtrados", metodo: "getRolesFiltrados"}]}
]

module TiposFacturasId
	FACTURA_SIN_COMPROBANTE = 1
	FACTURA_CON_VALOR_FISCAL = 2
	FACTURA_DE_CONSUMO = 3
	NOTA_DE_DEBITO = 4
	NOTA_DE_CREDITO = 5
	COMPROBANTE_DE_COMPRAS = 6
	REGISTRO_DE_UNICO_INGRESO = 7
	COMPROBANTE_PARA_GASTOS_MENORES = 8
	COMPROBANTE_DE_REGIMEN_ESPECIALES = 9
	COMPROBANTE_GUBERNAMENTAL = 10
	COMPROBANTE_PARA_EXPORTACIONES = 11
	COMPROBANTES_PARA_PAGO_AL_EXTERIOR = 12
	VENTA_CONTADO = 13
	COMPRA = 14
	CONDUCE = 15
	PRODUCCION = 16
	RECIBO_INGRESO = 17
	VENTA_CREDITO = 18
	PRE_FACTURA = 19

	def self.factura_sin_comprobante
		return FACTURA_SIN_COMPROBANTE
	end

	def self.factura_con_valor_fiscal
		return FACTURA_CON_VALOR_FISCAL
	end

	def self.factura_de_consumo
		return FACTURA_DE_CONSUMO
	end

	def self.nota_de_debito
		return NOTA_DE_DEBITO
	end

	def self.nota_de_credito
		return NOTA_DE_CREDITO
	end

	def self.comprobante_de_compras
		return COMPROBANTE_DE_COMPRAS
	end

	def self.registro_de_unico_ingreso
		return REGISTRO_DE_UNICO_INGRESO
	end

	def self.comprobante_para_gastos_menores
		return COMPROBANTE_PARA_GASTOS_MENORES
	end

	def self.comprobante_de_regimen_especiales
		return COMPROBANTE_DE_REGIMEN_ESPECIALES
	end

	def self.comprobante_gubernamental
		return COMPROBANTE_GUBERNAMENTAL
	end

	def self.comprobante_para_exportaciones
		return COMPROBANTE_PARA_EXPORTACIONES
	end

	def self.comprobantes_para_pago_al_exterior
		return COMPROBANTES_PARA_PAGO_AL_EXTERIOR
	end

	def self.venta_contado
		return VENTA_CONTADO
	end

	def self.compra
		return COMPRA
	end

	def self.conduce
		return CONDUCE
	end

	def self.produccion
		return PRODUCCION
	end

	def self.recibo_ingreso
		return RECIBO_INGRESO
	end

	def self.venta_credito
		return VENTA_CREDITO
	end

	def self.pre_factura
		return PRE_FACTURA
	end

end


# G_OTROS_COSTOS=[
# 	{descripcion:"Saco 100 libras", key: "saco_100", costo:9, precio:20 },
# 	{descripcion:"Saco 75 libras",  key: "saco_75",  costo:9, precio:20 },
# 	{descripcion:"Saco 25 libras",  key: "saco_25",  costo:9, precio:20 },
# ]