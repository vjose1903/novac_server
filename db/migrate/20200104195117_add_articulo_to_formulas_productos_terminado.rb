class AddArticuloToFormulasProductosTerminado < ActiveRecord::Migration[5.2]
  def change
    add_column :formulas_productos_terminados, :articulo, :integer
    add_column :mantenimiento_formulas, :articulo, :integer
  end
end
