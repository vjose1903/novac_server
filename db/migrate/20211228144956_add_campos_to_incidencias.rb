class AddCamposToIncidencias < ActiveRecord::Migration[6.1]
  def change
    add_reference :incidencias, :origen, polymorphic: true, index: true
  end
end
