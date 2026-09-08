class AddDivisaToCuadreCajaDenominaciones < ActiveRecord::Migration[7.0]
  def change
    add_reference :cuadre_caja_denominaciones, :divisa, foreign_key: true
    add_reference :cuadre_caja_denominaciones, :tasa_cambio, foreign_key: { to_table: :tasas_de_cambio }
  end
end
