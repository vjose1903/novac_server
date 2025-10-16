class CreatePermisos < ActiveRecord::Migration[6.1]
  def change
    create_table :permisos do |t|
      t.string :nombre
      t.string :descripcion
      t.string :controlador
      t.boolean :mostrar_front
      t.timestamps
    end
  end
end
