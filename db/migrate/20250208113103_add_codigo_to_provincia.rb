class AddCodigoToProvincia < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:provincias, :codigo)
      add_column :provincias, :codigo, :string
    end

    unless column_exists?(:municipios, :codigo)
      add_column :municipios, :codigo, :string
    end
  end

  def down
    if column_exists?(:provincias, :codigo)
      remove_column :provincias, :codigo
    end

    if column_exists?(:municipios, :codigo)
      remove_column :municipios, :codigo
    end
  end
end
