class ChangeFechaEquivalenteTypePagoFacturas < ActiveRecord::Migration[7.0]
  def up
    # Renombrar la columna actual
    rename_column :pago_facturas, :fecha_equivalente, :fecha_equivalente_old

    # Añadir la nueva columna con el nuevo tipo de dato
    add_column :pago_facturas, :fecha_equivalente, :datetime

    # Transferir los datos de la columna antigua a la nueva
    PagoFactura.reset_column_information
    PagoFactura.find_each do |pago_factura|
      pago_factura.update_column(:fecha_equivalente, pago_factura.fecha_equivalente_old)
    end

    # Eliminar la columna antigua
    remove_column :pago_facturas, :fecha_equivalente_old
  end

  def down
    # Añadir la columna antigua
    add_column :pago_facturas, :fecha_equivalente_old, :date

    # Transferir los datos de la nueva columna a la antigua
    PagoFactura.reset_column_information
    PagoFactura.find_each do |pago_factura|
      pago_factura.update_column(:fecha_equivalente_old, pago_factura.fecha_equivalente)
    end

    # Eliminar la nueva columna
    remove_column :pago_facturas, :fecha_equivalente

    # Renombrar la columna antigua
    rename_column :pago_facturas, :fecha_equivalente_old, :fecha_equivalente
  end
end
