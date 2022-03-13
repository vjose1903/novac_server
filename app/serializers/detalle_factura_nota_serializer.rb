class DetalleFacturaNotaSerializer < ActiveModel::Serializer

	attribute :id,                        if: Proc.new { self.get_param('id') || self.get_param('all') }
	attribute :unidad,                    if: Proc.new { self.get_param('unidad') || self.get_param('all') }
	attribute :cantidad,                  if: Proc.new { self.get_param('cantidad') || self.get_param('all') }
	attribute :cantidad_en_unidades,      if: Proc.new { self.get_param('cantidad_en_unidades') || self.get_param('all') }
	attribute :itbis,                     if: Proc.new { self.get_param('itbis') || self.get_param('all') }
	attribute :costo,                     if: Proc.new { self.get_param('costo') || self.get_param('all') }
	attribute :precio,                    if: Proc.new { self.get_param('precio') || self.get_param('all') }
	attribute :total,                     if: Proc.new { self.get_param('total') || self.get_param('all') }
	attribute :descuento,                 if: Proc.new { self.get_param('descuento') || self.get_param('all') }
	attribute :detalle_factura_id,        if: Proc.new { self.get_param('detalle_factura_id') || self.get_param('all') }

	attribute :articulo,                  if: Proc.new { self.get_param('articulo') || self.get_param('all') }


	def articulo
		serialize_parser(object.articulo, {id: true, nombre: true})
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
