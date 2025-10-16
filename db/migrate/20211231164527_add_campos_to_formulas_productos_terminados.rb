class AddCamposToFormulasProductosTerminados < ActiveRecord::Migration[6.1]
  def change
    add_column :formulas_productos_terminados, :medida, :string
  end
end
