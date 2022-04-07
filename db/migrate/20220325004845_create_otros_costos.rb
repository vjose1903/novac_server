class CreateOtrosCostos < ActiveRecord::Migration[6.1]
  def change
    create_table :otros_costos do |t|
      t.string :descripcion
      t.string :key
      t.float :costo
      t.float :precio
      t.boolean :estado

      t.timestamps
    end
  end
end
