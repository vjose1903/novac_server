class CuentaContableSerializer < ActiveModel::Serializer
  attributes :id, :descripcion, :cuenta_control, :codigo, :nivel, :origen, :tipo
  has_one :grupo_cuenta
end
