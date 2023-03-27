class AddCamposToPeriodoFiscal < ActiveRecord::Migration[7.0]
  def change
		add_column    :periodos_fiscales, :fecha_cerrado, :datetime, if_not_exists: true
		add_reference :periodos_fiscales, :usuario_cerrador, foreign_key: { to_table: :users }, index: true, if_not_exists: true
  end
end
