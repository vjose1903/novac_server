class AddCostoToFormulasProductosTerminado < ActiveRecord::Migration[5.2]
  def change
    add_column :formulas_productos_terminados, :costo, :float
  end
end
