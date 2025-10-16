class AddRefenceToCamionesViajes < ActiveRecord::Migration[6.1]
  def change
    add_reference :camiones_viajes, :origen, polymorphic: true, index: true

    execute "UPDATE camiones_viajes SET origen_type='CabeceraFactura', origen_id=camiones_viajes.cabecera_factura_id"

    remove_index :camiones_viajes, name: "index_camiones_viajes_on_cabecera_factura_id", if_exists: true
    remove_column :camiones_viajes, :cabecera_factura_id, if_exists: true
  end
end


