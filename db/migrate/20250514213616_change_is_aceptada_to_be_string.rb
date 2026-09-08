class ChangeIsAceptadaToBeString < ActiveRecord::Migration[7.0]
  def change
    change_column :cabecera_facturas, :is_aceptada, :string
    change_column :notas,             :is_aceptada, :string
  end
end
