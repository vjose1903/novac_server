class SubTipoArticuloSerializer < ActiveModel::Serializer


  def tipo_articulo
    fast_serialize_parser(object.tipo_articulo, { id: true, descripcion: true })
  end

  def cuentas_contables
    fast_serialize_parser(object.tipo_articulo_cuentas_contables, { all: true })
  end
end

class SubTipoArticuloSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :descripcion, :tipo_articulo_id, :tipo_articulo, :cuentas_contables]
  end
end
