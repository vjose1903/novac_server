class TransferenciaSerializer < ActiveModel::Serializer



  def cuenta_bancaria_origen
    fast_serialize_parser(object.cuenta_bancaria_origen, { id: true, descripcion: true, numero_cuenta: true, info_completa: true })
  end

  def cuenta_bancaria_destino
    fast_serialize_parser(object.cuenta_bancaria_destino, { id: true, descripcion: true, numero_cuenta: true, info_completa: true })
  end

  def divisa
    fast_serialize_parser(object.divisa, { id: true, nombre: true })
  end

  def user_creador
    fast_serialize_parser(object.user_creador, { id: true, nombre_completo: true })
  end

  def last_user_update
      fast_serialize_parser(object.last_user_update, { id: true, nombre_completo: true })
  end

  def user_anulador
    fast_serialize_parser(object.user_anulador, { id: true, nombre_completo: true })
  end

  def banco_obj
    banco = { nombre: '', id: nil }

    banco[:nombre] = object.cuenta_bancaria_destino.nil? ? object.nombre_banco_tercero : object.cuenta_bancaria_destino.banco.nombre
    banco[:id]     = object.cuenta_bancaria_destino.banco.id unless object.cuenta_bancaria_destino.nil?
    banco
  end

  def destino_info_completa
    if object.cuenta_bancaria_destino.nil?
      info = object.nombre_banco_tercero
      info += ": #{object.cuenta_bancaria_tercero}"
      info = info.gsub('  ', ' ').strip
    else
      info = object.cuenta_bancaria_destino.info_completa
    end

    info
  end
end

class TransferenciaSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :tasa, :monto, :monto_local, :comentario, :numero_referencia, :fecha_equivalente, :fecha_anulacion, :nombre_banco_tercero, :cuenta_bancaria_tercero, :estado, :cuenta_bancaria_origen, :cuenta_bancaria_destino, :divisa, :user_creador, :last_user_update, :user_anulador, :banco_obj, :destino_info_completa]
  end
end
