class DivisaSerializer < ActiveModel::Serializer
  attributes :id, :nombre, :simbolo, :imagen, :is_principal, :estado
end
