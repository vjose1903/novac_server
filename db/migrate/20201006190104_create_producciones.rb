class CreateProducciones < ActiveRecord::Migration[5.2]
  def change
    create_table :producciones do |t|
      t.references :user, foreign_key: true
      t.integer :numero
      t.datetime :fecha_equivalente

      t.timestamps
    end
  end
end
