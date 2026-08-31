class DocumentReferenceSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                    if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }
  attribute :document_origin,       if: Proc.new { self.get_param('all') || has_to_show(self.get_param('document_origin')) }
  attribute :document_referenced,   if: Proc.new { self.get_param('all') || has_to_show(self.get_param('document_referenced')) }
  attribute :referenced_by,         if: Proc.new { self.get_param('all') || has_to_show(self.get_param('referenced_by')) }
  attribute :referenced_at,         if: Proc.new { self.get_param('all') || has_to_show(self.get_param('referenced_at')) }

  ALL_OR_FIELD_FIELDS = [:id, :document_origin, :document_referenced, :referenced_by, :referenced_at].freeze

  def document_origin
    optional_params = parse_serialize_optional_params(self.get_param('document_origin'), { all: false, id: true, numero_comprobante: true })
    serialize_parser(object.document_origin, optional_params)
  end

  def document_referenced
    optional_params = parse_serialize_optional_params(self.get_param('document_referenced'), { all: false, id: true, numero_comprobante: true })
    serialize_parser(object.document_referenced, optional_params)
  end

  def referenced_by
    optional_params = parse_serialize_optional_params(self.get_param('referenced_by'), { all: false, id: true, nombre_completo: true })
    serialize_parser(object.referenced_by, optional_params)
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers(params))
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

  def self.readers(params)
    {
      document_origin: ->(record) { document_to_hash(record.document_origin, parse_serialize_optional_params(params[:document_origin], { all: false, id: true, numero_comprobante: true })) },
      document_referenced: ->(record) { document_to_hash(record.document_referenced, parse_serialize_optional_params(params[:document_referenced], { all: false, id: true, numero_comprobante: true })) },
      referenced_by: ->(record) { referenced_by_to_hash(record.referenced_by, params) },
      referenced_at: ->(record) { record.referenced_at&.as_json }
    }
  end

  def self.document_to_hash(document, params)
    return nil unless document

    case document
    when CabeceraFactura
      CabeceraFacturaSerializer.to_hash(document, params)
    when Nota
      NotaSerializer.to_hash(document, params)
    else
      serialize_parser(document, params)
    end
  end

  def self.referenced_by_to_hash(user, params)
    return nil unless user
    UserSerializer.to_hash(user, parse_serialize_optional_params(params[:referenced_by], { all: false, id: true, nombre_completo: true }))
  end
  private_class_method :document_to_hash, :referenced_by_to_hash
end
