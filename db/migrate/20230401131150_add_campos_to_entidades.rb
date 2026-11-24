class AddCamposToEntidades < ActiveRecord::Migration[7.0]
  def change
    add_reference :articulos,   :sub_tipo_articulo,          index: true,  null: true,   if_not_exists: true
  end
end
