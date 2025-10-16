class CreateFacturasAplicadas < ActiveRecord::Migration[6.1]
  def change
    create_table :facturas_aplicadas do |t|
      t.references :nota, null: false, foreign_key: true
      t.references :cabecera_factura, null: false, foreign_key: true
      t.float :total

      t.timestamps
    end
  end
end
