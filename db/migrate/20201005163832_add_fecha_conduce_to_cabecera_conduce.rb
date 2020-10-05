class AddFechaConduceToCabeceraConduce < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_conduces, :fecha_conduce, :datetime
  end
end
