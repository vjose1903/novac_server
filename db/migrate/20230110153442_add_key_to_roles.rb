class AddKeyToRoles < ActiveRecord::Migration[7.0]
  def change
		add_column :roles, :key, :string, if_not_exists: true
  end
end
