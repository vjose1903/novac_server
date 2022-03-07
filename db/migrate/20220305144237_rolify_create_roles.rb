class RolifyCreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table(:roles) do |t|
      t.string :nombre
      t.string :descripcion
      t.string :ruta_defecto
      t.boolean :activo

      t.timestamps
    end

    create_table(:users_roles, :id => false) do |t|
      t.references :user
      t.references :role
    end

    add_index(:roles, [ :nombre, :descripcion, :activo ], unique: true, where: "(activo = true)")
    add_index(:users_roles, [ :user_id, :role_id ])
  end
end

