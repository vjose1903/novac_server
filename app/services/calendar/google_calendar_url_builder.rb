module Calendar
  class GoogleCalendarUrlBuilder
    BASE_URL = 'https://calendar.google.com/calendar/render'.freeze

    def initialize(event)
      @event = event
    end

    def url
      query = {
        action: 'TEMPLATE',
        text: @event.title,
        dates: dates_value,
        details: details_value,
        location: @event.location,
        ctz: @event.timezone
      }

      query[:recur] = "RRULE:#{@event.recurrence_rule}" if @event.recurrence_rule.present?
      "#{BASE_URL}?#{query.compact.to_query}"
    end

    private

    def dates_value
      return "#{@event.start_date.strftime('%Y%m%d')}/#{(@event.end_date + 1.day).strftime('%Y%m%d')}" if @event.all_day

      start_value = @event.starts_at.utc.strftime('%Y%m%dT%H%M%SZ')
      end_value = @event.ends_at.utc.strftime('%Y%m%dT%H%M%SZ')
      "#{start_value}/#{end_value}"
    end

    def details_value
      @event.description.to_s
    end
  end
end
