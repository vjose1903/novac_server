class AddFechaNacimientoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :fecha_nacimiento, :string
  end
end
