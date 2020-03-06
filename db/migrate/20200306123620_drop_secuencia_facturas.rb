class DropSecuenciaFacturas < ActiveRecord::Migration[5.2]
  def change
      drop_table :secuencia_facturas
  end
end
