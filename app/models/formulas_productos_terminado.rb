class FormulasProductosTerminado < ApplicationRecord
  belongs_to :articulo

  def self.get_formulas_by_articulo_id(id)
    return my_query("SELECT * FROM formulas_productos_terminados WHERE articulo_id = #{id}")
  end
  def self.get_formulas_by_secuencia(secuencia)
    return my_query("SELECT * FROM formulas_productos_terminados WHERE secuencia = #{secuencia}")
  end
end
