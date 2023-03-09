
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
  {descripcion: "ACTIVOS",                origen: "D" tipo: "R", cuentas_contables: [
    { descripcion: "EFECTIVO CAJA Y BANCO",              is_control: true, origen: "D", tipo: "R" }
    { descripcion: "CAJA",                               is_control: true, origen: "D", tipo: "R" }
    { descripcion: "BANCO",                              is_control: true, origen: "D", tipo: "R" }
    { descripcion: "BANCO MONEDA NACIONAL",              is_control: true, origen: "D", tipo: "R" }
    { descripcion: "BANCO MONEDA EXTRANJERA",            is_control: true, origen: "D", tipo: "R" }
    { descripcion: "TRANSFERENCIAS NOMINA",              is_control: true, origen: "D", tipo: "R" }
    { descripcion: "CUENTAS X COBRAR",                   is_control: true, origen: "D", tipo: "R" }
    { descripcion: "CUENTAS X COBRAR CLIENTES",          is_control: true, origen: "D", tipo: "R" }
    { descripcion: "CTA X COBRAR CIAS RELACIONADAS",     is_control: true, origen: "D", tipo: "R" }
    { descripcion: "OTRAS CUENTAS X COBRAR",             is_control: true, origen: "D", tipo: "R" }
    { descripcion: "ANTICIPOS Y AVANCES",                is_control: true, origen: "D", tipo: "R" }
    { descripcion: "CXC RECLAMACIONES",                  is_control: true, origen: "D", tipo: "R" }
    { descripcion: "OTRAS CUENTAS X COBRAR",             is_control: true, origen: "D", tipo: "R" }
    { descripcion: "INVENTARIOS",                        is_control: true, origen: "D", tipo: "R" }
    { descripcion: "INVENTARIO ROLLOS DE PAPEL",         is_control: true, origen: "D", tipo: "R" }
    { descripcion: "PROPIEDAD PLANTA Y EQUIPO",          is_control: true, origen: "D", tipo: "R" }
    { descripcion: "EQUIPOS DE OFICINA",                 is_control: true, origen: "D", tipo: "R" }
    { descripcion: "EQUIPO DE COMPUTACION Y COMUNIC",    is_control: true, origen: "D", tipo: "R" }
    { descripcion: "EQUIPOS DE TRANSPORTE",              is_control: true, origen: "D", tipo: "R" }
    { descripcion: "EQUIPOS DE ELECTRICIDAD",            is_control: true, origen: "D", tipo: "R" }
    { descripcion: "ESTUDIO Y EQUIPOS DE SORTEO",        is_control: true, origen: "D", tipo: "R" }
    { descripcion: "DEPRECIACION ACUMULADA",             is_control: true, origen: "C", tipo: "R" }
    { descripcion: "MEJORA EN PROPIEDAD ARRENDADA",      is_control: true, origen: "D", tipo: "R" }
    { descripcion: "ACTIVOS DIFERIDOS",                  is_control: true, origen: "D", tipo: "R" }
    { descripcion: "GASTOS PAGADOS X ANTICIPADOS",       is_control: true, origen: "D", tipo: "R" }
    { descripcion: "OTROS ACTIVOS",                      is_control: true, origen: "D", tipo: "R" }
  ]},

  # 2
  {descripcion: "PASIVOS",                origen: "C" tipo: "R", cuentas_contables: [
    { descripcion: "CUENTAS POR PAGAR",                  is_control: true, origen: "C", tipo: "R" }
    { descripcion: "CUENTAS POR PAGAR PROVEEDORES",      is_control: true, origen: "C", tipo: "R" }
    { descripcion: "CUENTAS X PAGAR PROVEEDORES EXT",    is_control: true, origen: "C", tipo: "R" }
    { descripcion: "AVANCES",                            is_control: true, origen: "C", tipo: "R" }
    { descripcion: "OTRAS CUENTAS X PAGAR",              is_control: true, origen: "C", tipo: "R" }
    { descripcion: "OTRAS CUENTAS X PAGAR",              is_control: true, origen: "C", tipo: "R" }
    { descripcion: "CUENTAS X PAGAR EMPLEADOS",          is_control: true, origen: "C", tipo: "R" }
    { descripcion: "OTROS PASIVOS CORRIENTES",           is_control: true, origen: "C", tipo: "R" }
    { descripcion: "IMPUESTOS Y GRAVAMENES",             is_control: true, origen: "C", tipo: "R" }
    { descripcion: "RETENCIONES X PAGAR",                is_control: true, origen: "C", tipo: "R" }
    { descripcion: "RETENCIONES A EMPLEADOS",            is_control: true, origen: "C", tipo: "R" }
    { descripcion: "RETENC COOP, AFP, SFS",              is_control: true, origen: "C", tipo: "R" }
    { descripcion: "ACUMULACIONES X PAGAR",              is_control: true, origen: "C", tipo: "R" }
    { descripcion: "PROVISIONES",                        is_control: true, origen: "C", tipo: "R" }
  ]},

  # 3
  {descripcion: "CAPITAL SOCIAL",         origen: "C" tipo: "R", cuentas_contables: [
    { descripcion: "CAPITAL SUSCRITO Y PAGADO",          is_control: true, origen: "C", tipo: "R" }
    { descripcion: "CAPITAL SUSCRITO Y PAGADO",          is_control: true, origen: "C", tipo: "R" }
    { descripcion: "UTILIDADES ACUMULADAS",              is_control: true, origen: "C", tipo: "R" }
    { descripcion: "RESULTADO DEL  EJERCICIO",           is_control: true, origen: "C", tipo: "R" }
  ]},

  # 4
  {descripcion: "INGRESOS",               origen: "C" tipo: "N", cuentas_contables: [
    { descripcion: "INGRESOS OPERACIONALES",             is_control: true, origen: "C", tipo: "N" }
  ]},

  # 5
  {descripcion: "COSTO DE VENTAS",        origen: "D" tipo: "N", cuentas_contables: [
    { descripcion: "COSTOS OPERACIONALES",               is_control: true, origen: "D", tipo: "N" }
    { descripcion: "COSTO EN  VENTAS",                   is_control: true, origen: "D", tipo: "N" }
  ]},

  # 6
  {descripcion: "GASTOS OPERACIONALES",   origen: "D" tipo: "N", cuentas_contables: [
    { descripcion: "GASTOS  ADMINISTRATIVOS",            is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS DE PERSONAL ADM",             is_control: true, origen: "D", tipo: "N" }
    { descripcion: "HONORARIOS",                         is_control: true, origen: "D", tipo: "N" }
    { descripcion: "ALQUILERES",                         is_control: true, origen: "D", tipo: "N" }
    { descripcion: "SERVICIOS",                          is_control: true, origen: "D", tipo: "N" }
    { descripcion: "MANTENIMIENTO Y REPARACIONES",       is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS LEGALES",                     is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS DE VEHICULOS",                is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTO DEPRECIACION ACUMULADA",       is_control: true, origen: "D", tipo: "N" }
    { descripcion: "AMORTIZACIONES",                     is_control: true, origen: "D", tipo: "N" }
    { descripcion: "DIVERSOS ADMTVOS",                   is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS DE VENTA",                    is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS  PERSONAL  DE VENTAS",        is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS LEGALES",                     is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS DE VEHICULOS",                is_control: true, origen: "D", tipo: "N" }
    { descripcion: "COMUNICAICON Y REDES PUNTO DE V",    is_control: true, origen: "D", tipo: "N" }
    { descripcion: "PUBLICIDAD, PROPAGANDA Y PROMOC",    is_control: true, origen: "D", tipo: "N" }
    { descripcion: "ADECUACIONES E INSTALACIONES",       is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS DE VIAJES",                   is_control: true, origen: "D", tipo: "N" }
    { descripcion: "AMORTIZACION",                       is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS DEPRECIACION ACUMULADA",      is_control: true, origen: "D", tipo: "N" }
    { descripcion: "MATERIAL GASTABLE P.V",              is_control: true, origen: "D", tipo: "N" }
    { descripcion: "DIVERSOS VENTAS",                    is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTO  SORTEO",                      is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTOS PERSONAL SORTEO",             is_control: true, origen: "D", tipo: "N" }
    { descripcion: "HONORARIOS",                         is_control: true, origen: "D", tipo: "N" }
    { descripcion: "ARRENDAMIENTOS",                     is_control: true, origen: "D", tipo: "N" }
    { descripcion: "MANTENIMIENTO Y REPARACIONES",       is_control: true, origen: "D", tipo: "N" }
    { descripcion: "GASTO DEPRECIACION ACUMULADA",       is_control: true, origen: "D", tipo: "N" }
    { descripcion: "DIVERSOS SORTEOS",                   is_control: true, origen: "D", tipo: "N" }

  ]},
]

# CTA	       DESCRIP	                              ORIGEN   IS_CONTROL     TIPO

# 1          ACTIVOS                                   D        	T          R
# 11         EFECTIVO CAJA Y BANCO                     D        	T          R
# 11101      CAJA                                      D        	T          R
# 11102      BANCO                                     D        	T          R
# 1110201    BANCO MONEDA NACIONAL                     D        	T          R
# 11103      BANCO MONEDA EXTRANJERA                   D        	T          R
# 11104      TRANSFERENCIAS NOMINA                     D        	T          R
# 12         CUENTAS X COBRAR                          D        	T          R
# 12101      CUENTAS X COBRAR CLIENTES                 D        	T          R
# 12103      CTA X COBRAR CIAS RELACIONADAS            D        	T          R
# 13         OTRAS CUENTAS X COBRAR                    D        	T          R
# 13101      ANTICIPOS Y AVANCES                       D        	T          R
# 13102      CXC RECLAMACIONES                         D        	T          R
# 13103      OTRAS CUENTAS X COBRAR                    D        	T          R
# 14         INVENTARIOS                               D        	T          R
# 14101      INVENTARIO ROLLOS DE PAPEL                D        	T          R
# 15         PROPIEDAD PLANTA Y EQUIPO                 D        	T          R
# 15101      EQUIPOS DE OFICINA                        D        	T          R
# 15102      EQUIPO DE COMPUTACION Y COMUNIC           D        	T          R
# 15103      EQUIPOS DE TRANSPORTE                     D        	T          R
# 15104      EQUIPOS DE ELECTRICIDAD                   D        	T          R
# 15105      ESTUDIO Y EQUIPOS DE SORTEO               D        	T          R
# 15106      DEPRECIACION ACUMULADA                    C        	T          R
# 15107      MEJORA EN PROPIEDAD ARRENDADA             D        	T          R
# 16         ACTIVOS DIFERIDOS                         D        	T          R
# 16101      GASTOS PAGADOS X ANTICIPADOS              D        	T          R
# 16102      OTROS ACTIVOS                             D        	T          R

# 2          PASIVOS                                   C        	T          R
# 22         CUENTAS POR PAGAR                         C        	T          R
# 22101      CUENTAS POR PAGAR PROVEEDORES             C        	T          R
# 22102      CUENTAS X PAGAR PROVEEDORES EXT           C        	T          R
# 22103      AVANCES                                   C        	T          R
# 23         OTRAS CUENTAS X PAGAR                     C        	T          R
# 23101      OTRAS CUENTAS X PAGAR                     C        	T          R
# 23102      CUENTAS X PAGAR EMPLEADOS                 C        	T          R
# 24         OTROS PASIVOS CORRIENTES                  C        	T          R
# 24101      IMPUESTOS Y GRAVAMENES                    C        	T          R
# 24102      RETENCIONES X PAGAR                       C        	T          R
# 24103      RETENCIONES A EMPLEADOS                   C        	T          R
# 241030     RETENC COOP, AFP, SFS                     C        	T          R
# 27         ACUMULACIONES X PAGAR                     C        	T          R
# 27101      PROVISIONES                               C        	T          R

# 3          CAPITAL SOCIAL                            C        	T          R
# 31         CAPITAL SUSCRITO Y PAGADO                 C        	T          R
# 31101      CAPITAL SUSCRITO Y PAGADO                 C        	T          R
# 32         UTILIDADES ACUMULADAS                     C        	T          R
# 32101      RESULTADO DEL  EJERCICIO                  C        	T          R

# 4          INGRESOS                                  C        	T          N
# 41         INGRESOS OPERACIONALES                    C        	T          N

# 5          COSTO DE VENTAS                           D        	T          N
# 51         COSTOS OPERACIONALES                      D        	T          N
# 51101      COSTO EN  VENTAS                          D        	T          N

# 6          GASTOS OPERACIONALES                      D        	T          N
# 61         GASTOS  ADMINISTRATIVOS                   D        	T          N
# 61101      GASTOS DE PERSONAL ADM.                   D        	T          N
# 61102      HONORARIOS                                D        	T          N
# 61103      ALQUILERES                                D        	T          N
# 61104      SERVICIOS                                 D        	T          N
# 61105      MANTENIMIENTO Y REPARACIONES              D        	T          N
# 61106      GASTOS LEGALES                            D        	T          N
# 61107      GASTOS DE VEHICULOS                       D        	T          N
# 61108      GASTO DEPRECIACION ACUMULADA              D        	T          N
# 61109      AMORTIZACIONES                            D        	T          N
# 61200      DIVERSOS ADMTVOS                          D        	T          N
# 62         GASTOS DE VENTA                           D        	T          N
# 62101      GASTOS  PERSONAL  DE VENTAS               D        	T          N
# 62103      GASTOS LEGALES                            D        	T          N
# 62104      GASTOS DE VEHICULOS                       D        	T          N
# 62105      COMUNICAICON Y REDES PUNTO DE V           D        	T          N
# 62106      PUBLICIDAD, PROPAGANDA Y PROMOC           D        	T          N
# 62108      ADECUACIONES E INSTALACIONES              D        	T          N
# 62109      GASTOS DE VIAJES                          D        	T          N
# 62201      AMORTIZACION                              D        	T          N
# 62202      GASTOS DEPRECIACION ACUMULADA             D        	T          N
# 62203      MATERIAL GASTABLE P.V                     D        	T          N
# 62910      DIVERSOS VENTAS                           D        	T          N
# 63         GASTO  SORTEO                             D        	T          N
# 63101      GASTOS PERSONAL SORTEO                    D        	T          N
# 63102      HONORARIOS                                D        	T          N
# 63103      ARRENDAMIENTOS                            D        	T          N
# 63105      MANTENIMIENTO Y REPARACIONES              D        	T          N
# 63106      GASTO DEPRECIACION ACUMULADA              D        	T          N
# 63200      DIVERSOS SORTEOS                          D        	T          N