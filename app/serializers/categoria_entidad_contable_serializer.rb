class CategoriaEntidadContableSerializer < ActiveModel::Serializer
  attribute :id,                                          if: Proc.new { self.get_param('id')                         || self.get_param('all') }
  attribute :descripcion,                                 if: Proc.new { self.get_param('descripcion')                || self.get_param('all') }
  attribute :entidad,                                     if: Proc.new { self.get_param('entidad')                    || self.get_param('all') }
  attribute :key,                                         if: Proc.new { self.get_param('key')                        || self.get_param('all') }

  attribute :cuenta_contable_control,                     if: Proc.new { self.get_param('cuenta_contable_control')    || self.get_param('all') }
  attribute :cuenta_contable_auxiliar,                    if: Proc.new { self.get_param('cuenta_contable_auxiliar')   || self.get_param('all') }

  def cuenta_contable_control
    serialize_parser(object.cuenta_contable_control, {id: true, descripcion: true, codigo: true})
  end

  def cuenta_contable_auxiliar
    serialize_parser(object.cuenta_contable_auxiliar, {id: true, descripcion: true, codigo: true})
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

end
