class CreateRolesPermisosAcciones < ActiveRecord::Migration[6.1]
  def change
    create_table :roles_permisos_acciones do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permiso_accion, null: false, foreign_key: true
      t.timestamps
    end

		add_index(:roles_permisos_acciones, [:role_id, :permiso_accion_id])
  end
end