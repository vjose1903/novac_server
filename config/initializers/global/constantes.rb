
PROJECT_PATH     = File.join Rails.root, '/'
PUBLIC_PATH      = File.join Rails.root, 'public'
ENCRIPT_SECRET   = '1234567890ABCDEF'
HTTP_STATUS_CODE = Rack::Utils::SYMBOL_TO_STATUS_CODE



DIAS             = ['Lunes', 'Martes', 'Miercoles', 'Jueves',  'Viernes', 'Sabado', 'Domingo']


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
	VETERINARIA         = '1'
	MATERIA_PRIMA       = '2'
	PRODUCTO_TERMINADO  = '3'
	OTRO                = '4'

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
	CEDULA = 'cedula'
	RNC = 'rnc'

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
	{nombre:'crear',       descripcion: 'create',    metodo: 'create'},
	{nombre:'ver todos',   descripcion: 'read_all',  metodo: 'index'},
	{nombre:'buscar uno',  descripcion: 'read_one',  metodo: 'show'},
	{nombre:'editar',      descripcion: 'update',    metodo: 'update'},
]

ACCION_DESTROY = [{ nombre:'eliminar', descripcion: 'destroy', metodo: 'destroy'}]



G_PERMISOS = [
	{ nombre:'articulos',                     descripcion: 'articulo',                controlador: 'Articulos',               acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'ver inventario', descripcion: 'get_stock', metodo: 'getStock'}, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getArticulosFiltrados'}, {nombre:'verificar si excede', descripcion: 'check_excede', metodo: 'checkIfExcede'}, {nombre:'ver formulas', descripcion: 'read_formula', metodo: nil}, {nombre:'editar formular', descripcion: 'update_formula', metodo: nil} ]},
	{ nombre:'conduces',                      descripcion: 'conduce',                 controlador: 'CabeceraConduces',        acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'facturas',                      descripcion: 'factura',                 controlador: 'CabeceraFacturas',        acciones: [*ACCIONES_COMUNES, {nombre:'buscar facturas por parametros', descripcion: 'get_facturas_by_params', metodo: 'getFacturasByParams'}, {nombre:'buscar notas', descripcion: 'get_notas', metodo: 'getNotas'}, {nombre:'comprobar serial', descripcion: 'comprobar_serial', metodo: 'comprobarSerial'}, {nombre:'buscar cantidad devuelto', descripcion: 'get_cantidad_devuelto', metodo: 'getCantidadDevuelto'}, {nombre:'verificar si puede editar', descripcion: 'verificate_can_update_id', metodo: 'verificateCanUpdateById'}, {nombre:'buscar viajes sin completar', descripcion: 'get_viajes_sin_completar', metodo: 'getViajesSinCompletar'}, {nombre:'buscar facturas por cliente y estado', descripcion: 'get_facturas_by_cliente_estado', metodo: 'getFacturasByClienteIdAndEstado'}, {nombre:'cancelar factura', descripcion: 'cancelar_factura', metodo: 'cancelarFactura'}]},
	{ nombre:'clientes',                      descripcion: 'cliente',                 controlador: 'Clientes',                acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getClientesFiltrados'} ]},
	{ nombre:'costos fletes',                 descripcion: 'costo_flete',             controlador: 'CostoFletes',             acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'detalles factura',              descripcion: 'detalle_factura',         controlador: 'DetalleFacturas',         acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'historicos producciones',       descripcion: 'historico_produccion',    controlador: 'HistoricoProduccions',    acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'imagenes',                      descripcion: 'imagen',                  controlador: 'Imagenes',                acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'cuadres caja',                  descripcion: 'cuadre_caja',             controlador: 'CuadreCajas',             acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'verificar cuadre del dia', descripcion: 'check_today_cuadre', metodo: 'checkTodayCuadre'} ]},
	{ nombre:'mantenimientos articulos',      descripcion: 'mantenimiento_articulo',  controlador: 'MantenimientoArticulos',  acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar articulo por fecha', descripcion: 'get_one_articulo_date', metodo: 'getOneArticuloByDate'} ]},
	{ nombre:'marcas',                        descripcion: 'marca',                   controlador: 'Marcas',                  acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getMarcasFiltradas'} ]},
	{ nombre:'modelos',                       descripcion: 'modelo',                  controlador: 'Modelos',                 acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'ver modelos por marca', descripcion: 'get_modelos_by_marca', metodo: 'getModelosPorMarca'}, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getModelosFiltrados'} ]},
	{ nombre:'movimientos de inventarios',    descripcion: 'movimiento_inventario',   controlador: 'MovimientosInventarios',  acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'municipios',                    descripcion: 'municipio',               controlador: 'Municipios',              acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY]},
	{ nombre:'producciones',                  descripcion: 'produccion',              controlador: 'Producciones',            acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getProduccionesFiltradas'} ]},
	{ nombre:'provincias',                    descripcion: 'provincia',               controlador: 'Provincias',              acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'recibos ingreso',               descripcion: 'recibo_ingreso',          controlador: 'RecibosIngresos',         acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getRecibosFiltrados'}, {nombre:'revertir recibo', descripcion: 'revertir_recibo', metodo: 'revertirRecibos'} ]},
	{ nombre:'reportes',                      descripcion: 'reporte',                 controlador: 'Reportes',                acciones: [{nombre:'ver reportes', descripcion: 'get_reportes', metodo: 'getReportes'} ]},
	{ nombre:'comprobantes fiscales',         descripcion: 'secuencia_comprobante',   controlador: 'SecuenciaComprobantes',   acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getSecuenciaComprobantesFiltrados'}, {nombre:'buscar comprobanrte por estado', descripcion: 'get_paquete_rnc_estado', metodo: 'getPaqueteRncByEstado'} ]},
	{ nombre:'suplidores',                    descripcion: 'suplidor',                controlador: 'Suplidores',              acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar nombres de suplidores', descripcion: 'get_nombres_suplidores', metodo: 'getNombresSuplidores'}, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getSuplidoresFiltrados'} ]},
	{ nombre:'tipos articulos',               descripcion: 'tipo_articulo',           controlador: 'TipoArticulos',           acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'tipos facturas',                descripcion: 'tipo_factura',            controlador: 'TipoFacturas',            acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'tipos recibos',                 descripcion: 'tipo_recibo',             controlador: 'TipoRecibos',             acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
	{ nombre:'empleados',                     descripcion: 'user',                    controlador: 'Users',                   acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getUsuariosFiltrados'} ]},
	{ nombre:'vehiculos',                     descripcion: 'vehiculo',                controlador: 'Vehiculos',               acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', descripcion: 'get_filtrados', metodo: 'getVehiculosFiltrados'}  ]}
]

G_ROLES = [
	{descripcion:'Administrador'},
	{descripcion:'Vendedor'},
	{descripcion:'Cajero'},
	{descripcion:'Chofer'},
]