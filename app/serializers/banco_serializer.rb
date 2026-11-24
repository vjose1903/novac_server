class BancoSerializer < ActiveModel::Serializer



  def cuentas_bancarias
    fast_serialize_parser(object.cuentas_bancarias, { all: true })
  end
end

class BancoSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :nombre, :rnc, :comentario, :telefono, :direccion, :ejecutivo_cuenta, :telefono_ejecutivo_cuenta, :estado, :cuentas_bancarias]
  end
end
