class AddCamposXmlToDocumentos < ActiveRecord::Migration[7.0]
  def up
    # -------------------------------------------------------------------------
    # CABECERA FACTURA
    # -------------------------------------------------------------------------
    unless column_exists?(:cabecera_facturas, :fecha_hora_firma)
      add_column :cabecera_facturas,   :fecha_hora_firma,   :datetime
    end

    unless column_exists?(:cabecera_facturas, :trackId)
      add_column :cabecera_facturas,   :trackId,   :string
    end

    unless column_exists?(:cabecera_facturas, :security_code)
      add_column :cabecera_facturas,   :security_code,   :string
    end

    unless column_exists?(:cabecera_facturas, :xml_file_name)
      add_column :cabecera_facturas,   :xml_file_name,   :string
    end

    unless column_exists?(:cabecera_facturas, :qr_url_dgii)
      add_column :cabecera_facturas,   :qr_url_dgii,   :string
    end


    # -------------------------------------------------------------------------
    # NOTAS
    # -------------------------------------------------------------------------
    unless column_exists?(:notas, :fecha_hora_firma)
      add_column :notas,   :fecha_hora_firma,   :datetime
    end

    unless column_exists?(:notas, :trackId)
      add_column :notas,   :trackId,   :string
    end

    unless column_exists?(:notas, :security_code)
      add_column :notas,   :security_code,   :string
    end

    unless column_exists?(:notas, :xml_file_name)
      add_column :notas,   :xml_file_name,   :string
    end

    unless column_exists?(:notas, :qr_url_dgii)
      add_column :notas,   :qr_url_dgii,   :string
    end
  end

  def down
    # -------------------------------------------------------------------------
    # CABECERA FACTURA
    # -------------------------------------------------------------------------
    if column_exists?(:cabecera_facturas, :fecha_hora_firma)
      remove_column :cabecera_facturas,   :fecha_hora_firma
    end

    if column_exists?(:cabecera_facturas, :trackId)
      remove_column :cabecera_facturas,   :trackId
    end

    if column_exists?(:cabecera_facturas, :security_code)
      remove_column :cabecera_facturas,   :security_code
    end

    if column_exists?(:cabecera_facturas, :xml_file_name)
      remove_column :cabecera_facturas,   :xml_file_name
    end

    if column_exists?(:cabecera_facturas, :qr_url_dgii)
      remove_column :cabecera_facturas,   :qr_url_dgii
    end


    # -------------------------------------------------------------------------
    # NOTAS
    # -------------------------------------------------------------------------
    if column_exists?(:notas, :fecha_hora_firma)
      remove_column :notas,   :fecha_hora_firma
    end

    if column_exists?(:notas, :trackId)
      remove_column :notas,   :trackId
    end

    if column_exists?(:notas, :security_code)
      remove_column :notas,   :security_code
    end

    if column_exists?(:notas, :xml_file_name)
      remove_column :notas,   :xml_file_name
    end

    if column_exists?(:notas, :qr_url_dgii)
      remove_column :notas,   :qr_url_dgii
    end
  end
end
