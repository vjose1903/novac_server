class CreateDetalleRecibos < ActiveRecord::Migration[5.2]
  def change
    create_table :detalle_recibos do |t|
      t.references :cabecera_recibo, foreign_key: true
      t.references :trabajo, foreign_key: true
      t.references :cabecera_factura, foreign_key: true
      t.float :total
      t.string :descripcion
      t.float :deposito

      t.timestamps
    end
  end
end
