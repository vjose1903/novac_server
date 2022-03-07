class CreateAcciones < ActiveRecord::Migration[6.1]
  def change
    create_table :acciones do |t|
      t.string :nombre
      t.string :descripcion
      t.string :metodo
      t.timestamps
    end
  end
end
