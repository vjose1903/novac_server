class RemoveRncFromSuplidor < ActiveRecord::Migration[5.2]
  def change
    remove_column :suplidores, :rnc, :string
  end
end
