class CabeceraFacturaSerializer < ActiveModel::Serializer
  attribute :id,                                             if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :tipo_factura_id,                                if: Proc.new { self.personalizar_parametros('tipo_factura_id') || self.personalizar_parametros('all') }
  attribute :suplidor_id,                                    if: Proc.new { self.personalizar_parametros('suplidor_id') || self.personalizar_parametros('all') }
  attribute :cliente_id,                                     if: Proc.new { self.personalizar_parametros('cliente_id') || self.personalizar_parametros('all') }
  attribute :user_id,                                        if: Proc.new { self.personalizar_parametros('user_id') || self.personalizar_parametros('all') }
  attribute :fecha_viaje,                                    if: Proc.new { self.personalizar_parametros('fecha_viaje') || self.personalizar_parametros('all') }
  attribute :fecha_equivalente,                              if: Proc.new { self.personalizar_parametros('fecha_equivalente') || self.personalizar_parametros('all') }
  attribute :fecha_vencimiento,                              if: Proc.new { self.personalizar_parametros('fecha_vencimiento') || self.personalizar_parametros('all') }
  attribute :fecha_valida,                                   if: Proc.new { self.personalizar_parametros('fecha_valida') || self.personalizar_parametros('all') }
  attribute :fecha_completada,                               if: Proc.new { self.personalizar_parametros('fecha_completada') || self.personalizar_parametros('all') }
  attribute :numero_comprobante,                             if: Proc.new { self.personalizar_parametros('numero_comprobante') || self.personalizar_parametros('all') }
  attribute :numero_factura,                                 if: Proc.new { self.personalizar_parametros('numero_factura') || self.personalizar_parametros('all') }
  attribute :condicion,                                      if: Proc.new { self.personalizar_parametros('condicion') || self.personalizar_parametros('all') }
  attribute :forma_pago,                                     if: Proc.new { self.personalizar_parametros('forma_pago') || self.personalizar_parametros('all') }
  attribute :total_factura,                                  if: Proc.new { self.personalizar_parametros('total_factura') || self.personalizar_parametros('all') }
  attribute :itbis,                                          if: Proc.new { self.personalizar_parametros('itbis') || self.personalizar_parametros('all') }
  attribute :descuento,                                      if: Proc.new { self.personalizar_parametros('descuento') || self.personalizar_parametros('all') }
  attribute :Bruto,                                          if: Proc.new { self.personalizar_parametros('Bruto') || self.personalizar_parametros('all') }
  attribute :estado,                                         if: Proc.new { self.personalizar_parametros('estado') || self.personalizar_parametros('all') }
  attribute :tipo,                                           if: Proc.new { self.personalizar_parametros('tipo') || self.personalizar_parametros('all') }
  attribute :NoCliente_nombre,                               if: Proc.new { self.personalizar_parametros('NoCliente_nombre') || self.personalizar_parametros('all') }
  attribute :NoCliente_direccion,                            if: Proc.new { self.personalizar_parametros('NoCliente_direccion') || self.personalizar_parametros('all') }
  attribute :costoYgasto,                                    if: Proc.new { self.personalizar_parametros('costoYgasto') || self.personalizar_parametros('all') }
  attribute :pagada,                                         if: Proc.new { self.personalizar_parametros('pagada') || self.personalizar_parametros('all') }
  attribute :vendedor_id,                                    if: Proc.new { self.personalizar_parametros('vendedor_id') || self.personalizar_parametros('all') }
  attribute :balance,                                        if: Proc.new { self.personalizar_parametros('balance') || self.personalizar_parametros('all') }
  attribute :devuelta,                                       if: Proc.new { self.personalizar_parametros('devuelta') || self.personalizar_parametros('all') }
  attribute :is_adelantada,                                  if: Proc.new { self.personalizar_parametros('is_adelantada') || self.personalizar_parametros('all') }
  attribute :is_nota,                                        if: Proc.new { self.personalizar_parametros('is_nota') || self.personalizar_parametros('all') }
  attribute :is_viaje,                                       if: Proc.new { self.personalizar_parametros('is_viaje') || self.personalizar_parametros('all') }
  attribute :tiene_nota,                                     if: Proc.new { self.personalizar_parametros('tiene_nota') || self.personalizar_parametros('all') }
  attribute :aplicada_a,                                     if: Proc.new { self.personalizar_parametros('aplicada_a') || self.personalizar_parametros('all') }

  attribute :tipo_factura,                                   if: Proc.new { self.personalizar_parametros('tipo_factura') || self.personalizar_parametros('all') }
  
  attribute :detalle_facturas,                               if: Proc.new { self.personalizar_parametros('detalle_facturas') || self.personalizar_parametros('all') }
  attribute :cliente,                                        if: Proc.new { !object.cliente.nil? && (self.personalizar_parametros('cliente') || self.personalizar_parametros('all')) }
  attribute :suplidor,                                       if: Proc.new { !object.suplidor.nil? && (self.personalizar_parametros('suplidor') || self.personalizar_parametros('all')) }

  
  def tipo_factura
    object.tipo_factura.descripcion.titleize
  end

  def detalle_facturas
    serialize_parser(object.detalle_facturas, {all: true})
  end

  def cliente
    cliente = {}
    cliente["nombre"]            = object.cliente.nombre
    cliente["telefono"]          = object.cliente.telefono
    cliente["direccion"]         = object.cliente.direccion
    cliente["rnc"]               = object.cliente.documentos_de_identidad.find_by_principal(true)["documento"]
    cliente
  end

  def suplidor
    suplidor = {}
    suplidor["nombre"]            = object.suplidor.nombre
    suplidor["direccion"]         = object.suplidor.direccion
    suplidor["rnc"]               = object.suplidor.documentos_de_identidad.find_by_principal(true)["documento"]
    suplidor
  end
  
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end

end
