class CreateAcciones < ActiveRecord::Migration[6.1]
  def change
    create_table :acciones do |t|
      t.string :descripcion
      t.timestamps
    end
  end
end
