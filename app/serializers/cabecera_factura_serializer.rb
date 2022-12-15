class CabeceraFacturaSerializer < ActiveModel::Serializer
  attribute :id,                                             if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :tipo_factura_id,                                if: Proc.new { self.get_param('tipo_factura_id') || self.get_param('all') }
  attribute :suplidor_id,                                    if: Proc.new { self.get_param('suplidor_id') || self.get_param('all') }
  attribute :cliente_id,                                     if: Proc.new { self.get_param('cliente_id') || self.get_param('all') }
  attribute :user_id,                                        if: Proc.new { self.get_param('user_id') || self.get_param('all') }
  attribute :fecha_viaje,                                    if: Proc.new { self.get_param('fecha_viaje') || self.get_param('all') }
  attribute :fecha_equivalente,                              if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :fecha_vencimiento,                              if: Proc.new { self.get_param('fecha_vencimiento') || self.get_param('all') }
  attribute :fecha_valida,                                   if: Proc.new { self.get_param('fecha_valida') || self.get_param('all') }
  attribute :fecha_completada,                               if: Proc.new { self.get_param('fecha_completada') || self.get_param('all') }
  attribute :numero_comprobante,                             if: Proc.new { self.get_param('numero_comprobante') || self.get_param('all') }
  attribute :numero_factura,                                 if: Proc.new { self.get_param('numero_factura') || self.get_param('all') }
  attribute :condicion,                                      if: Proc.new { self.get_param('condicion') || self.get_param('all') }
  attribute :forma_pago,                                     if: Proc.new { self.get_param('forma_pago') || self.get_param('all') }
  attribute :total_factura,                                  if: Proc.new { self.get_param('total_factura') || self.get_param('all') }
  attribute :itbis,                                          if: Proc.new { self.get_param('itbis') || self.get_param('all') }
  attribute :descuento,                                      if: Proc.new { self.get_param('descuento') || self.get_param('all') }
  attribute :Bruto,                                          if: Proc.new { self.get_param('Bruto') || self.get_param('all') }
  attribute :estado,                                         if: Proc.new { self.get_param('estado') || self.get_param('all') }
  attribute :tipo,                                           if: Proc.new { self.get_param('tipo') || self.get_param('all') }
  attribute :NoCliente_nombre,                               if: Proc.new { self.get_param('NoCliente_nombre') || self.get_param('all') }
  attribute :NoCliente_direccion,                            if: Proc.new { self.get_param('NoCliente_direccion') || self.get_param('all') }
  attribute :costoYgasto,                                    if: Proc.new { self.get_param('costoYgasto') || self.get_param('all') }
  attribute :pagada,                                         if: Proc.new { self.get_param('pagada') || self.get_param('all') }
  attribute :vendedor_id,                                    if: Proc.new { self.get_param('vendedor_id') || self.get_param('all') }
  attribute :balance,                                        if: Proc.new { self.get_param('balance') || self.get_param('all') }
  attribute :devuelta,                                       if: Proc.new { self.get_param('devuelta') || self.get_param('all') }
  attribute :is_adelantada,                                  if: Proc.new { self.get_param('is_adelantada') || self.get_param('all') }
  attribute :is_nota,                                        if: Proc.new { self.get_param('is_nota') || self.get_param('all') }
  attribute :is_viaje,                                       if: Proc.new { self.get_param('is_viaje') || self.get_param('all') }
  attribute :tiene_nota,                                     if: Proc.new { self.get_param('tiene_nota') || self.get_param('all') }
  attribute :aplicada_a,                                     if: Proc.new { self.get_param('aplicada_a') || self.get_param('all') }
  attribute :identificador,                                  if: Proc.new { self.get_param('identificador') || self.get_param('all') }

  attribute :tipo_factura,                                   if: Proc.new { self.get_param('tipo_factura') || self.get_param('all') }

  attribute :detalle_facturas,                               if: Proc.new { self.get_param('detalle_facturas') || self.get_param('all') }
  attribute :cliente,                                        if: Proc.new { self.get_param('cliente') || self.get_param('all') }
  attribute :suplidor,                                       if: Proc.new { self.get_param('suplidor') || self.get_param('all') }
  attribute :usuario,                                        if: Proc.new { self.get_param('usuario') || self.get_param('all') }
  attribute :vendedor,                                       if: Proc.new { self.get_param('vendedor') || self.get_param('all') }
  attribute :notas,                                          if: Proc.new { self.get_param('notas') || self.get_param('all') }
  attribute :pagos,                                          if: Proc.new { self.get_param('pagos') || self.get_param('all') }
  attribute :camiones,                                       if: Proc.new { self.get_param('camiones') }
  attribute :cotizacion,                                     if: Proc.new { self.get_param('cotizacion') || self.get_param('all') }
  attribute :pre_factura,                                    if: Proc.new { self.get_param('pre_factura') || self.get_param('all') }


  def tipo_factura
    object.tipo_factura.descripcion.titleize
  end

  def detalle_facturas
    serialize_parser(object.detalle_facturas, @instance_options)
  end


  def cliente
    cliente = {}
    if object.cliente.blank?
      cliente["nombre"]            = object.NoCliente_nombre
      cliente["direccion"]         = object.NoCliente_direccion
      cliente["telefono"]          = "----------"
      cliente["rnc"]               = "----------"
    else
      client_                      = object.cliente.attributes
      cliente["nombre"]            = object.cliente.nombre_completo
      cliente["telefono"]          = client_["telefono"]
      cliente["direccion"]         = client_["direccion"]

      documento                    = object.cliente.documentos_de_identidad.find { |doc| doc.principal == true }
      cliente["rnc"]               = documento.nil? ? "----------" : documento.documento
    end
    cliente
  end

  def suplidor
    suplidor = {}
    unless object.suplidor.blank?
      supli_                        = object.suplidor.attributes
      suplidor["nombre"]            = supli_["nombre"].capitalize
      suplidor["direccion"]         = supli_["direccion"]
      suplidor["telefono"]          = supli_["telefono"]

      documento                     = object.suplidor.documentos_de_identidad.find { |doc| doc.principal == true }
      suplidor["rnc"]               = documento.nil? ? "----------" : documento.documento

    end
    suplidor
  end

  def usuario
    usuario = object.user.nombre_completo
    usuario
  end

  def vendedor
    vendedor = ""
    if object.vendedor_id
      user_vendedor = # `Usuario` es un modelo.
      User.find_by_id(object.vendedor_id)
      vendedor = user_vendedor.nombre_completo
      vendedor
    end
    vendedor
  end

  def notas
    notas = []
    if object.tiene_nota
      notas = object.facturas_aplicadas.filter { | factura_aplicada | factura_aplicada.nota.estado == true }
      notas = serialize_parser(notas, {numero_comprobante: true, id: true, user_id: true, detalles_facturas_notas: true, total: true, tipo: true, tipo_label:true})
    end
    notas
  end

  def pagos
    pago_parseo    = []
		puts "----> object.Bruto ".red + " #{object.to_json}"
    if object.Bruto != nil && ( object.Bruto - object.descuento ) != object.balance && (object.condicion != 'Contado' || object.is_viaje)
      pagos          = object.detalle_recibos

      if pagos.length > 0
        pagos.map do |detalle_recibo|

          recibo           = detalle_recibo.recibos_ingreso

          detalle_recibo   = detalle_recibo.as_json
          detalle_recibo["numero_recibo"]     = recibo["numero_recibo"]
          detalle_recibo["recibo_creado_por"] = recibo.user.nombre_completo
          detalle_recibo["fecha_equivalente"] = recibo["fecha_equivalente"]

					pago_parseo.push( detalle_recibo )
        end
      end

    end
    pago_parseo
  end

  def camiones
    object.camiones_viajes
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end

end
