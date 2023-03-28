
PROJECT_PATH     = File.join Rails.root, "/"
PUBLIC_PATH      = File.join Rails.root, "public"
IMAGES_PATH      = File.join Rails.root, "public/img"

ENCRIPT_SECRET   = "1234567890ABCDEF"
HTTP_STATUS_CODE = Rack::Utils::SYMBOL_TO_STATUS_CODE


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

  CLIENTE_ID = "cliente_id"
  SUPLIDOR_ID = "suplidor_id"
  NUMERO_COMPROBANTE = "numero_comprobante"
  NUMERO_FACTURA = "numero_factura"
  LAST_50 = "last_50"
  TODAS = "todas"

  PARAMETROS = { :_0_ => TODAS, :_1_ => CLIENTE_ID, :_2_ => NUMERO_COMPROBANTE, :_3_ => NUMERO_FACTURA, :_4_ => LAST_50, :_5_ => SUPLIDOR_ID }

  def self.get_campo_by_param(param)
    return PARAMETROS[:"_#{param}_"]
  end

  def self.parse_valor_by_param(param, valor=nil)
    valor = param == "1" || param == "3" || param == "5" ? valor.to_i : valor.upcase unless param == "4"
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

  def self.get_id(tipo)
    return tipo == TiposNotas.credito ? self.credito : self.debito
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


module TiposFacturasDescripcion
  FACTURA_SIN_COMPROBANTE = "Factura sin comprobante"
  FACTURA_CON_VALOR_FISCAL = "Factura con valor fiscal"
  FACTURA_DE_CONSUMO = "Factura de consumo"
  NOTA_DE_DEBITO = "Nota de debito"
  NOTA_DE_CREDITO = "Nota de credito"
  COMPROBANTE_DE_COMPRAS = "Comprobante de compras"
  REGISTRO_DE_UNICO_INGRESO = "Registro de unico ingreso"
  COMPROBANTE_PARA_GASTOS_MENORES = "Comprobante para gastos menores"
  COMPROBANTE_DE_REGIMEN_ESPECIALES = "Comprobante de regimen especiales"
  COMPROBANTE_GUBERNAMENTAL = "Comprobante gubernamental"
  COMPROBANTE_PARA_EXPORTACIONES = "Comprobante para exportaciones"
  COMPROBANTES_PARA_PAGO_AL_EXTERIOR = "Comprobantes para pago al exterior"
  VENTA_CONTADO = "Venta Contado"
  COMPRA = "Compra"
  CONDUCE = "Conduce"
  PRODUCCION = "Produccion"
  RECIBO_INGRESO = "Recibo_ingreso"
  VENTA_CREDITO = "Venta Credito"
  PRE_VENTA = "pre_venta"
  COTIZACION = "cotizacion"

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

  def self.pre_venta
    return PRE_VENTA
  end

  def self.cotizacion
    return COTIZACION
  end

end


