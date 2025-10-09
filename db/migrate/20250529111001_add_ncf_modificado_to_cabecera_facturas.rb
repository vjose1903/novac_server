class AddNcfModificadoToCabeceraFacturas < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:cabecera_facturas, :is_ncf_modificado)
      add_column :cabecera_facturas,   :is_ncf_modificado,   :boolean,   default: false
    end

    CabeceraFactura.where(is_ncf_modificado: nil).update_all(is_ncf_modificado: false)
  end

  def down
    if column_exists?(:cabecera_facturas, :is_ncf_modificado)
      remove_column :cabecera_facturas,   :is_ncf_modificado
    end
  end
end
