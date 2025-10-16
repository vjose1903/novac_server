class AddMoreCamposToDetallesFacturasNotas < ActiveRecord::Migration[6.1]
  def change
		add_reference :detalles_facturas_notas, :tipo_factura, polymorphic: false, index: true
		execute "UPDATE detalles_facturas_notas
		SET tipo_factura_id = n.tipo_factura_id
		FROM detalles_facturas_notas dfn
		INNER JOIN facturas_aplicadas fa ON fa.id = dfn.factura_aplicada_id
		INNER JOIN notas n ON n.id = fa.nota_id"
  end
end
