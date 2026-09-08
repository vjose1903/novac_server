class NotaSerializer < ActiveModel::Serializer
  extend FastSerializer



  ALL_OR_FIELD_FIELDS = [:id, :total, :bruto, :itbis, :identificador, :numero_documento, :numero_comprobante, :fecha_equivalente, :fecha_valida, :no_cliente_nombre, :no_cliente_direccion, :no_cliente_rnc, :estado, :tipo_factura_id, :serie, :razon, :fecha_hora_firma, :qr_url_dgii, :trackId, :security_code, :is_aceptada, :dgii_message, :cliente, :usuario, :tipo_factura, :facturas_aplicadas].freeze


  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :total, :bruto, :itbis, :identificador, :numero_documento, :numero_comprobante, :fecha_equivalente, :fecha_valida, :no_cliente_nombre, :no_cliente_direccion, :no_cliente_rnc, :estado, :tipo_factura_id, :serie, :razon, :fecha_hora_firma, :qr_url_dgii, :trackId, :security_code, :is_aceptada, :dgii_message, :cliente, :usuario, :tipo_factura, :facturas_aplicadas]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers
    {
      cliente: ->(record) {
        cliente = {}
        if record.cliente.blank?
          cliente[:nombre]            = record.no_cliente_nombre
          cliente[:nombre_completo]   = record.no_cliente_nombre
          cliente[:direccion]         = record.no_cliente_direccion
          cliente[:telefono]          = "----------"
          cliente[:rnc]               = record.no_cliente_rnc
        else
          client_                     = record.cliente.attributes
          cliente[:nombre]            = record.cliente.nombre_completo
          cliente[:telefono]          = client_[:telefono]
          cliente[:direccion]         = client_[:direccion]
          cliente[:nombre_completo]   = record.cliente.nombre_completo

          documento                   = record.cliente.documentos_de_identidad.find { |doc| doc.principal == true }
          cliente["rnc"]              = documento.nil? ? "----------" : documento.documento
        end
        cliente
      },
      usuario: ->(record) { record.user.nombre_completo },
      tipo_factura: ->(record) { record.tipo_factura.descripcion.titleize },
      facturas_aplicadas: ->(record) { FacturaAplicadaSerializer.collection_to_hash(record.facturas_aplicadas, {all: true}) }
    }
  end
end
