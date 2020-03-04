class AddRncToSuplidor < ActiveRecord::Migration[5.2]
  def change
    add_column :suplidores, :rnc, :string
  end
end
