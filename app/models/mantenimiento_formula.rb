class MantenimientoFormula < ApplicationRecord
  def self.get_mantenimiento_formulas_by_secuencia(num)
    return my_query("SELECT * FROM mantenimiento_formulas WHERE secuencia = #{num}")
  end
end
