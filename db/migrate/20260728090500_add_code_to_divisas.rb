class AddCodeToDivisas < ActiveRecord::Migration[7.0]
  def change
    add_column :divisas, :code, :string

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE divisas
          SET code = 'DOP'
          WHERE LOWER(nombre) LIKE '%peso%' AND code IS NULL
        SQL

        execute <<~SQL.squish
          UPDATE divisas
          SET code = 'USD'
          WHERE (LOWER(nombre) LIKE '%dolar%' OR LOWER(nombre) LIKE '%dólar%') AND code IS NULL
        SQL
      end
    end

    add_index :divisas, :code
  end
end
