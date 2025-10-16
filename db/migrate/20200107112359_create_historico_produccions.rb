class CreateHistoricoProduccions < ActiveRecord::Migration[5.2]
  def change
    create_table :historico_producciones do |t|
      t.references :user, foreign_key: true
      t.references :articulo, foreign_key: true
      t.float :cantidad
      t.string :medida

      t.timestamps
    end
  end
end
