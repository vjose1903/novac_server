
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

G_ACCIONES = [
	{nombre: 'create'},
	{nombre: 'read'},
	{nombre: 'update'},
	{nombre: 'destroy'},

	{nombre: 'get_stock'},
	{nombre: 'checkIfExcede'},
]

G_PERMISOS = [
	{nombre: 'articulo',                  controlador: 'Articulos'},
	{nombre: 'conduce',                   controlador: 'CabeceraConduces'},
	{nombre: 'factura',                   controlador: 'CabeceraFacturas'},
	{nombre: 'cliente',                   controlador: 'Clientes'},
	{nombre: 'costo_flete',               controlador: 'CostoFletes'},
	{nombre: 'cuadre_caja',               controlador: 'CuadreCajas'},
	{nombre: 'detalle_factura',           controlador: 'DetalleFacturas'},
	{nombre: 'historico_produccion',      controlador: 'HistoricoProduccions'},
	{nombre: 'imagen',                    controlador: 'Imagenes'},
	{nombre: 'mantenimiento_articulo',    controlador: 'MantenimientoArticulos'},
	{nombre: 'marca',                     controlador: 'Marcas'},
	{nombre: 'modelo',                    controlador: 'Modelos'},
	{nombre: 'movimiento_inventario',     controlador: 'MovimientosInventarios'},
	{nombre: 'municipio',                 controlador: 'Municipios'},
	{nombre: 'produccion',                controlador: 'Producciones'},
	{nombre: 'provincia',                 controlador: 'Provincias'},
	{nombre: 'recibo_ingreso',            controlador: 'RecibosIngresos'},
	{nombre: 'reporte',                   controlador: 'Reportes'},
	{nombre: 'secuencia_comprobante',     controlador: 'SecuenciaComprobantes'},
	{nombre: 'suplidor',                  controlador: 'Suplidores'},
	{nombre: 'tipo_articulo',             controlador: 'TipoArticulos'},
	{nombre: 'tipo_factura',              controlador: 'TipoFacturas'},
	{nombre: 'tipo_recibo',               controlador: 'TipoRecibos'},
	{nombre: 'user',                      controlador: 'Users'},
	{nombre: 'vehiculo',                  controlador: 'Vehiculos'},
]