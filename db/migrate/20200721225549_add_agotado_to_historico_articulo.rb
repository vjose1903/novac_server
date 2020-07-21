class AddAgotadoToHistoricoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :historico_articulos, :agotado, :boolean
  end
end
