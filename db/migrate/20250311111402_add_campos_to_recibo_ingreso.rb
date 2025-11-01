class AddCamposToReciboIngreso < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:recibos_ingresos, :bruto)
      add_column :recibos_ingresos,   :bruto,   :float
    end

    unless column_exists?(:recibos_ingresos, :mora)
      add_column :recibos_ingresos,   :mora,   :float
    end

    unless column_exists?(:recibos_ingresos, :balance_cliente)
      add_column :recibos_ingresos,   :balance_cliente,   :float
    end

    unless column_exists?(:detalle_recibos, :mora)
      add_column :detalle_recibos,   :mora,   :float
    end

    # Actualizar registros existentes: bruto = total, mora = 0
    execute "UPDATE recibos_ingresos SET bruto = total, mora = 0 WHERE bruto IS NULL"

    # Actualizar detalle_recibos: mora = 0
    execute "UPDATE detalle_recibos SET mora = 0 WHERE mora IS NULL"
  end

  def down
    if column_exists?(:recibos_ingresos, :bruto)
      remove_column :recibos_ingresos,   :bruto
    end

    if column_exists?(:recibos_ingresos, :mora)
      remove_column :recibos_ingresos,   :mora
    end

    if column_exists?(:recibos_ingresos, :balance_cliente)
      remove_column :recibos_ingresos,   :balance_cliente
    end

    if column_exists?(:detalle_recibos, :mora)
      remove_column :detalle_recibos,   :mora
    end
  end
end
