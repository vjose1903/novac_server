class AddCodigoToCabezaAsientoContable < ActiveRecord::Migration[7.0]
  def up
    # Añadir la nueva columna Codigo
    add_column :cabezas_asientos_contables,    :codigo, :string


    # Renombrar la columna actual
    rename_column :cabezas_asientos_contables, :fecha_anulacion,   :fecha_anulacion_old
    # Añadir la nueva columna con el nuevo tipo de dato
    add_column :cabezas_asientos_contables, :fecha_anulacion,   :datetime
    # Remover la columna fecha_anulacion_old
    remove_column :cabezas_asientos_contables, :fecha_anulacion_old

  end

  def down
    # Remover la columna Codigo
    remove_column :cabezas_asientos_contables, :codigo

    # Renombrar la columna actual
    rename_column :cabezas_asientos_contables, :fecha_anulacion,   :fecha_anulacion_old
    # Añadir la nueva columna con el nuevo tipo de dato
    add_column :cabezas_asientos_contables, :fecha_anulacion,   :date
    # Remover la columna fecha_anulacion_old
    remove_column :cabezas_asientos_contables, :fecha_anulacion_old
  end
end
