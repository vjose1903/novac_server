class AddFormulaIdToMantenimientoFormula < ActiveRecord::Migration[6.1]
  def change
		add_column :mantenimiento_formulas, :formula_id, :integer
  end
end
