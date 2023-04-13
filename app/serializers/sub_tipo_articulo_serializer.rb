class SubTipoArticuloSerializer < ActiveModel::Serializer
	attribute :id,                            if: Proc.new { self.get_param('id')                   || self.get_param('all') }
  attribute :descripcion,                   if: Proc.new { self.get_param('descripcion')          || self.get_param('all') }

	attribute :cuentas_contables,             if: Proc.new {  self.get_param('cuentas_contables')   || self.get_param('all') }

  def cuentas_contables
    serialize_parser(object.tipo_articulo_cuentas_contables, { all: true })
  end

	def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
