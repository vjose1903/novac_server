class CreateNotas < ActiveRecord::Migration[6.1]
  def change
    create_table :notas do |t|
      t.references :cliente,       null: true,  foreign_key: true
      t.references :user,          null: false, foreign_key: true
      t.references :tipo_factura,  null: false, foreign_key: true
      t.float :total
      t.string :identificador
      t.integer :numero_documento
      t.string :numero_comprobante
      t.datetime :fecha_equivalente
      t.string :no_cliente_nombre
      t.string :no_cliente_direccion
      t.boolean :estado

      t.timestamps
    end
  end
end
