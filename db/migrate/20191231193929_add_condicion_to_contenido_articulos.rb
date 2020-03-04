class AddCondicionToContenidoArticulos < ActiveRecord::Migration[5.2]
  def change
    add_column :contenido_articulos, :condicion, :string
  end
end
