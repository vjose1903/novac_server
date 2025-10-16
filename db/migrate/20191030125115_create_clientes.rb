class CreateClientes < ActiveRecord::Migration[5.2]
  def change
    create_table :clientes do |t|
      t.references :imagen, foreign_key: true
      t.string :nombre
      t.string :apellido
      t.string :telefono
      t.string :direccion
      t.integer :limite_credito
      t.string :sexo, limit: 1
      t.boolean :estado
      t.float :maximo_credito
      t.integer :vendedor_id
      t.float :balance

      t.timestamps
    end
  end
end
