class CreateBancos < ActiveRecord::Migration[7.0]
  def change
    create_table :bancos do |t|

      t.string  :nombre,   :null => false
      t.string  :rnc,      :null => false
      t.string  :comentario
      t.string  :telefono
      t.string  :direccion
      t.string  :ejecutivo_cuenta
      t.string  :telefono_ejecutivo_cuenta
      t.boolean :estado,   :default => true

      t.timestamps
    end
  end
end
