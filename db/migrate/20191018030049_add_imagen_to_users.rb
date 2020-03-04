class AddImagenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :imagen, foreign_key: true
  end
end
