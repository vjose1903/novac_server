class SecuenciaFactura < ApplicationRecord
  belongs_to :tipo_factura
  # ========================================================================================================================

  def self.find_secuencia(id)
    actual_secuencia_conduce = SecuenciaFactura.find_by_tipo_factura_id(id)

    if actual_secuencia_conduce == [] || actual_secuencia_conduce == nil
      next_secuencia_conduce = 1
    else
      next_secuencia_conduce = actual_secuencia_conduce["secuencia"] + 1
    end

    numero_secuencia = ("%05d" % next_secuencia_conduce)
    return numero_secuencia
  end
end
