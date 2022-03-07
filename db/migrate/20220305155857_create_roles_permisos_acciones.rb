class CreateRolesPermisosAcciones < ActiveRecord::Migration[6.1]
  def change
    create_table :roles_permisos_acciones do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permiso_accion, null: false, foreign_key: true
      t.string :controlador
      t.string :metodo

      t.timestamps
    end

		add_index(:roles_permisos_acciones, [:role_id, :permiso_accion_id])
		add_index(:roles_permisos_acciones, [:controlador, :metodo], unique: true, where: "(metodo IS NOT NULL)")
  end
end
