PROJECT_PATH     = File.join Rails.root, "/"
PUBLIC_PATH      = File.join Rails.root, "public"
IMAGES_PATH      = File.join Rails.root, "public/img"

ENCRIPT_SECRET   = "1234567890ABCDEF"
HTTP_STATUS_CODE = Rack::Utils::SYMBOL_TO_STATUS_CODE

module HTTP_STATUS
  CONFLICT        = HTTP_STATUS_CODE[:conflict]
  NOT_FOUND       = HTTP_STATUS_CODE[:not_found]
  OK              = HTTP_STATUS_CODE[:ok]
  INTERNAL_ERROR  = HTTP_STATUS_CODE[:internal_server_error]
  UNAUTHORIZED    = HTTP_STATUS_CODE[:unauthorized]
  M_NOT_ALLOWED   = HTTP_STATUS_CODE[:method_not_allowed]


  def self.conflict
    return CONFLICT
  end

  def self.not_found
    return NOT_FOUND
  end

  def self.ok
    return OK
  end

  def self.internal_error
    return INTERNAL_ERROR
  end

  def self.unauthorized
    return UNAUTHORIZED
  end

  def self.method_not_allowed
    return M_NOT_ALLOWED
  end

end

DIAS             = ["Lunes", "Martes", "Miercoles", "Jueves",  "Viernes", "Sabado", "Domingo"]


module Identificador
  CLIENTE_ID         = "1"
  USER_ID            = "2"
  TOTAL_FACTURA      = "3"
  FECHA_EQUIVALENTE  = "4"
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
  VETERINARIA               = "veterinaria"
  MATERIA_PRIMA             = "materia_prima"
  PRODUCTO_TERMINADO        = "producto_terminado"
  OTRO                      = "otro"
  MATERIALES_DE_OFICINA     = "materiales_de_oficina"
  SERVICIOS_LEGALES         = "servicios_legales"
  SERVICIOS_CONTABLES       = "servicios_contables"
  DULCES                    = "dulces"

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

  def self.materiales_de_oficina
    return MATERIALES_DE_OFICINA
  end

  def self.servicios_legales
    return SERVICIOS_LEGALES
  end

  def self.servicios_contables
    return SERVICIOS_CONTABLES
  end

  def self.dulces
    return DULCES
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
  Enum = {
    todas: 0,
    cliente_id: 1,
    numero_comprobante: 2,
    numero_factura: 3,
    last_50: 4,
    suplidor_id: 5,
    id: 6,
  }.with_indifferent_access

  CLIENTE_ID = 'cliente_id'
  SUPLIDOR_ID = 'suplidor_id'
  NUMERO_COMPROBANTE = 'numero_comprobante'
  NUMERO_FACTURA = 'numero_factura'
  LAST_50 = 'last_50'
  ID = 'id'
  TODAS = 'todas'

  PARAMETROS = { :_0_ => TODAS, :_1_ => CLIENTE_ID, :_2_ => NUMERO_COMPROBANTE, :_3_ => NUMERO_FACTURA, :_4_ => LAST_50, :_5_ => SUPLIDOR_ID, :_6_ => ID }


  def self.get_campo_by_param(param)
    return PARAMETROS[:"_#{param}_"]
  end

  def self.parse_valor_by_param(param, valor='')

    if param == "#{Enum[:last_50]}"
      return valor

    elsif FacturasParams.params_to_parse_int.my_includes_str(param.to_i)
      return valor.to_i

    else
      return valor.upcase
    end
  end


  def self.enum
    return Enum
  end

  def self.params_to_parse_int
    return [ Enum[:cliente_id], Enum[:numero_factura], Enum[:suplidor_id], Enum[:id ] ]
  end

  def self.suplidor_id
    return CLIENTE_ID
  end

  def self.cliente_id
    return SUPLIDOR_ID
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

  def self.id
    return ID
  end

  def self.todas
    return TODAS
  end
end



module TipoReporteVentas
  VENTAS_HOY      = 'ventas_diarias'
  VENTAS_RANGO    = 'ventas_rango'
  VENTAS_CLIENTE  = 'ventas_cliente'

  def self.ventas_hoy
    return VENTAS_HOY
  end

  def self.ventas_rango
    return VENTAS_RANGO
  end

  def self.ventas_cliente
    return VENTAS_CLIENTE
  end

