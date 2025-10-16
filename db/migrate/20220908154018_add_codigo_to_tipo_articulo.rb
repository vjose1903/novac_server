class AddCodigoToTipoArticulo < ActiveRecord::Migration[6.1]
  def change
		add_column :tipo_articulos,   :codigo,   :string, if_not_exists: true
  end
end
