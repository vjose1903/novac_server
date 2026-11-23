class EntidadCuentaContableSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.get_param('id')                              || self.get_param('all') }
  attribute :configuracion_entidad_cuenta_id,    if: Proc.new { self.get_param('configuracion_entidad_cuenta_id') || self.get_param('all') }
  attribute :key,                                if: Proc.new { self.get_param('key')                             || self.get_param('all') }
  attribute :tipo_agrupacion_contable,           if: Proc.new { self.get_param('tipo_agrupacion_contable')        || self.get_param('all') }
  attribute :is_comun,                           if: Proc.new { self.get_param('is_comun')                        || self.get_param('all') }

  attribute :cuenta_contable,                    if: Proc.new { self.get_param('cuenta_contable')                 || self.get_param('all') }
  attribute :origen_categoria,                   if: Proc.new { self.get_param('origen_categoria')                || self.get_param('all') }
  attribute :origen_entidad,                     if: Proc.new { self.get_param('origen_entidad')}



  def cuenta_contable
    serialize_parser(object.cuenta_contable, { id: true, descripcion: true, codigo: true, label: true })
  end

  def origen_categoria
    return nil if object.origen_categoria.nil?

    data = serialize_parser(object.origen_categoria, { id: true, descripcion: true }).as_json
    data[:table_name] = object.origen_categoria.class.table_name
    data
  end

  def origen_entidad
    serialize_parser(object.origen_entidad, { all: true })
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
