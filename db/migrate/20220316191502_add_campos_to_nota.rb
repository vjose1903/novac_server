class AddCamposToNota < ActiveRecord::Migration[6.1]
  def change
		add_column :notas, :fecha_valida, :datetime
  end
end
