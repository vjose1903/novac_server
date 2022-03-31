class AddCamposToOtrosCostosHistorial < ActiveRecord::Migration[6.1]
  def change
		add_reference :otros_costos_historiales, :otro_costo, null: false, foreign_key: true, index: true
  end
end
