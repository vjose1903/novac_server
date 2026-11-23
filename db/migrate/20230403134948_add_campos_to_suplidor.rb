class AddCamposToSuplidor < ActiveRecord::Migration[7.0]
  def change
		add_reference :suplidores,  :divisa, polymorphic: false, index: true, if_not_exists: true
  end
end
