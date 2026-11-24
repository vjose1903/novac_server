class CabezaAsientoContableSerializer < ActiveModel::Serializer



  def usuario_creador
    fast_serialize_parser(object.usuario_creador, { id: true, nombre_completo: true })
  end

  def usuario_anulador
    fast_serialize_parser(object.usuario_anulador, { id: true, nombre_completo: true })
  end

  def periodo_fiscal
    fast_serialize_parser(object.periodo_fiscal, { fecha_inicio: true, fecha_cierre: true })
  end

  def detalles_asientos_contables
    fast_serialize_parser(object.detalles_asientos_contables, { all: true })
  end
end

class CabezaAsientoContableSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :comentario, :tipo, :fecha_equivalente, :fecha_anulacion, :is_validated, :estado, :codigo, :usuario_creador, :usuario_anulador, :periodo_fiscal, :detalles_asientos_contables]
  end
end
