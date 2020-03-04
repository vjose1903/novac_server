class RecibosIngreso < ApplicationRecord
  belongs_to :tipo_recibo
  belongs_to :user
  belongs_to :cliente

  has_many :detalle_recibos, dependent: :destroy
  attribute :detalle_recibos
  accepts_nested_attributes_for :detalle_recibos, :allow_destroy => true

  attribute :user
  attribute :cliente
  attribute :tipo_recibo

  def self.find_secuencia
    actual_secuencia_recibo = SecuenciaIngreso.all.last

    if actual_secuencia_recibo == [] || actual_secuencia_recibo == nil
      next_secuencia_recibo = 1
    else
      next_secuencia_recibo = actual_secuencia_recibo["secuencia"] + 1
    end

    numero_comprobante = ("%05d" % next_secuencia_recibo)

    return numero_comprobante
  end
end
