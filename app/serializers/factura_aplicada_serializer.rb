class FacturaAplicadaSerializer < ActiveModel::Serializer
	attribute :id,                            if: Proc.new { self.get_param('all') || self.get_param('id')  }

	def id
		self.get_param('usar_id_nota') ? object.nota_id : object.id
	end

	attribute :total,                         if: Proc.new { self.get_param('all') || self.get_param('total')  }
	attribute :cabecera_factura,              if: Proc.new { self.get_param('all') || self.get_param('cabecera_factura')  }
	attribute :detalles_facturas_notas,       if: Proc.new { self.get_param('all') || self.get_param('detalles_facturas_notas')  }
	attribute :fecha_equivalente,             if: Proc.new { self.get_param('all') || self.get_param('fecha_equivalente') }
	
	attribute :numero_comprobante,            if: Proc.new { self.get_param('numero_comprobante') }
	attribute :user_id,                       if: Proc.new { self.get_param('user_id') }
	attribute :estado,                        if: Proc.new { self.get_param('estado') }
	attribute :tipo,                          if: Proc.new { self.get_param('tipo') }
	attribute :tipo_label,                    if: Proc.new { self.get_param('tipo_label') }

	def cabecera_factura
		serialize_parser(object.cabecera_factura, {id: true, numero_comprobante: true, fecha_equivalente: true})
	end

	def detalles_facturas_notas
		serialize_parser(object.detalles_facturas_notas, {all: true})
	end

	def fecha_equivalente
		object.nota.fecha_equivalente
	end
	
	def numero_comprobante
		object.nota.numero_comprobante
	end


	def user_id
		object.nota.user_id
	end

	def estado
		object.nota.estado
	end

	def tipo
		object.tipo_nota
	end

	def tipo_label
		object.tipo_nota == TiposNotas.credito  ? 'Crédito' : 'Débito'
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
