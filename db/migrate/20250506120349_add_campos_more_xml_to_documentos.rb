class AddCamposMoreXmlToDocumentos < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:notas, :is_aceptada)
      add_column :notas,   :is_aceptada,   :boolean
    end

    unless column_exists?(:notas, :dgii_message)
      add_column :notas,   :dgii_message,   :string
    end

    unless column_exists?(:cabecera_facturas, :is_aceptada)
      add_column :cabecera_facturas,   :is_aceptada,   :boolean
    end

    unless column_exists?(:cabecera_facturas, :dgii_message)
      add_column :cabecera_facturas,   :dgii_message,   :string
    end

  end

  def down
    if column_exists?(:notas, :is_aceptada)
      remove_column :notas,   :is_aceptada
    end

    if column_exists?(:notas, :dgii_message)
      remove_column :notas,   :dgii_message
    end

    if column_exists?(:cabecera_facturas, :is_aceptada)
      remove_column :cabecera_facturas,   :is_aceptada
    end

    if column_exists?(:cabecera_facturas, :dgii_message)
      remove_column :cabecera_facturas,   :dgii_message
    end
  end
end
