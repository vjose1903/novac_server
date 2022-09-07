class AddCamposToFacturasAplicadas < ActiveRecord::Migration[6.1]
  def change
		add_reference :facturas_aplicadas, :tipo_factura, polymorphic: false, index: true
		execute "UPDATE facturas_aplicadas
		SET tipo_factura_id = n.tipo_factura_id
		FROM facturas_aplicadas fa
		INNER JOIN notas n ON n.id = fa.nota_id"
  end
end
