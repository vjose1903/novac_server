class CalendarEventTypeSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id, if: Proc.new { get_param('all') || get_param('id') }
  attribute :name, if: Proc.new { get_param('all') || get_param('name') }
  attribute :slug, if: Proc.new { get_param('all') || get_param('slug') }
  attribute :color, if: Proc.new { get_param('all') || get_param('color') }
  attribute :is_system, if: Proc.new { get_param('all') || get_param('is_system') }
  attribute :active, if: Proc.new { get_param('all') || get_param('active') }
  attribute :sort_order, if: Proc.new { get_param('all') || get_param('sort_order') }

  ALL_OR_FIELD_FIELDS = [:id, :name, :slug, :color, :is_system, :active, :sort_order].freeze

  def get_param(col)
    @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_field?(field, params) }, readers: readers)
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
    {}
  end
end