end

module TipoFecha
  SIN_HORA = 'sin_hora'
  CON_HORA = 'con_hora'

  def self.sin_hora
    return SIN_HORA
  end

  def self.con_hora
    return CON_HORA
  end

end

module TipoArticuloType
  VENTA_NORMAL = 'venta_normal'
  SERVICIO = 'servicio'


  def self.venta_normal
    return VENTA_NORMAL
  end

  def self.servicio
    return SERVICIO
  end

end

TIPO_ARTICULO_TYPES_VALIDOS = [ TipoArticuloType.venta_normal, TipoArticuloType.servicio ]



module TiposNotasId
  def self.credito
    @credito ||= TipoFactura.find_by(:key => 'nota_de_credito', :serie => SerieFactura.normal)&.id
  end

  def self.credito_electronica
    @credito_electronica ||= TipoFactura.find_by(:key => 'nota_de_credito', :serie => SerieFactura.electronica)&.id
  end

  def self.debito
    @debito ||= TipoFactura.find_by(:key => 'nota_de_debito', :serie => SerieFactura.normal)&.id
  end

  def self.debito_electronica
    @debito_electronica ||= TipoFactura.find_by(:key => 'nota_de_debito', :serie => SerieFactura.electronica)&.id
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
    return tipo == TiposNotasId.credito || tipo == TiposNotasId.credito_electronica ? self.credito : self.debito
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

# modulo status ==========================================
module STATUS
  ACTIVE        = 'active'
  DISABLE       = 'disable'
  DELETE        = 'delete'
  PENDING       = 'pending'
  COMPLETE      = 'complete'
  APPROVED      = 'approved'
  DISAPPROVED   = 'disapproved'

  def self.active
    return ACTIVE
  end

  def self.disable
    return DISABLE
  end

  def self.delete
    return DELETE
  end

  def self.pending
    return PENDING
  end

  def self.complete
    return COMPLETE
  end

  def self.approved
    return APPROVED
  end

  def self.disapproved
    return DISAPPROVED
  end

  def self.is_active(status)
    return status == self.active
  end

  def self.is_delete(status)
    return status == self.delete
  end

end

STATUS_VALIDOS = [ STATUS.active, STATUS.disable, STATUS.delete, STATUS.pending, STATUS.complete, STATUS.approved, STATUS.disapproved ]



