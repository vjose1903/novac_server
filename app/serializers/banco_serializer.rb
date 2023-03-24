class BancoSerializer < ActiveModel::Serializer
  attributes :id, :nombre, :rnc, :comentario, :telefono, :direccion, :ejecutivo_cuenta, :telefono_ejecutivo_cuenta, :estado
end
