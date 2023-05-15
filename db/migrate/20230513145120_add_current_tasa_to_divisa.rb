class AddCurrentTasaToDivisa < ActiveRecord::Migration[7.0]
  def change
		add_column :divisas,   :current_tasa,   :float,      default: 1,     if_not_exists: true
		add_column :divisas,   :predeterminado, :boolean,    default: false, if_not_exists: true
  end
end
