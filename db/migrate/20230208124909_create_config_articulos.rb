class CreateConfigArticulos < ActiveRecord::Migration[7.0]
  def change
    create_table :config_articulos do |t|
      t.float :porciento_ganancia

      t.timestamps
    end
  end
end
