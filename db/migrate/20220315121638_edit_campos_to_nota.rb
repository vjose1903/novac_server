class EditCamposToNota < ActiveRecord::Migration[6.1]
  def change
		remove_column :roles_permisos_acciones, :metodo
		remove_column :roles_permisos_acciones, :controlador
		remove_column :roles, :activo

		add_column :permisos, :controlador, :string
		add_column :permisos, :mostrar_front, :boolean
		add_column :roles, :estado, :boolean
  end
end
