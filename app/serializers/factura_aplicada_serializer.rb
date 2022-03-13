class FacturaAplicadaSerializer < ActiveModel::Serializer
	attribute :id,                            if: Proc.new { self.get_param('id') || self.get_param('all') }
	attribute :total,                         if: Proc.new { self.get_param('total') || self.get_param('all') }
	attribute :cabecera_factura,              if: Proc.new { self.get_param('cabecera_factura') || self.get_param('all') }
	attribute :detalles_facturas_notas,       if: Proc.new { self.get_param('detalles_facturas_notas') || self.get_param('all') }

	def cabecera_factura
		serialize_parser(object.cabecera_factura, {id: true, numero_comprobante: true})
	end

	def detalles_facturas_notas
		serialize_parser(object.detalles_facturas_notas, {all: true})
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
