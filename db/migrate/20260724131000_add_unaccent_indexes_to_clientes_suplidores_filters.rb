class AddUnaccentIndexesToClientesSuplidoresFilters < ActiveRecord::Migration[7.0]
  def up
    enable_extension "unaccent" unless extension_enabled?("unaccent")

    create_immutable_unaccent_function

    remove_index_by_name(:documentos_de_identidad, "index_documentos_de_identidad_on_documento_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_email_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_direccion_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_nombre_trgm")
    remove_index_by_name(:clientes, "index_clientes_on_apellido_trgm")
    remove_index_by_name(:clientes, "index_clientes_on_nombre_trgm")

    create_trigram_index(:clientes, :nombre, "index_clientes_on_unaccent_nombre_trgm")
    create_trigram_index(:clientes, :apellido, "index_clientes_on_unaccent_apellido_trgm")
    create_trigram_index(:suplidores, :nombre, "index_suplidores_on_unaccent_nombre_trgm")
    create_trigram_index(:suplidores, :direccion, "index_suplidores_on_unaccent_direccion_trgm")
    create_trigram_index(:suplidores, :email, "index_suplidores_on_unaccent_email_trgm")
    create_trigram_index(:documentos_de_identidad, :documento, "index_documentos_identidad_on_unaccent_documento_trgm")

    create_sort_index(:clientes, [:nombre, :apellido], "index_clientes_on_nombre_apellido")
    create_sort_index(:suplidores, [:nombre], "index_suplidores_on_nombre")
  end

  def down
    remove_index_by_name(:suplidores, "index_suplidores_on_nombre")
    remove_index_by_name(:clientes, "index_clientes_on_nombre_apellido")

    remove_index_by_name(:documentos_de_identidad, "index_documentos_identidad_on_unaccent_documento_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_unaccent_email_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_unaccent_direccion_trgm")
    remove_index_by_name(:suplidores, "index_suplidores_on_unaccent_nombre_trgm")
    remove_index_by_name(:clientes, "index_clientes_on_unaccent_apellido_trgm")
    remove_index_by_name(:clientes, "index_clientes_on_unaccent_nombre_trgm")

    execute "DROP FUNCTION IF EXISTS immutable_unaccent(text)"

    create_plain_trigram_index(:clientes, :nombre, "index_clientes_on_nombre_trgm")
    create_plain_trigram_index(:clientes, :apellido, "index_clientes_on_apellido_trgm")
    create_plain_trigram_index(:suplidores, :nombre, "index_suplidores_on_nombre_trgm")
    create_plain_trigram_index(:suplidores, :direccion, "index_suplidores_on_direccion_trgm")
    create_plain_trigram_index(:suplidores, :email, "index_suplidores_on_email_trgm")
    create_plain_trigram_index(:documentos_de_identidad, :documento, "index_documentos_de_identidad_on_documento_trgm")
  end

  private

  def create_immutable_unaccent_function
    execute <<~SQL
      CREATE OR REPLACE FUNCTION immutable_unaccent(text)
      RETURNS text
      LANGUAGE sql
      IMMUTABLE
      PARALLEL SAFE
      AS $$
        SELECT public.unaccent('public.unaccent', $1)
      $$
    SQL
  end

  def create_trigram_index(table, column, name)
    return if index_exists_by_name?(table, name)

    execute <<~SQL
      CREATE INDEX #{quote_column_name(name)}
      ON #{quote_table_name(table)}
      USING gin (immutable_unaccent(#{quote_column_name(column)}) gin_trgm_ops)
    SQL
  end

  def create_sort_index(table, columns, name)
    return if index_exists_by_name?(table, name)

    columns_sql = columns.map { |column| quote_column_name(column) }.join(", ")

    execute <<~SQL
      CREATE INDEX #{quote_column_name(name)}
      ON #{quote_table_name(table)} (#{columns_sql})
    SQL
  end

  def create_plain_trigram_index(table, column, name)
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
