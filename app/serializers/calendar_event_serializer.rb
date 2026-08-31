class CalendarEventSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id, if: Proc.new { get_param('all') || get_param('id') }
  attribute :calendar_event_type_id, if: Proc.new { get_param('all') || get_param('calendar_event_type_id') }
  attribute :title, if: Proc.new { get_param('all') || get_param('title') }
  attribute :description, if: Proc.new { get_param('all') || get_param('description') }
  attribute :location, if: Proc.new { get_param('all') || get_param('location') }
  attribute :color, if: Proc.new { get_param('all') || get_param('color') }
  attribute :starts_at, if: Proc.new { get_param('all') || get_param('starts_at') }
  attribute :ends_at, if: Proc.new { get_param('all') || get_param('ends_at') }
  attribute :start_date, if: Proc.new { get_param('all') || get_param('start_date') }
  attribute :end_date, if: Proc.new { get_param('all') || get_param('end_date') }
  attribute :all_day, if: Proc.new { get_param('all') || get_param('all_day') }
  attribute :timezone, if: Proc.new { get_param('all') || get_param('timezone') }
  attribute :recurrence_type, if: Proc.new { get_param('all') || get_param('recurrence_type') }
  attribute :recurrence_rule, if: Proc.new { get_param('all') || get_param('recurrence_rule') }
  attribute :recurrence_interval, if: Proc.new { get_param('all') || get_param('recurrence_interval') }
  attribute :recurrence_days, if: Proc.new { get_param('all') || get_param('recurrence_days') }
  attribute :recurrence_until, if: Proc.new { get_param('all') || get_param('recurrence_until') }
  attribute :recurrence_count, if: Proc.new { get_param('all') || get_param('recurrence_count') }
  attribute :google_uid, if: Proc.new { get_param('all') || get_param('google_uid') }
  attribute :ical_uid, if: Proc.new { get_param('all') || get_param('ical_uid') }
  attribute :source, if: Proc.new { get_param('all') || get_param('source') }
  attribute :is_global, if: Proc.new { get_param('all') || get_param('is_global') }
  attribute :is_holiday, if: Proc.new { get_param('all') || get_param('is_holiday') }
  attribute :is_working_day, if: Proc.new { get_param('all') || get_param('is_working_day') }
  attribute :holiday_key, if: Proc.new { get_param('all') || get_param('holiday_key') }
  attribute :deleted_at, if: Proc.new { get_param('deleted_at') }
  attribute :calendar_event_type, if: Proc.new { get_param('all') || get_param('calendar_event_type') }
  attribute :links, if: Proc.new { get_param('all') || get_param('links') }
  attribute :google_calendar_url, if: Proc.new { get_param('google_calendar_url') }
  attribute :full_calendar, if: Proc.new { get_param('full_calendar') }

  ALL_OR_FIELD_FIELDS = [
    :id, :calendar_event_type_id, :title, :description, :location, :color, :starts_at, :ends_at,
    :start_date, :end_date, :all_day, :timezone, :recurrence_type, :recurrence_rule,
    :recurrence_interval, :recurrence_days, :recurrence_until, :recurrence_count, :google_uid,
    :ical_uid, :source, :is_global, :is_holiday, :is_working_day, :holiday_key
  ].freeze

  TIMESTAMP_FIELDS = [:starts_at, :ends_at, :start_date, :end_date, :recurrence_until].freeze

  def calendar_event_type
    serialize_parser(object.calendar_event_type, { all: true })
  end

  def links
    serialize_parser(object.calendar_event_links, { all: true })
  end

  def google_calendar_url
    object.google_calendar_url
  end

  def full_calendar
    Calendar::EventSerializer.new(object, include_links: get_param('links')).as_json
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

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
