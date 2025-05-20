class ChangeCamposFacturacionElectronicaNota < ActiveRecord::Migration[7.0]
  def change
    change_column :notas, :fecha_hora_firma, :string
  end
end