PROVINCIAS_MUNICIPIOS=[
  { nombre: 'Distrito Nacional',         municipios: ['Santo Domingo Centro (DN)', 'Santo Domingo Este', 'Santo Domingo Oeste', 'Santo Domingo Norte', 'Boca Chica', 'San Antonio DE Guerra', 'Los Alcarrizos', 'Pedro Brand'] },
  { nombre: 'San Pedro de Macorís',      municipios: ['San Pedro DE Macorís', 'Los Llanos', 'Ramon Santana', 'Consuelo', 'Quisqueya', 'Guayacanes'] },
  { nombre: 'La Romana',                 municipios: ['La Romana', 'Guaymate', 'Villa Hermosa'] },
  { nombre: 'La Altagracia',             municipios: ['Higüey', 'San Rafael Del Yuma' ] },
  { nombre: 'El Seibo',                  municipios: ['El Seibo', 'Miches'] },
  { nombre: 'Hato Mayor',                municipios: ['Hato Mayor', 'Sabana De La Mar', 'El Valle'] },
  { nombre: 'Duarte',	                   municipios: ['San Francisco De Macorís', 'Arenoso', 'Castillo', 'Pimentel', 'Villa Riva', 'Las Guaranas', 'Eugenio Maria De Hostos'] },
  { nombre: 'Samaná',	                   municipios: ['Samaná', 'Sanchez', 'Las Terrenas'] },
  { nombre: 'Maria Trinidad Sánchez',	   municipios: ['Nagua', 'Cabrera', 'El Factor', 'Rio San Juan'] },
  { nombre: 'Salcedo',	                 municipios: ['Salcedo', 'Tenares', 'Villa Tapia'] },
  { nombre: 'La Vega',	                 municipios: ['La Vega', 'Constanza', 'Jarabacoa', 'Jima Abajo'] },
  { nombre: 'Monseñor Nouel',	           municipios: ['Bonao', 'Maimon', 'Piedra Blanca'] },
  { nombre: 'Sánchez Ramirez',	         municipios: ['Cotui', 'Cevicos', 'Fantino', 'La Mata'] },
  { nombre: 'Santiago',	                 municipios: ['Santiago', 'Bisono', 'Janico', 'Licey Al Medio', 'San Jose De Las Matas', 'Tamboril', 'Villa Gonzalez', 'Puñal', 'Sabana Iglesia'] },
  { nombre: 'Espaillat',	               municipios: ['Moca', 'Cayetano Germosen', 'Gaspar Hernandez', 'Jamao Al Norte'] },
  { nombre: 'Puerto Plata',	             municipios: ['Puerto plata', 'altamira', 'guananico', 'imbert', 'Los hidalgos', 'luperon', 'sosua', 'Villa isabela', 'Villa montellano'] },
  { nombre: 'Valverde',	                 municipios: ['Mao', 'Esperanza', 'Laguna Salada'] },
  { nombre: 'Monte Cristi',	             municipios: ['Monte Cristi', 'Castañuelas', 'Guayubin', 'Las Matas De Santa Cruz', 'Pepillo Salcedo', 'Villa Vasquez'] },
  { nombre: 'Dajabón',	                 municipios: ['Dajabón', 'Loma De Cabrera', 'Partido', 'Restauración', 'El Pino'] },
  { nombre: 'Santiago Rodríguez',	       municipios: ['San Ignacio De Sabaneta', 'Villa Los Almacigos', 'Monción'] },
  { nombre: 'Azua',	                     municipios: ['Azua', 'Las Charcas', 'Las Yayas De Viajama', 'Padre Las Casas', 'Peralta', 'Sabana Yegua', 'Pueblo Viejo', 'Tabara Arriba', 'Guayabal', 'Estebania'] },
  { nombre: 'San Juan de la Maguana',	   municipios: ['San Juan', 'Bohechio', 'El Cercado', 'Juan De Herrera', 'Las Matas De Farfan', 'Vallejuelo'] },
  { nombre: 'Elías Piña',	               municipios: ['Comendador', 'Banica', 'El Llano', 'Hondo Valle', 'Pedro Santana', 'Juan Santiago'] },
  { nombre: 'Barahona',	                 municipios: ['Barahona', 'Cabral', 'Enriquillo', 'Paraiso', 'Vicente Noble', 'El Peñón', 'La Cienaga', 'Fundación', 'Las Salinas', 'Polo', 'Jaquimeyes'] },
  { nombre: 'Bahoruco',	                 municipios: ['Neiba', 'Galvan', 'Tamayo', 'Villa Jaragua', 'Los Rios'] },
  { nombre: 'Independencia',	           municipios: ['Jimaní', 'Duverge', 'La Descubierta', 'Postrer Rio', 'Cristobal', 'Mella'] },
  { nombre: 'Perdenales',	               municipios: ['Pedernales', 'Oviedo'] },
  { nombre: 'San Cristóbal',	           municipios: ['San Cristobal', 'Sabana Grande De Palenque', 'Bajos De Haina', 'Cambita Garabitos', 'Villa Altagracia', 'Yaguate', 'San Gregorio De Nigua', 'Los Cacaos'] },
  { nombre: 'Monte Plata',	             municipios: ['Monte Plata', 'Bayaguana', 'Sabana Grande De Boya', 'Yamasa', 'Peralvillo'] },
  { nombre: 'San José de Ocoa',	         municipios: ['San Jose De Ocoa', 'Sabana Larga', 'Rancho Arriba'] },
  { nombre: 'Peravia',	                 municipios: ['Bani', 'Nizao'] }
]

