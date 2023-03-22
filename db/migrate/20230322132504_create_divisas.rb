class CreateDivisas < ActiveRecord::Migration[7.0]
  def change
    create_table :divisas do |t|
      t.string :nombre
      t.string :simbolo
      t.string :imagen
      t.boolean :is_principal
      t.boolean :estado

      t.timestamps
    end
  end
end
