class CabeceraFacturaSerializer < ActiveModel::Serializer
	extend FastSerializer




















	# ============================================================
	# FastSerializer
	# ============================================================

	def self.to_hash(object, params={})
		fields = default_fields.select { |field| show_field?(field, params, object) }
		serialize_record(object, fields, readers: readers(params))
	end

	def self.collection_to_hash(collection, params={})
		collection.map { |object| to_hash(object, params) }
	end

	def self.default_fields
		[:id, :tipo_factura_id, :suplidor_id, :cliente_id, :user_id, :fecha_viaje, :fecha_equivalente, :fecha_vencimiento, :fecha_valida, :fecha_completada, :numero_comprobante, :numero_factura, :condicion, :forma_pago, :total_factura, :itbis, :descuento, :Bruto, :estado, :tipo, :NoCliente_nombre, :NoCliente_direccion, :NoCliente_rnc, :costoYgasto, :pagada, :vendedor_id, :balance, :devuelta, :is_adelantada, :is_nota, :is_viaje, :is_external, :tiene_nota, :aplicada_a, :identificador, :serie, :fecha_hora_firma, :qr_url_dgii, :trackId, :security_code, :is_aceptada, :dgii_message, :movimientos_viaje, :tipo_factura, :detalle_facturas, :cliente, :suplidor, :usuario, :vendedor, :notas, :pagos, :cotizacion, :pre_factura, :document_reference, :is_ncf_modificado]
	end

	def self.show_field?(field, params, object)
		case field
		when :movimientos_viaje
			params[:movimientos_viaje]
		when :cliente
			(!object.cliente_id.nil? || !object.NoCliente_nombre.nil?) && (params[:all] || params[:cliente])
		when :suplidor
			!object.suplidor_id.nil? && (params[:all] || params[:suplidor])
		when :document_reference
			(object.document_reference_as_origin || object.document_reference_as_referenced) && (params[:all] || params[:document_reference])
		else
			params[:all] || params[field]
		end
	end

	def self.readers(params)
		{
			tipo_factura: ->(record) { record.tipo_factura.descripcion.titleize },
			detalle_facturas: ->(record) { DetalleFacturaSerializer.collection_to_hash(record.detalle_facturas, params) },
			cliente: ->(record) { cliente_to_hash(record) },
			suplidor: ->(record) { suplidor_to_hash(record.suplidor) },
			usuario: ->(record) { record.user.nombre_completo },
			vendedor: ->(record) { vendedor_to_hash(record) },
			notas: ->(record) { notas_to_hash(record) },
			pagos: ->(record) { pagos_to_hash(record) },
			movimientos_viaje: ->(record) { MovimientoViajeSerializer.collection_to_hash(record.movimientos_viaje, params) },
			document_reference: ->(record) { document_reference_to_hash(record, params) }
		}
	end

	def self.cliente_to_hash(record)
		cliente = {}
		if record.cliente.blank?
			cliente[:nombre]            = record.NoCliente_nombre
			cliente[:nombre_completo]   = record.NoCliente_nombre
			cliente[:direccion]         = record.NoCliente_direccion
			cliente[:telefono]          = '----------'
			cliente[:rnc]               = record.NoCliente_rnc || '----------'
		else
			cliente_obj                 = record.cliente
			cliente[:nombre]            = cliente_obj.nombre_completo
			cliente[:nombre_completo]   = cliente_obj.nombre_completo
			cliente[:telefono]          = cliente_obj['telefono']
			cliente[:direccion]         = cliente_obj['direccion']
			documento                   = cliente_obj.documentos_de_identidad.find { |doc| doc.principal == true }
			cliente[:rnc]               = documento.nil? ? "----------" : documento.documento
		end
		cliente
	end

	def self.suplidor_to_hash(suplidor)
		supli_obj = {}
		unless suplidor.blank?
			supli_                      = suplidor.attributes
			supli_obj[:nombre_completo] = suplidor.nombre_completo
			supli_obj[:direccion]       = supli_["direccion"]
			supli_obj[:telefono]        = supli_["telefono"]
			documento                   = suplidor.documentos_de_identidad.find { |doc| doc.principal == true }
			supli_obj[:rnc]             = documento.nil? ? '----------' : documento.documento
		end
		supli_obj
	end

	def self.vendedor_to_hash(record)
		return "" unless record.vendedor_id

		user_vendedor = record.vendedor
		user_vendedor.nombre_completo
	end

	def self.notas_to_hash(record)
		return [] unless record.tiene_nota

		notas = record.facturas_aplicadas.select { |factura_aplicada| factura_aplicada.nota.estado == true }
		FacturaAplicadaSerializer.collection_to_hash(notas, { fecha_equivalente: true, numero_comprobante: true, id: true, user_id: true, detalles_facturas_notas: true, total: true, tipo: true, tipo_label: true, usar_id_nota: true })
	end

	def self.pagos_to_hash(record)
		pago_parseo = []

		if record.condicion != 'Contado' || record.is_viaje
			pagos = record.detalle_recibos

			if pagos.length > 0
				pagos.each do |detalle_recibo|
					recibo         = detalle_recibo.recibos_ingreso

					detalle_recibo = detalle_recibo.as_json
					detalle_recibo["id"]                = recibo["id"]
					detalle_recibo["numero_recibo"]     = recibo["numero_recibo"]
					detalle_recibo["recibo_creado_por"] = recibo.user.nombre_completo
					detalle_recibo["fecha_equivalente"] = recibo["fecha_equivalente"]

					pago_parseo.push(detalle_recibo)
				end
			end
		end
		pago_parseo
	end

	def self.document_reference_to_hash(record, params)
		reference = record.document_reference_as_origin || record.document_reference_as_referenced
		return nil unless reference

		default_params = { all: false, id: true, referenced_by: { all: false, id: true, nombre_completo: true }, referenced_at: true }

		if reference.document_origin.id == record.id
			default_params = default_params.merge(document_referenced: { id: true, numero_comprobante: true })
		else
			default_params = default_params.merge(document_origin: { id: true, numero_comprobante: true })
		end

		optional_params = parse_serialize_optional_params(params[:document_reference], default_params)
		DocumentReferenceSerializer.to_hash(reference, optional_params)
	end
end
