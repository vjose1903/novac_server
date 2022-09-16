class ChangeCamposToDetallesFacturasAndDetallesConducesAndDetallesProduccionAndDetallesFacturasNotas < ActiveRecord::Migration[6.1]
  def change
		change_column :detalles_facturas_notas,   :cantidad_en_unidades, :float
		execute "UPDATE detalles_facturas_notas SET cantidad_en_unidades = detalles_facturas_notas.cantidad where cantidad_en_unidades = 0"

		change_column :detalles_produccion,       :cantidad_en_unidades, :float
		execute "UPDATE detalles_produccion SET cantidad_en_unidades = detalles_produccion.cantidad where cantidad_en_unidades = 0"

		change_column :detalle_facturas,          :cantidad_en_unidades, :float
		change_column :detalle_facturas,          :retirado, :float
		change_column :detalle_facturas,          :retirado_en_venta, :float
		execute "UPDATE detalle_facturas SET cantidad_en_unidades = detalle_facturas.cantidad where cantidad_en_unidades = 0"

		change_column :detalle_conduces,          :cantidad_en_unidades, :float
		execute "UPDATE detalle_conduces SET cantidad_en_unidades = detalle_conduces.cantidad where cantidad_en_unidades = 0"
  end
end
