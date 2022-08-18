class AddTipoToTipoArticulo < ActiveRecord::Migration[6.1]
  def change
		add_column :tipo_articulos,   :tipo,   :string, if_not_exists: true
		add_column :tipo_articulos,   :codigo, :string, if_not_exists: true

		execute "UPDATE tipo_articulos SET tipo='venta_normal'"
  end
end
