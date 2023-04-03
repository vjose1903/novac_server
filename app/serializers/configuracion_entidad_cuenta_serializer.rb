class ConfiguracionEntidadCuentaSerializer < ActiveModel::Serializer
  attribute :id,                                          if: Proc.new { self.get_param('id')                 || self.get_param('all') }
  attribute :descripcion,                                 if: Proc.new { self.get_param('descripcion')        || self.get_param('all') }
  attribute :entidad,                                     if: Proc.new { self.get_param('entidad')            || self.get_param('all') }
  attribute :key,                                         if: Proc.new { self.get_param('key')                || self.get_param('all') }
  attribute :is_prima,                                    if: Proc.new { self.get_param('is_prima')           || self.get_param('all') }
  attribute :cuenta_contable,                             if: Proc.new { self.get_param('cuenta_contable')    || self.get_param('all') }

	def cuenta_contable
    serialize_parser(object.cuenta_contable, {id: true, descripcion: true, codigo: true})
  end

	def get_param(col)
    return @instance_options[:"#{col}"]
  end

end
