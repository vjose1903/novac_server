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


  def tipo_factura
    object.tipo_factura.descripcion.titleize
  end

  def detalle_facturas
    @saco = self.get_param('saco_sistema')
    serialize_parser(object.detalle_facturas, {all: true, saco_sistema: @saco})
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

      documento                    = object.cliente.documentos_de_identidad.find_by_principal(true)
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

      documento                     = object.suplidor.documentos_de_identidad.find_by_principal(true)
      suplidor["rnc"]               = documento.nil? ? "----------" : documento.documento


    end
    suplidor
  end

  def usuario
    user_   = object.user.attributes
    usuario = object.user.nombre_completo
    usuario
  end

  def vendedor
    vendedor = ""
    if object.vendedor_id
      user_vendedor = User.find_by_id(object.vendedor_id)
      vendedor = user_vendedor.nombre_completo
      vendedor
    end
    vendedor
  end

  def notas
    notas_parseo = []

    if object.tiene_nota
      notas = CabeceraFactura.where({ aplicada_a: object.numero_comprobante })
			if notas.length > 0
        notas_parseo  = notas.map do | detalle_nota |
					keys_to_pick                      = ['tipo_factura_id', 'detalle_facturas', 'id', 'total_factura', 'aplicada_a','estado', 'numero_comprobante', 'user_id']

          detalle_nota_json_temp                      = detalle_nota.as_json
					detalle_nota_json_temp['detalle_facturas']  = detalle_nota.detalle_facturas

          detalle_nota_json = detalle_nota_json_temp.as_json.select { |key, value| keys_to_pick.my_includes_str(key) }
					detalle_nota = detalle_nota_json
          detalle_nota
        end

      end
      # serialize_parser(notas, {all: true, saco_sistema: @saco})  unless notas.blank?
    end
    notas_parseo
  end

  def pagos
    pago_parseo    = []

    if ( object.Bruto - object.descuento ) != object.balance && (object.condicion != 'Contado' || object.is_viaje)
      pago_          = DetalleRecibo.where({ cabecera_factura_id: object.id }).order('id DESC')

      if pago_.length > 0
        pago_parseo  = pago_.map do |detalle_recibo|

          detalle_recibo   = detalle_recibo.as_json
          recibo           = RecibosIngreso.find_by_id(detalle_recibo["recibos_ingreso_id"])

          detalle_recibo["numero_recibo"]     = recibo["numero_recibo"]
          detalle_recibo["recibo_creado_por"] = recibo.user.nombre_completo
          detalle_recibo["fecha_equivalente"] = recibo["fecha_equivalente"]
          detalle_recibo
        end
      end

    end
    pago_parseo
  end





  def get_param(col)
		return @instance_options[:"#{col}"]
	end

end
