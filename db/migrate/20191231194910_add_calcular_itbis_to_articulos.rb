class AddCalcularItbisToArticulos < ActiveRecord::Migration[5.2]
  def change
    add_column :articulos, :calcular_itbis, :boolean
  end
end
