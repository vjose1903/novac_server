class EcfReceptionSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,              if: Proc.new { has_to_show(self.get_param('id'))            || self.get_param('all') }
  attribute :eNCF,            if: Proc.new { has_to_show(self.get_param('eNCF'))          || self.get_param('all') }
  attribute :rnc_emisor,      if: Proc.new { has_to_show(self.get_param('rnc_emisor'))    || self.get_param('all') }
  attribute :rnc_comprador,   if: Proc.new { has_to_show(self.get_param('rnc_comprador')) || self.get_param('all') }
  attribute :monto_total,     if: Proc.new { has_to_show(self.get_param('monto_total'))   || self.get_param('all') }
  attribute :suplidor_id,     if: Proc.new { has_to_show(self.get_param('suplidor_id'))   || self.get_param('all') }
  attribute :suplidor,        if: Proc.new { has_to_show(self.get_param('suplidor')) }

  ALL_OR_FIELD_FIELDS = [:id, :eNCF, :rnc_emisor, :rnc_comprador, :monto_total, :suplidor_id].freeze

  def rnc_emisor
    format_rnc(object.rnc_emisor)
  end

  def rnc_comprador
    format_rnc(object.rnc_comprador)
  end

  def suplidor
    optional_params = parse_serialize_optional_params(self.get_param('suplidor'), { all: false, id: true, nombre: true  })
    serialize_parser(object.suplidor, optional_params)
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    data = serialize_record(object, fields, readers: readers)
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

  def self.suplidor_to_hash(suplidor, param)
    return nil unless suplidor
    optional = parse_serialize_optional_params(param, { all: false, id: true, nombre: true })
    optional.delete(:documentos_de_identidad) unless has_to_show(param&.dig(:documentos_de_identidad))
    SuplidorSerializer.to_hash(suplidor, optional)
  end
  private_class_method :suplidor_to_hash
end
