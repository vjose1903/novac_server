class AddSerieToNotas < ActiveRecord::Migration[7.0]

  def up
    unless column_exists?(:notas, :serie)
      add_column :notas,   :serie,   :string
    end

    unless column_exists?(:notas, :razon)
      add_column :notas,   :razon,   :string
    end

    unless column_exists?(:notas, :bruto)
      add_column :notas,   :bruto,   :float
    end

    unless column_exists?(:notas, :itbis)
      add_column :notas,   :itbis,   :float
    end 

    execute <<-SQL
      UPDATE notas
      SET serie = 'normal'
    SQL

  end

  def down
    if column_exists?(:notas, :serie)
      remove_column :notas,   :serie
    end

    if column_exists?(:notas, :razon)
      remove_column :notas,   :razon
    end

    if column_exists?(:notas, :bruto)
      remove_column :notas,   :bruto
    end

    if column_exists?(:notas, :itbis)
      remove_column :notas,   :itbis
    end
  end
end
