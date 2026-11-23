class ChangeFechaEquivalenteTypeTransferencias < ActiveRecord::Migration[7.0]
  def up
    # Renombrar la columna actual
    rename_column :transferencias, :fecha_anulacion,   :fecha_anulacion_old

    # Añadir la nueva columna con el nuevo tipo de dato
    add_column :transferencias, :fecha_anulacion,   :datetime

    # Transferir los datos de la columna antigua a la nueva
    Transferencia.reset_column_information
    Transferencia.find_each do | transferencia |
      transferencia.update_column(:fecha_anulacion,   transferencia.fecha_anulacion_old)
    end

    # Eliminar la columna antigua
    remove_column :transferencias, :fecha_anulacion_old
  end

  def down
    # Añadir la columna antigua
    add_column :transferencias, :fecha_anulacion_old, :date

    # Transferir los datos de la nueva columna a la antigua
    Transferencia.reset_column_information
    Transferencia.find_each do | transferencia |
      transferencia.update_column(:fecha_anulacion_old,   transferencia.fecha_anulacion)
    end

    # Eliminar la nueva columna
    remove_column :transferencias, :fecha_anulacion

    # Renombrar la columna antigua
    rename_column :transferencias, :fecha_anulacion_old,   :fecha_anulacion
  end
end
