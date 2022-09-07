class AddCamposToDetallesFacturasNotas < ActiveRecord::Migration[6.1]
  def change
		add_column :detalles_facturas_notas,   :precio_real,    :float, if_not_exists: true
		add_column :detalles_facturas_notas,   :itbis_real,     :float, if_not_exists: true
		add_column :detalles_facturas_notas,   :descuento_real, :float, if_not_exists: true

		execute "UPDATE detalles_facturas_notas SET precio_real = detalles_facturas_notas.precio, itbis_real = detalles_facturas_notas.itbis, descuento_real = detalles_facturas_notas.descuento"
  end
end
