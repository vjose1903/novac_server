class AddCamposToEntidades < ActiveRecord::Migration[7.0]
  def change
		add_reference :suplidores,  :categoria_entidad_contable, index: true,  null: true,   if_exists: false
		add_reference :clientes,    :categoria_entidad_contable, index: true,  null: true,   if_exists: false
		add_reference :users,       :categoria_entidad_contable, index: true,  null: true,   if_exists: false

		add_reference :articulos,   :sub_tipo_articulo,          index: true,  null: true,   if_exists: false
  end
end
