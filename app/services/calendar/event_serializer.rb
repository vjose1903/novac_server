module Calendar
  class EventSerializer
    TEXT_COLOR = '#ffffff'

    def initialize(events, include_links: false)
      @events = events
      @include_links = include_links
    end

    def as_json
      return serialize_event(@events) unless @events.respond_to?(:map)

      @events.map { |event| serialize_event(event) }
    end

    private

    def serialize_event(event)
      color = event.display_color

      {
        id: event.id,
        title: event.title,
        start: serialize_start(event),
        end: serialize_end(event),
        allDay: event.all_day,
        backgroundColor: color,
        borderColor: color,
        textColor: TEXT_COLOR,
        extendedProps: extended_props(event)
      }
    end

    def serialize_start(event)
      return event.start_date.iso8601 if event.all_day

      event.starts_at.in_time_zone(event.timezone).iso8601
    end

    def serialize_end(event)
      return (event.end_date + 1.day).iso8601 if event.all_day

      event.ends_at.in_time_zone(event.timezone).iso8601
    end

    def extended_props(event)
      props = {
        description: event.description,
        location: event.location,
        typeId: event.calendar_event_type_id,
        typeName: event.calendar_event_type.name,
        typeSlug: event.calendar_event_type.slug,
        isGlobal: event.is_global,
        isHoliday: event.is_holiday,
        isWorkingDay: event.is_working_day,
        source: event.source,
        timezone: event.timezone,
        recurrenceRule: event.recurrence_rule,
        holidayKey: event.holiday_key
      }

      props[:links] = serialize_links(event) if @include_links
      props
    end

    def serialize_links(event)
      event.calendar_event_links.map do |link|
        {
          id: link.id,
          linkable_type: link.linkable_type,
          linkable_id: link.linkable_id,
          label: link.label,
          metadata: link.metadata
        }
      end
    end
  end
end
