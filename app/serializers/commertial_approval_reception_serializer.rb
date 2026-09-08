class CommertialApprovalReceptionSerializer < ActiveModel::Serializer
  extend FastSerializer


  ALL_OR_FIELD_FIELDS = [:id, :eNCF, :rnc_emisor, :rnc_comprador, :monto_total, :estado, :detalleMotivoRechazo, :cabecera_factura_id, :suplidor_id].freeze






  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    data = serialize_record(object, fields, readers: readers)
    data[:cabecera_factura] = cabecera_factura_to_hash(object.cabecera_factura, params[:cabecera_factura]) if has_to_show(params[:cabecera_factura])
    data[:suplidor] = suplidor_to_hash(object.suplidor, params[:suplidor]) if has_to_show(params[:suplidor])
    data
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    ALL_OR_FIELD_FIELDS
  end

  def self.show_field?(field, params)
    params[:all] || has_to_show(params[field])
  end

  def self.readers
    {
      rnc_emisor: ->(record) { format_rnc(record.rnc_emisor) },
      rnc_comprador: ->(record) { format_rnc(record.rnc_comprador) }
    }
  end

  def self.cabecera_factura_to_hash(factura, param)
    return nil unless factura
    CabeceraFacturaSerializer.to_hash(factura, parse_serialize_optional_params(param, { all: false, id: true, numero_comprobante: true }))
  end

  def self.suplidor_to_hash(suplidor, param)
    return nil unless suplidor
    optional = parse_serialize_optional_params(param, { all: false, id: true, nombre: true })
    optional.delete(:documentos_de_identidad) unless has_to_show(param&.dig(:documentos_de_identidad))
    SuplidorSerializer.to_hash(suplidor, optional)
  end
  private_class_method :cabecera_factura_to_hash, :suplidor_to_hash
end
