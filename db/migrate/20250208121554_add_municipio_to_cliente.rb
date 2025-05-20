class AddMunicipioToCliente < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:clientes, :municipio_id)
      add_reference :clientes, :municipio, foreign_key: true, null: true
    end
  end

  def down
    if column_exists?(:clientes, :municipio_id)
      remove_reference :clientes, :municipio, foreign_key: true
    end
  end
end
