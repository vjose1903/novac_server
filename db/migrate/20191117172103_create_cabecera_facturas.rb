class CreateCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :cabecera_facturas do |t|
      t.references :tipo_factura, foreign_key: true
      t.references :suplidor, foreign_key: true
      t.references :cliente, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamp :fecha_facturacion
      t.date :fecha_vencimiento
      t.date :fecha_valida
      t.string :numero_comprobante
      t.integer :numero_factura
      t.string :condicion
      t.string :forma_pago
      t.float :total_factura
      t.float :itbis
      t.float :descuento
      t.float :Bruto
      t.boolean :estado
      t.string :tipo
      t.string :NoCliente_nombre
      t.string :NoCliente_direccion
      t.string :costoYgasto
      t.boolean :pagada
      t.integer :vendedor_id
      t.float :balance
      t.float :devuelta
      t.boolean :adelantada
      t.boolean :is_nota
      t.boolean :tiene_nota
      t.string :aplicada_a

      t.timestamps
    end
  end
end
