class AddUserToHistoricoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_reference :historico_articulos, :user, foreign_key: true
  end
end
