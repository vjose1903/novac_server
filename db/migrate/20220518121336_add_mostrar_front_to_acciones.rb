class AddMostrarFrontToAcciones < ActiveRecord::Migration[6.1]
  def change
		add_column :acciones, :mostrar_front, :boolean, if_not_exists: true
  end
end
