class AddCamposToDetalleFacturasNotas < ActiveRecord::Migration[7.0]

  def up
    # -------------------------------------------------------------------------
    # DETALLE NOTA
    # -------------------------------------------------------------------------
    unless column_exists?(:detalles_facturas_notas, :cantidad_origin)
      add_column :detalles_facturas_notas,   :cantidad_origin,   :float
    end

    unless column_exists?(:detalles_facturas_notas, :codigo)
      add_column :detalles_facturas_notas,   :codigo,   :string
    end

    # -------------------------------------------------------------------------
    # DETALLE FACTURA
    # -------------------------------------------------------------------------
    unless column_exists?(:detalle_facturas, :codigo)
      add_column :detalle_facturas,   :codigo,   :string
    end

    execute <<-SQL
      UPDATE detalles_facturas_notas
      SET codigo = (SELECT codigo FROM articulos WHERE articulos.id = detalles_facturas_notas.articulo_id)
    SQL

    execute <<-SQL
      UPDATE detalles_facturas_notas
      SET cantidad_origin = (SELECT cantidad FROM detalle_facturas WHERE detalle_facturas.id = detalles_facturas_notas.detalle_factura_id)
    SQL

    execute <<-SQL
      UPDATE detalle_facturas
      SET codigo = (SELECT codigo FROM articulos WHERE articulos.id = detalle_facturas.articulo_id)
    SQL

  end

  def down
    if column_exists?(:detalles_facturas_notas, :cantidad_origin)
      remove_column :detalles_facturas_notas,   :cantidad_origin
    end

    if column_exists?(:detalles_facturas_notas, :codigo)
      remove_column :detalles_facturas_notas,   :codigo
    end

    # if column_exists?(:detalle_facturas, :codigo)
    #   remove_column :detalle_facturas,   :codigo
    # end
  end

end
