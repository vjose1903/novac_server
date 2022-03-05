class CreatePermisosAcciones < ActiveRecord::Migration[6.1]
  def change
    create_table :permisos_acciones do |t|
      t.references :permiso, null: false, foreign_key: true
      t.references :accion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
