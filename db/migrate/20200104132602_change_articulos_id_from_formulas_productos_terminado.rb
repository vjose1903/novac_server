class ChangeArticulosIdFromFormulasProductosTerminado < ActiveRecord::Migration[5.2]
  def change
    rename_column :formulas_productos_terminados, :articulos_id, :articulo_id
  end
end
