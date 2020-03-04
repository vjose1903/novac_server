class CreateClientes < ActiveRecord::Migration[5.2]
  def change
    create_table :clientes do |t|
      t.references :imagen, foreign_key: true
      t.references :documento_de_identidad, foreign_key: true
      t.string :nombre
      t.string :apellido
      t.string :telefono
      t.string :direccion
      t.string :sexo, limit: 1

      t.timestamps
    end
  end
end
