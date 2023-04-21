class ChangeArticuloComboToReference < ActiveRecord::Migration[7.0]

  def up
    add_column :formulas_productos_terminados, :articulo_combo_id, :bigint
    add_foreign_key :formulas_productos_terminados, :articulos, column: :articulo_combo_id, foreign_key: { to_table: :articulos }

    FormulasProductosTerminado.reset_column_information

    reversible do |dir|
      dir.up do
        FormulasProductosTerminado.find_each do |fpt|
          fpt.update_attribute(:articulo_combo_id, fpt.articulo_combo)
        end
      end
    end

    remove_column :formulas_productos_terminados, :articulo_combo, :integer
  end

  def down
    add_column :formulas_productos_terminados, :articulo_combo, :integer

    reversible do |dir|
      dir.up do
        FormulasProductosTerminado.find_each do |fpt|
          fpt.update_attribute(:articulo_combo, fpt.articulo_combo_id)
        end
      end
    end

    remove_foreign_key :formulas_productos_terminados, column: :articulo_combo_id
    remove_column :formulas_productos_terminados, :articulo_combo_id, :bigint
  end

end