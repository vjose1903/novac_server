class AddDetalleFacturaToDetalleFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_facturas, :detalle_factura_nota, :integer
  end
end
