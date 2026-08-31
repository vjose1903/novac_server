class CalendarEventLinkSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id, if: Proc.new { get_param('all') || get_param('id') }
  attribute :calendar_event_id, if: Proc.new { get_param('all') || get_param('calendar_event_id') }
  attribute :linkable_type, if: Proc.new { get_param('all') || get_param('linkable_type') }
  attribute :linkable_id, if: Proc.new { get_param('all') || get_param('linkable_id') }
  attribute :label, if: Proc.new { get_param('all') || get_param('label') }
  attribute :metadata, if: Proc.new { get_param('all') || get_param('metadata') }

  ALL_OR_FIELD_FIELDS = [:id, :calendar_event_id, :linkable_type, :linkable_id, :label, :metadata].freeze

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
