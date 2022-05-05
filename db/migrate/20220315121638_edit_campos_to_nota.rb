class EditCamposToNota < ActiveRecord::Migration[6.1]
  def change
		remove_column :roles_permisos_acciones, :metodo, if_exists: true
		remove_column :roles_permisos_acciones, :controlador, if_exists: true
		remove_column :roles, :activo, if_exists: true

		add_column :permisos, :controlador, :string, if_not_exists: true
		add_column :permisos, :mostrar_front, :boolean, if_not_exists: true
		add_column :roles, :estado, :boolean, if_not_exists: true
  end
end
