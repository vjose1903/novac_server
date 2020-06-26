class CabeceraConduce < ApplicationRecord
  belongs_to :user
  belongs_to :cliente

  belongs_to :tipo_factura

  attribute :cliente
  attribute :tipo_factura

  has_many :detalle_conduces, dependent: :destroy
  attribute :detalle_conduces
  accepts_nested_attributes_for :detalle_conduces, :allow_destroy => true
end
