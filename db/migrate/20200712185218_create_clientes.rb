class CreateClientes < ActiveRecord::Migration[5.2]
  def change
    create_table :clientes do |t|
      t.string :nombre
      t.string :apellido
      t.string :nombre
      t.string :telefono
      t.string :direccion
      t.string :email
      t.boolean :estado

      t.timestamps
    end
  end
end
