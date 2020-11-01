class CreateCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :cabecera_facturas do |t|
      t.references :tipo_factura, foreign_key: true
      t.references :suplidor, foreign_key: true
      t.references :cliente, foreign_key: true
      t.references :user, foreign_key: true
      # t.datetime :fecha_viaje
      t.datetime :fecha_equivalente
      t.datetime :fecha_vencimiento
      t.datetime :fecha_valida
      t.datetime :fecha_completada
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
      t.boolean :is_adelantada
      t.boolean :is_nota
      t.boolean :is_viaje
      t.boolean :tiene_nota
      t.string :aplicada_a

      t.timestamps
    end
  end
end
