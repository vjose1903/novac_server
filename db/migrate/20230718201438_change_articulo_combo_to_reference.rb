class ChangeArticuloComboToReference < ActiveRecord::Migration[7.0]

	def change
		reversible do |dir|
			dir.up do
				add_column :formulas_productos_terminados, :articulo_combo_id, :bigint
				FormulasProductosTerminado.reset_column_information
				add_foreign_key :formulas_productos_terminados, :articulos, column: :articulo_combo_id, foreign_key: { to_table: :articulos }

				comboMappingUp = FormulasProductosTerminado.pluck(:id, :articulo_combo).to_h

				FormulasProductosTerminado.find_each do |fpt|
					fpt.update_attribute(:articulo_combo_id, comboMappingUp[fpt.id])
				end

				remove_column :formulas_productos_terminados, :articulo_combo, :integer
			end

			dir.down do
				add_column :formulas_productos_terminados, :articulo_combo_temp, :integer

				comboMappingDown = FormulasProductosTerminado.pluck(:id, :articulo_combo_id).to_h

				FormulasProductosTerminado.find_each do |fpt|
					fpt.update_attribute(:articulo_combo_temp, comboMappingDown[fpt.id])
				end

				FormulasProductosTerminado.reset_column_information

				remove_foreign_key :formulas_productos_terminados, column: :articulo_combo_id
				remove_column :formulas_productos_terminados, :articulo_combo_id, :bigint
				rename_column :formulas_productos_terminados, :articulo_combo_temp, :articulo_combo
			end

		end
	end
end


