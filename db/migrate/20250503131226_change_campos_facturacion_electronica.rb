class ChangeCamposFacturacionElectronica < ActiveRecord::Migration[7.0]
  def change
    change_column :cabecera_facturas, :fecha_hora_firma, :string
  end
end
