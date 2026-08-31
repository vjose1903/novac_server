class CuadreCajaEventoSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id, if: Proc.new { get_param('id') || get_param('all') }
  attribute :event_type, if: Proc.new { get_param('event_type') || get_param('all') }
  attribute :from_status, if: Proc.new { get_param('from_status') || get_param('all') }
  attribute :to_status, if: Proc.new { get_param('to_status') || get_param('all') }
  attribute :reason, if: Proc.new { get_param('reason') || get_param('all') }
  attribute :metadata, if: Proc.new { get_param('metadata') || get_param('all') }
  attribute :created_at, if: Proc.new { get_param('created_at') || get_param('all') }
  attribute :user, if: Proc.new { get_param('user') || get_param('all') }

  ALL_OR_FIELD_FIELDS = [:id, :event_type, :from_status, :to_status, :reason, :metadata, :created_at, :user].freeze

  def user
    serialize_parser(object.user, { id: true, nombre: true, apellido: true, nombre_completo: true })
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :event_type, :from_status, :to_status, :reason, :metadata, :created_at, :user]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers
    {
      created_at: ->(record) { record.created_at&.as_json },
      user: ->(record) { record.user ? UserSerializer.to_hash(record.user, { id: true, nombre: true, apellido: true, nombre_completo: true }) : nil }
    }
  end
end
