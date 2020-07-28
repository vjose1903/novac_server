class AddCamposToHistoricoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :historico_articulos, :medida_hijo, :string
    add_column :historico_articulos, :costo_hijo, :float
    add_column :historico_articulos, :precio_hijo, :float
    add_column :historico_articulos, :cantidad_hijo, :integer
    add_column :historico_articulos, :referencia_hijo, :integer
    add_column :historico_articulos, :medida_padre, :string
    add_column :historico_articulos, :costo_padre, :float
    add_column :historico_articulos, :precio_padre, :float
    add_column :historico_articulos, :cantidad_padre, :integer
    add_column :historico_articulos, :referencia_padre, :integer
  end
end
