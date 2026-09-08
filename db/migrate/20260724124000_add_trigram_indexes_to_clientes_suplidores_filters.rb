class AddTrigramIndexesToClientesSuplidoresFilters < ActiveRecord::Migration[7.0]
  def up
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    create_trigram_index(:clientes, :nombre, "index_clientes_on_nombre_trgm")
    create_trigram_index(:clientes, :apellido, "index_clientes_on_apellido_trgm")
    create_trigram_index(:suplidores, :nombre, "index_suplidores_on_nombre_trgm")
    create_trigram_index(:suplidores, :direccion, "index_suplidores_on_direccion_trgm")
    create_trigram_index(:suplidores, :email, "index_suplidores_on_email_trgm")
    create_trigram_index(:documentos_de_identidad, :documento, "index_documentos_de_identidad_on_documento_trgm")
  end

  def down
    remove_index_by_name(:documentos_de_identidad, "index_documentos_de_identidad_on_documento_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_email_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_direccion_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_nombre_trgm")
    remove_index_by_name(:clientes, "index_clientes_on_apellido_trgm")
    remove_index_by_name(:clientes, "index_clientes_on_nombre_trgm")
  end

  private

  def create_trigram_index(table, column, name)
    return if index_exists_by_name?(table, name)

    execute <<~SQL
      CREATE INDEX #{quote_column_name(name)}
      ON #{quote_table_name(table)}
      USING gin (#{quote_column_name(column)} gin_trgm_ops)
    SQL
  end

  def remove_index_by_name(table, name)
    remove_index table, name: name if index_exists_by_name?(table, name)
  end

  def index_exists_by_name?(table, name)
    indexes(table).any? { |index| index.name == name }
  end
end
