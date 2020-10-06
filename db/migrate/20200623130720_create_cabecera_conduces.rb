class CreateCabeceraConduces < ActiveRecord::Migration[5.2]
  def change
    create_table :cabecera_conduces do |t|
      t.references :user, foreign_key: true
      t.references :cliente, foreign_key: true
      t.integer :numero_conduce
      t.datetime :fecha_equivalente

      t.timestamps
    end
  end
end
