class AddFechaEquivalenteToCuadreCaja < ActiveRecord::Migration[5.2]
  def change
    add_column :cuadre_cajas, :fecha_equivalente, :datetime
  end
end
