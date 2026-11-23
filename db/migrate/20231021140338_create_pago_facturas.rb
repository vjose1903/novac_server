class CreatePagoFacturas < ActiveRecord::Migration[7.0]
  def change
    create_table :pago_facturas do |t|
      t.references :user,         null: false, foreign_key: true
      t.references :suplidor,     null: false, foreign_key: true
      t.references :tipo_factura, null: false, foreign_key: true
      t.date    :fecha_equivalente
      t.integer :numero
      t.string  :forma_pago
      t.boolean :estado, default: true
      t.float   :total

      t.timestamps
    end
  end
end
