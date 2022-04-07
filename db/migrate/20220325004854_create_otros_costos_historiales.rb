class CreateOtrosCostosHistoriales < ActiveRecord::Migration[6.1]
  def change
    create_table :otros_costos_historiales do |t|
			t.references :otro_costo, null: false, foreign_key: true
			t.string :descripcion
      t.string :key
      t.float :costo
      t.float :precio
      t.boolean :estado

      t.timestamps
    end
  end
end