G_CATALOGO_DEFAULT = [
  # 1
  {descripcion: "ACTIVOS",              origen: "D", tipo: "R", cuentas_contables: [
    { descripcion: "EFECTIVO CAJA Y BANCO",                        is_control: true, origen: "D", tipo: "R", cuentas_contables: [
      { descripcion: "EFECTIVO EN CAJA",                                    is_control: true, origen: "D", tipo: "R" },
      { descripcion: "EFECTIVO EN BANCO MONEDA NACIONAL",                   is_control: true, origen: "D", tipo: "R" },
      { descripcion: "EFECTIVO EN BANCO MONEDA EXTRANJERA",                 is_control: true, origen: "D", tipo: "R" },
    ]},
    { descripcion: "CUENTAS POR COBRAR",                           is_control: true, origen: "D", tipo: "R", cuentas_contables: [
      { descripcion: "CUENTAS POR COBRAR CLIENTES",                         is_control: true, origen: "D", tipo: "R" },
      { descripcion: "CUENTAS POR COBRAR EMPLEADOS",                        is_control: true, origen: "D", tipo: "R" },
    ]},
    { descripcion: "OTRAS CUENTAS POR COBRAR",                     is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
    { descripcion: "INVENTARIOS",                                  is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
    { descripcion: "PROPIEDAD PLANTA Y EQUIPO",                    is_control: true, origen: "D", tipo: "R", cuentas_contables: [
      { descripcion: "EQUIPOS DE OFICINA",                                  is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
      { descripcion: "EQUIPO DE COMPUTACION Y COMUNICACION",                is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
      { descripcion: "EQUIPOS DE TRANSPORTE",                               is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
      { descripcion: "EQUIPOS DE ELECTRICIDAD",                             is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
      { descripcion: "DEPRECIACION ACUMULADA",                              is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    ]},
    { descripcion: "ACTIVOS DIFERIDOS",                            is_control: true, origen: "D", tipo: "R", cuentas_contables: [
      { descripcion: "GASTOS PAGADOS POR ANTICIPADO",                       is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
      { descripcion: "OTROS ACTIVOS",                                       is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
    ]},
  ]},

  # 2
  {descripcion: "PASIVOS",              origen: "C", tipo: "R", cuentas_contables: [
    { descripcion: "CUENTAS POR PAGAR",                            is_control: true, origen: "C", tipo: "R", cuentas_contables: [
      { descripcion: "CUENTAS POR PAGAR PROVEEDORES MONEDA NACIONAL",       is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      { descripcion: "CUENTAS POR PAGAR PROVEEDORES MONEDA EXTRANJERA",     is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      { descripcion: "AVANCES",                                             is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    ]},
    { descripcion: "OTRAS CUENTAS POR PAGAR",                      is_control: true, origen: "C", tipo: "R", cuentas_contables: [
      { descripcion: "OTRAS CUENTAS POR PAGAR",                             is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      { descripcion: "CUENTAS POR PAGAR EMPLEADOS",                         is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    ]},
    { descripcion: "OTROS PASIVOS CORRIENTES",                     is_control: true, origen: "C", tipo: "R", cuentas_contables: [
      { descripcion: "IMPUESTOS Y GRAVAMENES",                              is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      { descripcion: "RETENCIONES POR PAGAR",                               is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      { descripcion: "RETENCIONES A EMPLEADOS",                             is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    ]},
    { descripcion: "ACUMULACIONES POR PAGAR",                      is_control: true, origen: "C", tipo: "R", cuentas_contables: [
      { descripcion: "PROVISIONES",                                         is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    ]},
  ]},

  # 3
  {descripcion: "CAPITAL SOCIAL",       origen: "C", tipo: "R", cuentas_contables: [
    { descripcion: "CAPITAL SUSCRITO Y PAGADO",                    is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    { descripcion: "GANANCIA Y/O PERDIDA",                         is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    { descripcion: "GANANCIA ACUMULADA",                           is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
  ]},

  # 4
  {descripcion: "VENTAS",               origen: "C", tipo: "N", cuentas_contables: [
    { descripcion: "VENTAS GENERALES",                             is_control: true, origen: "C", tipo: "N", cuentas_contables: [] },
    { descripcion: "DESCUENTOS SOBRE VENTAS GENERALES",            is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
		]},

		# 5
		{descripcion: "COMPRAS",              origen: "D", tipo: "N", cuentas_contables: [
			{ descripcion: "COMPRAS GENERALES",                          is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
			{ descripcion: "DESCUENTOS SOBRE COMPRAS GENERALES",                   is_control: true, origen: "C", tipo: "N", cuentas_contables: [] },
  ]},

  # 6
  {descripcion: "GASTOS",               origen: "D", tipo: "N", cuentas_contables: [
    { descripcion: "GASTOS ADMINISTRATIVOS",                       is_control: true, origen: "D", tipo: "N", cuentas_contables: [
      { descripcion: "GASTOS DE PERSONAL ADMINISTRATIVO",                   is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "HONORARIOS",                                          is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "ALQUILERES",                                          is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "SERVICIOS",                                           is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "MANTENIMIENTO Y REPARACIONES",                        is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "GASTOS LEGALES",                                      is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "GASTOS DE VEHICULOS",                                 is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "GASTO DEPRECIACION ACUMULADA",                        is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "AMORTIZACIONES",                                      is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "DIVERSOS ADMINISTRATIVO",                             is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
    ]},
    { descripcion: "GASTOS DE VENTA",                              is_control: true, origen: "D", tipo: "N", cuentas_contables: [
      { descripcion: "GASTOS PERSONAL DE VENTAS",                           is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "GASTOS LEGALES",                                      is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "GASTOS DE VEHICULOS",                                 is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "COMUNICACION Y REDES PUNTO DE VENTA",                 is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "PUBLICIDAD, PROPAGANDA Y PROMOCIONES",                is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "ADECUACIONES E INSTALACIONES",                        is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "GASTOS DE VIAJES",                                    is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "AMORTIZACION",                                        is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "GASTOS DEPRECIACION ACUMULADA",                       is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "MATERIAL GASTABLE PARA VENTA",                        is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
      { descripcion: "DIVERSOS VENTAS",                                     is_control: true, origen: "D", tipo: "N", cuentas_contables: [] },
    ]},
    { descripcion: "GASTOS FINANCIEROS",                           is_control: true, origen: "D", tipo: "N", cuentas_contables: [] }
  ]},
]

G_CONFIG_ENTIDAD_CUENTA = [
  { descripcion: 'CXC clientes',                      key: 'cobrar',             entidad: 'cliente',          is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'CUENTAS POR COBRAR CLIENTES' },
  { descripcion: 'CXP suplidores moneda nacional',    key: 'pagar',              entidad: 'suplidor',         is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'CUENTAS POR PAGAR PROVEEDORES MONEDA NACIONAL' },
  { descripcion: 'CXP suplidores moneda extranjera',  key: 'pagar',              entidad: 'suplidor',         is_nacional: false,   has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'CUENTAS POR PAGAR PROVEEDORES MONEDA EXTRANJERA' },
  { descripcion: 'CXC empleados',                     key: 'cobrar',             entidad: 'user',             is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'CUENTAS POR COBRAR EMPLEADOS' },
  { descripcion: 'CXP empleados',                     key: 'pagar',              entidad: 'user',             is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'CUENTAS POR PAGAR EMPLEADOS' },
  { descripcion: 'Retenciones empleados',             key: 'retencion',          entidad: 'user',             is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'RETENCIONES A EMPLEADOS' },
  { descripcion: 'Efectivo banco moneda nacional',    key: 'efectivo_banco',     entidad: 'cuenta_bancaria',  is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'EFECTIVO EN BANCO MONEDA NACIONAL' },
  { descripcion: 'Efectivo banco moneda extranjera',  key: 'efectivo_banco',     entidad: 'cuenta_bancaria',  is_nacional: false,   has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'EFECTIVO EN BANCO MONEDA EXTRANJERA' },
  { descripcion: 'Inventario',                        key: 'inventario',         entidad: 'articulo',         is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: true,   cuenta_contable_descripcion: 'INVENTARIOS' },
  { descripcion: 'Ventas',                            key: 'ventas',             entidad: 'articulo',         is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: true,   cuenta_contable_descripcion: 'VENTAS GENERALES' },
  { descripcion: 'Descuentos de ventas',              key: 'descuento_ventas',   entidad: 'articulo',         is_nacional: true,    has_comun: false, is_control: false, has_individual: false, has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'DESCUENTOS SOBRE VENTAS GENERALES' },
  { descripcion: 'Compras',                           key: 'compras',            entidad: 'articulo',         is_nacional: true,    has_comun: true,  is_control: true,  has_individual: true,  has_categoria: true,  has_sub_categoria: true,   cuenta_contable_descripcion: 'COMPRAS GENERALES' },
  { descripcion: 'Descuentos de compras',             key: 'descuento_compras',  entidad: 'articulo',         is_nacional: true,    has_comun: false, is_control: false, has_individual: false, has_categoria: true,  has_sub_categoria: false,  cuenta_contable_descripcion: 'DESCUENTOS SOBRE COMPRAS GENERALES' },
]
