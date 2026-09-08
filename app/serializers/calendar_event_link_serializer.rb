class CalendarEventLinkSerializer < ActiveModel::Serializer
  extend FastSerializer


  ALL_OR_FIELD_FIELDS = [:id, :calendar_event_id, :linkable_type, :linkable_id, :label, :metadata].freeze


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
