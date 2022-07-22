class AddMedidaToMantenimientoFormula < ActiveRecord::Migration[6.1]
  def change
		add_column :mantenimiento_formulas, :medida, :string
  end
end
