PROJECT_PATH     = File.join Rails.root, "/"
PUBLIC_PATH      = File.join Rails.root, "public"
IMAGES_PATH      = File.join Rails.root, "public/img"
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

module TipoCxC
  CLIENTE                     = '1'
  ANTIGUEDAD_SALDO_DETALLADO  = '2'
  ANTIGUEDAD_SALDO_AGRUPADO   = '3'


  def self.cliente
    return CLIENTE
  end

  def self.antiguedad_saldo_detallado
    return ANTIGUEDAD_SALDO_DETALLADO
  end

  def self.antiguedad_saldo_agrupado
    return ANTIGUEDAD_SALDO_AGRUPADO
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


# G_OTROS_COSTOS=[
# 	{descripcion:"Saco 100 libras", key: "saco_100", costo:9, precio:20 },
# 	{descripcion:"Saco 75 libras",  key: "saco_75",  costo:9, precio:20 },
# 	{descripcion:"Saco 25 libras",  key: "saco_25",  costo:9, precio:20 },
# ]
