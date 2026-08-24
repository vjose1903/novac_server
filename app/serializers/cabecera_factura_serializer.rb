class CabeceraFacturaSerializer < ActiveModel::Serializer
	attribute :id,                                             if: Proc.new { self.get_param('all') || self.get_param('id')  }
	attribute :tipo_factura_id,                                if: Proc.new { self.get_param('all') || self.get_param('tipo_factura_id')  }
	attribute :suplidor_id,                                    if: Proc.new { self.get_param('all') || self.get_param('suplidor_id')  }
	attribute :cliente_id,                                     if: Proc.new { self.get_param('all') || self.get_param('cliente_id')  }
	attribute :user_id,                                        if: Proc.new { self.get_param('all') || self.get_param('user_id')  }
	attribute :fecha_viaje,                                    if: Proc.new { self.get_param('all') || self.get_param('fecha_viaje')  }
	attribute :fecha_equivalente,                              if: Proc.new { self.get_param('all') || self.get_param('fecha_equivalente')  }
	attribute :fecha_vencimiento,                              if: Proc.new { self.get_param('all') || self.get_param('fecha_vencimiento')  }
	attribute :fecha_valida,                                   if: Proc.new { self.get_param('all') || self.get_param('fecha_valida')  }
	attribute :fecha_completada,                               if: Proc.new { self.get_param('all') || self.get_param('fecha_completada')  }
	attribute :numero_comprobante,                             if: Proc.new { self.get_param('all') || self.get_param('numero_comprobante')  }
	attribute :numero_factura,                                 if: Proc.new { self.get_param('all') || self.get_param('numero_factura')  }
	attribute :condicion,                                      if: Proc.new { self.get_param('all') || self.get_param('condicion')  }
	attribute :forma_pago,                                     if: Proc.new { self.get_param('all') || self.get_param('forma_pago')  }
	attribute :total_factura,                                  if: Proc.new { self.get_param('all') || self.get_param('total_factura')  }
	attribute :itbis,                                          if: Proc.new { self.get_param('all') || self.get_param('itbis')  }
	attribute :descuento,                                      if: Proc.new { self.get_param('all') || self.get_param('descuento')  }
	attribute :Bruto,                                          if: Proc.new { self.get_param('all') || self.get_param('Bruto')  }
	attribute :estado,                                         if: Proc.new { self.get_param('all') || self.get_param('estado')  }
	attribute :tipo,                                           if: Proc.new { self.get_param('all') || self.get_param('tipo')  }
	attribute :NoCliente_nombre,                               if: Proc.new { self.get_param('all') || self.get_param('NoCliente_nombre')  }
	attribute :NoCliente_direccion,                            if: Proc.new { self.get_param('all') || self.get_param('NoCliente_direccion')  }
	attribute :NoCliente_rnc,                                  if: Proc.new { self.get_param('all') || self.get_param('NoCliente_rnc')  }
	attribute :costoYgasto,                                    if: Proc.new { self.get_param('all') || self.get_param('costoYgasto')  }
	attribute :pagada,                                         if: Proc.new { self.get_param('all') || self.get_param('pagada')  }
	attribute :vendedor_id,                                    if: Proc.new { self.get_param('all') || self.get_param('vendedor_id')  }
	attribute :balance,                                        if: Proc.new { self.get_param('all') || self.get_param('balance')  }
	attribute :devuelta,                                       if: Proc.new { self.get_param('all') || self.get_param('devuelta')  }
	attribute :is_adelantada,                                  if: Proc.new { self.get_param('all') || self.get_param('is_adelantada')  }
	attribute :is_nota,                                        if: Proc.new { self.get_param('all') || self.get_param('is_nota')  }
	attribute :is_viaje,                                       if: Proc.new { self.get_param('all') || self.get_param('is_viaje')  }
	attribute :is_external,                                    if: Proc.new { self.get_param('all') || self.get_param('is_external')  }
	attribute :tiene_nota,                                     if: Proc.new { self.get_param('all') || self.get_param('tiene_nota')  }
	attribute :aplicada_a,                                     if: Proc.new { self.get_param('all') || self.get_param('aplicada_a')  }
	attribute :identificador,                                  if: Proc.new { self.get_param('all') || self.get_param('identificador')  }
	attribute :serie,                                          if: Proc.new { self.get_param('all') || self.get_param('serie')  }
	attribute :fecha_hora_firma,                               if: Proc.new { self.get_param('all') || self.get_param('fecha_hora_firma')  }
	attribute :qr_url_dgii,                                    if: Proc.new { self.get_param('all') || self.get_param('qr_url_dgii')  }
	attribute :trackId,                                        if: Proc.new { self.get_param('all') || self.get_param('trackId')  }
	attribute :security_code,                                  if: Proc.new { self.get_param('all') || self.get_param('security_code')  }
	attribute :is_aceptada,                                    if: Proc.new { self.get_param('all') || self.get_param('is_aceptada')  }
	attribute :dgii_message,                                   if: Proc.new { self.get_param('all') || self.get_param('dgii_message')  }
	attribute :movimientos_viaje,                              if: Proc.new { self.get_param('movimientos_viaje') }

	attribute :tipo_factura,                                   if: Proc.new { self.get_param('all') || self.get_param('tipo_factura')  }

	attribute :detalle_facturas,                               if: Proc.new { self.get_param('all') || self.get_param('detalle_facturas')  }
	attribute :cliente,                                        if: Proc.new { (!object.cliente_id.nil? || !object.NoCliente_nombre.nil? ) && ( self.get_param('all') || self.get_param('cliente') ) }
	attribute :suplidor,                                       if: Proc.new { !object.suplidor_id.nil? && ( self.get_param('all') || self.get_param('suplidor') ) }
	attribute :usuario,                                        if: Proc.new { self.get_param('all') || self.get_param('usuario')  }
	attribute :vendedor,                                       if: Proc.new { self.get_param('all') || self.get_param('vendedor')  }
	attribute :notas,                                          if: Proc.new { self.get_param('all') || self.get_param('notas')  }
	attribute :pagos,                                          if: Proc.new { self.get_param('all') || self.get_param('pagos')  }
	attribute :cotizacion,                                     if: Proc.new { self.get_param('all') || self.get_param('cotizacion')  }
	attribute :pre_factura,                                    if: Proc.new { self.get_param('all') || self.get_param('pre_factura')  }

	attribute :document_reference,                             if: Proc.new { (object.document_reference_as_origin || object.document_reference_as_referenced) && (self.get_param('all') || self.get_param('document_reference')) }
	attribute :is_ncf_modificado,                              if: Proc.new { self.get_param('all') || self.get_param('is_ncf_modificado')  }



	def tipo_factura
		object.tipo_factura.descripcion.titleize
	end

	def detalle_facturas
		serialize_parser(object.detalle_facturas, @instance_options)
	end

	def cliente
		cliente = {}
		if object.cliente.blank?
			cliente[:nombre]            = object.NoCliente_nombre
			cliente[:nombre_completo]   = object.NoCliente_nombre
			cliente[:direccion]         = object.NoCliente_direccion
			cliente[:telefono]          = '----------'
			cliente[:rnc]               = object.NoCliente_rnc || '----------'
		else
			client_                     = object.cliente.attributes
			cliente[:nombre]            = object.cliente.nombre_completo
			cliente[:nombre_completo]   = object.cliente.nombre_completo
			cliente[:telefono]          = client_["telefono"]
			cliente[:direccion]         = client_["direccion"]

			documento                    = object.cliente.documentos_de_identidad.find { |doc| doc.principal == true }
			cliente[:rnc]                = documento.nil? ? "----------" : documento.documento
		end
		cliente
	end

	def suplidor
		suplidor = {}
		unless object.suplidor.blank?
			supli_                       = object.suplidor.attributes
			suplidor[:nombre_completo]   = object.suplidor.nombre_completo
			suplidor[:direccion]         = supli_["direccion"]
			suplidor[:telefono]          = supli_["telefono"]

			documento                     = object.suplidor.documentos_de_identidad.find { |doc| doc.principal == true }
			suplidor[:rnc]                = documento.nil? ? '----------' : documento.documento
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
			notas = serialize_parser(notas, { fecha_equivalente: true, numero_comprobante: true, id: true, user_id: true, detalles_facturas_notas: true, total: true, tipo: true, tipo_label:true, usar_id_nota: true })
		end
		notas
	end

	def pagos
		pago_parseo    = []

		if object.condicion != 'Contado' || object.is_viaje
			pagos          = object.detalle_recibos

			if pagos.length > 0
				pagos.map do |detalle_recibo|

				recibo           = detalle_recibo.recibos_ingreso

				detalle_recibo   = detalle_recibo.as_json
				detalle_recibo["id"]                = recibo["id"]
				detalle_recibo["numero_recibo"]     = recibo["numero_recibo"]
				detalle_recibo["recibo_creado_por"] = recibo.user.nombre_completo
				detalle_recibo["fecha_equivalente"] = recibo["fecha_equivalente"]

				pago_parseo.push( detalle_recibo )
				end
			end

		end
		pago_parseo
	end

	def movimientos_viaje
		serialize_parser(object.movimientos_viaje, @instance_options)
	end


	def document_reference
		reference = object.document_reference_as_origin || object.document_reference_as_referenced
		return nil unless reference

		default_params = { all: false, id: true, referenced_by: { all: false, id: true, nombre_completo: true }, referenced_at: true }

		if reference.document_origin.id == object.id
		default_params = {**default_params, document_referenced: { id: true, numero_comprobante: true }}
		else
		default_params = {**default_params, document_origin: { id: true, numero_comprobante: true }}
		end

		optional_params = parse_serialize_optional_params(self.get_param('document_reference'), default_params)
		serialize_parser(reference, optional_params)
	end


	def get_param(col)
		@instance_options[:"#{col}"]
	end
end
