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
  attribute :detalle_recibos

  def self.find_secuencia
    actual_secuencia_recibo = SecuenciaIngreso.all.last

    if actual_secuencia_recibo == [] || actual_secuencia_recibo == nil
      next_secuencia_recibo = 1
    else
      next_secuencia_recibo = actual_secuencia_recibo["secuencia"] + 1
    end

    numero_secuencia = ("%05d" % next_secuencia_recibo)
    puts "numero_secuencia !!!!!!! ".red, numero_secuencia
    return numero_secuencia
  end

  def self.parsearData(data)
    begin
      obj = data.attributes
      obj["detalle_recibos"] = data.detalle_recibos.to_a
      obj["cliente"] = data.cliente
      obj["user"] = data.user
    rescue
      obj = data
    end

    detalles = []
    obj["detalle_recibos"].each do |detalle|
      objD = detalle.attributes
      factura = CabeceraFactura.find_by_id(detalle["cabecera_factura_id"])

      objD["total_factura"] = factura["total_factura"]
      detalles.push(objD)
    end

    obj["detalle_recibos"] = detalles

    return obj
  end
end
