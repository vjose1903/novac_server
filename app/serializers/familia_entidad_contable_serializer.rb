class FamiliaEntidadContableSerializer < ActiveModel::Serializer
  attributes :id, :descripcion, :entidad
  has_one :cuenta_contable_control
  has_one :cuenta_contable_auxiliar
end
