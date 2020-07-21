class AddSecuenciaToHistoricoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :historico_articulos, :secuencia, :integer
  end
end
