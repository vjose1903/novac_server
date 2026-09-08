class CalendarEventSerializer < ActiveModel::Serializer
  extend FastSerializer


  ALL_OR_FIELD_FIELDS = [
    :id, :calendar_event_type_id, :title, :description, :location, :color, :starts_at, :ends_at,
    :start_date, :end_date, :all_day, :timezone, :recurrence_type, :recurrence_rule,
    :recurrence_interval, :recurrence_days, :recurrence_until, :recurrence_count, :google_uid,
    :ical_uid, :source, :is_global, :is_holiday, :is_working_day, :holiday_key
  ].freeze

  TIMESTAMP_FIELDS = [:starts_at, :ends_at, :start_date, :end_date, :recurrence_until].freeze






  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    data = serialize_record(object, fields, readers: readers)
    data[:deleted_at] = object.deleted_at&.as_json if has_to_show(params[:deleted_at])
    data[:calendar_event_type] = CalendarEventTypeSerializer.to_hash(object.calendar_event_type, { all: true }) if show_field?(:calendar_event_type, params)
    data[:links] = links_to_hash(object.calendar_event_links) if show_field?(:links, params)
    data[:google_calendar_url] = object.google_calendar_url if has_to_show(params[:google_calendar_url])
    data[:full_calendar] = Calendar::EventSerializer.new(object, include_links: params[:links]).as_json if has_to_show(params[:full_calendar])
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
    return @readers if defined?(@readers)
    @readers = {}
    TIMESTAMP_FIELDS.each do |field|
      @readers[field] = ->(record) { record.public_send(field)&.as_json }
    end
    @readers
  end

  def self.links_to_hash(links)
    CalendarEventLinkSerializer.collection_to_hash(links, { all: true })
  end
  private_class_method :links_to_hash
end
