class AddCalcularItbisToContenidoArticulos < ActiveRecord::Migration[5.2]
  def change
    add_column :contenido_articulos, :calcular_itbis, :boolean
  end
end
