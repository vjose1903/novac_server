class AddUsadoToSecuenciaComprobantes < ActiveRecord::Migration[5.2]
  def change
    add_column :secuencia_comprobantes, :usado, :boolean
  end
end
