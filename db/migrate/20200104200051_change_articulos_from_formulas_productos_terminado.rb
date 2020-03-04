class ChangeArticulosFromFormulasProductosTerminado < ActiveRecord::Migration[5.2]
  def change
    rename_column :formulas_productos_terminados, :articulo, :articulo_combo
    rename_column :mantenimiento_formulas, :articulo, :articulo_combo
  end
end
