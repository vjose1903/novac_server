class ConfiguracionEntidadCuentaSerializer < ActiveModel::Serializer


	def cuenta_contable
    fast_serialize_parser(object.cuenta_contable, {id: true, descripcion: true, codigo: true, label: true })
  end

end

class ConfiguracionEntidadCuentaSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :descripcion, :entidad, :key, :is_nacional, :cuenta_contable_id, :has_comun, :has_individual, :has_categoria, :has_sub_categoria, :cuenta_contable]
  end
end
