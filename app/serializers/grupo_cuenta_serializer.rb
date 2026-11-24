class GrupoCuentaSerializer < ActiveModel::Serializer

  def origen
    OrigenGrupo.get_label(object.origen)
  end

  def tipo
    TipoGrupo.get_label(object.tipo)
  end

  def cuentas_contables
    fast_serialize_parser(object.cuentas_contables, {all: true})
  end
end

class GrupoCuentaSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :descripcion, :grupo, :origen, :tipo, :estado, :cuentas_contables]
  end
end
