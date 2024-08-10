class CreateNombreBancos < ActiveRecord::Migration[7.0]
  def change
    create_table :nombre_bancos do |t|
      t.string :nombre
    end
  end
end
