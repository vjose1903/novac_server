class AddReferenciaToSecuenciaComprobante < ActiveRecord::Migration[5.2]
  def change
    add_column :secuencia_comprobantes, :referencia, :string
  end
end
