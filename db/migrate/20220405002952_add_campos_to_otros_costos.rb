class AddCamposToOtrosCostos < ActiveRecord::Migration[6.1]
  def change
		add_column :otros_costos, :estado, :boolean
  end
end