G_CATALOGO_DEFAULT = [
  # 1
  {descripcion: "ACTIVOS",                origen: "D", tipo: "R", cuentas_contables: [
    { descripcion: "EFECTIVO CAJA Y BANCO",                        is_control: true, origen: "D", tipo: "R", cuentas_contables: [
        { descripcion: "EFECTIVO EN CAJA",                                    is_control: true, origen: "D", tipo: "R" },
        { descripcion: "EFECTIVO EN BANCO MONEDA NACIONAL",                   is_control: true, origen: "D", tipo: "R" },
        { descripcion: "EFECTIVO EN BANCO MONEDA EXTRANJERA",                 is_control: true, origen: "D", tipo: "R" },
        { descripcion: "TRANSFERENCIAS NOMINA",                               is_control: true, origen: "D", tipo: "R" },
      ]
    },
    { descripcion: "CUENTAS POR COBRAR",                           is_control: true, origen: "D", tipo: "R", cuentas_contables: [
        { descripcion: "CUENTAS POR COBRAR CLIENTES",                         is_control: true, origen: "D", tipo: "R" },
        { descripcion: "CUENTAS POR COBRAR EMPLEADOS",                        is_control: true, origen: "D", tipo: "R" },
      ]
    },
    { descripcion: "OTRAS CUENTAS POR COBRAR",                     is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
    { descripcion: "INVENTARIOS",                                  is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
    { descripcion: "PROPIEDAD PLANTA Y EQUIPO",                    is_control: true, origen: "D", tipo: "R", cuentas_contables: [
        { descripcion: "EQUIPOS DE OFICINA",                                  is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
        { descripcion: "EQUIPO DE COMPUTACION Y COMUNICACION",                is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
        { descripcion: "EQUIPOS DE TRANSPORTE",                               is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
        { descripcion: "EQUIPOS DE ELECTRICIDAD",                             is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
        { descripcion: "DEPRECIACION ACUMULADA",                              is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      ]
    },
    { descripcion: "ACTIVOS DIFERIDOS",                            is_control: true, origen: "D", tipo: "R", cuentas_contables: [
        { descripcion: "GASTOS PAGADOS POR ANTICIPADO",                       is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
        { descripcion: "OTROS ACTIVOS",                                       is_control: true, origen: "D", tipo: "R", cuentas_contables: [] },
      ]
    },
  ]},

  # 2
  {descripcion: "PASIVOS",                origen: "C", tipo: "R", cuentas_contables: [
    { descripcion: "CUENTAS POR PAGAR",                            is_control: true, origen: "C", tipo: "R", cuentas_contables: [
        { descripcion: "CUENTAS POR PAGAR PROVEEDORES NACIONALES",            is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
        { descripcion: "CUENTAS POR PAGAR PROVEEDORES EXTRANJEROS",           is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
        { descripcion: "AVANCES",                                             is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      ]
    },
    { descripcion: "OTRAS CUENTAS POR PAGAR",                      is_control: true, origen: "C", tipo: "R", cuentas_contables: [
        { descripcion: "OTRAS CUENTAS POR PAGAR",                             is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
        { descripcion: "CUENTAS POR PAGAR EMPLEADOS",                         is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      ]
    },
    { descripcion: "OTROS PASIVOS CORRIENTES",                     is_control: true, origen: "C", tipo: "R", cuentas_contables: [
        { descripcion: "IMPUESTOS Y GRAVAMENES",                              is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
        { descripcion: "RETENCIONES POR PAGAR",                               is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
        { descripcion: "RETENCIONES A EMPLEADOS",                             is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      ]
    },
    { descripcion: "ACUMULACIONES POR PAGAR",                      is_control: true, origen: "C", tipo: "R", cuentas_contables: [
        { descripcion: "PROVISIONES",                                         is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
      ]
    },
  ]},

  # 3
  {descripcion: "CAPITAL SOCIAL",         origen: "C", tipo: "R", cuentas_contables: [
    { descripcion: "CAPITAL SUSCRITO Y PAGADO",                    is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    { descripcion: "GANANCIA Y/O PERDIDA",                         is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
    { descripcion: "GANANCIA ACUMULADA",                           is_control: true, origen: "C", tipo: "R", cuentas_contables: [] },
  ]},

  # 4
  {descripcion: "INGRESOS",               origen: "C", tipo: "N", cuentas_contables: [] },

  # 5
  {descripcion: "COSTOS",        origen: "D", tipo: "N", cuentas_contables: [] },

  # 6
  {descripcion: "GASTOS",   origen: "D", tipo: "N", cuentas_contables: [
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
      ]
    },
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
      ]
    },
    { descripcion: "GASTOS FINANCIEROS",                           is_control: true, origen: "D", tipo: "N", cuentas_contables: [] }
  ]},
]

G_CONFIG_ENTIDAD_CUENTA = [
  { descripcion: 'CXC clientes',                 entidad:'cliente',            cuenta_contable_descripcion: 'CUENTAS POR COBRAR CLIENTES' },
  { descripcion: 'CXP suplidores nacionales',    entidad:'suplidor',           cuenta_contable_descripcion: 'CUENTAS POR PAGAR PROVEEDORES NACIONALES' },
  { descripcion: 'CXP suplidores extranjeros',   entidad:'suplidor',           cuenta_contable_descripcion: 'CUENTAS POR PAGAR PROVEEDORES EXTRANJEROS' },
  { descripcion: 'CXC empleados',                entidad:'user',               cuenta_contable_descripcion: 'CUENTAS POR COBRAR EMPLEADOS' },
  { descripcion: 'CXP empleados',                entidad:'user',               cuenta_contable_descripcion: 'CUENTAS POR PAGAR EMPLEADOS' },
  { descripcion: 'Retenciones empleados',        entidad:'user',               cuenta_contable_descripcion: 'RETENCIONES A EMPLEADOS' },
  { descripcion: 'Efectivo banco nacional',      entidad:'cuenta_bancaria',    cuenta_contable_descripcion: 'EFECTIVO EN BANCO MONEDA NACIONAL' },
  { descripcion: 'Efectivo banco extranjero',    entidad:'cuenta_bancaria',    cuenta_contable_descripcion: 'EFECTIVO EN BANCO MONEDA EXTRANJERA' },
  { descripcion: 'Inventario',                   entidad:'inventario',         cuenta_contable_descripcion: 'INVENTARIOS' },
]