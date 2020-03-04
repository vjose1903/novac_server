class RemoveMantenimientoArticuloIdFromMantenimientoFormula < ActiveRecord::Migration[5.2]
  def change
    remove_column :mantenimiento_formulas, :mantenimiento_articulos_id, :reference
  end
end
