module Calendar
  class HolidaySyncService
    COUNTRY_CODE = 'DO'.freeze

    def initialize(years:, provider: nil)
      @years = Array(years).map(&:to_i).uniq.sort
      @provider = provider || HolidayPythonProvider.new(years: @years)
    end

    def call
      res = Response.new

      CalendarEvent.transaction do
        CalendarEventType.seed_defaults
        event_type = CalendarEventType.holiday_type
        holidays = @provider.call

        holidays.each do |holiday_data|
          holiday = upsert_global_holiday(holiday_data)
          upsert_calendar_event(holiday, event_type)
        end

        res.add_msg('Feriados sincronizados correctamente.')
        res.set_data(GlobalHoliday.where(year: @years).order('date ASC'), { all: true })
      rescue StandardError => e
        res.add_msg(e.message)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      ensure
        raise ActiveRecord::Rollback unless res.status_valid
      end

      res
    end

    private

    def upsert_global_holiday(data)
      date = Date.parse(data['date'].to_s)
      observed_date = data['observed_date'].present? ? Date.parse(data['observed_date'].to_s) : nil
      holiday_key = data['holiday_key'].presence || build_holiday_key(date, data['name'])

      holiday = GlobalHoliday.where(country_code: COUNTRY_CODE, holiday_key: holiday_key).first_or_initialize
      holiday.assign_attributes(
        name: data['name'],
        date: date,
        observed_date: observed_date,
        year: (observed_date || date).year,
        source: data['source'].presence || 'python_holidays',
        is_working_day: data.key?('is_working_day') ? data['is_working_day'] : false,
        metadata: data['metadata'] || {}
      )
      holiday.save!
      holiday
    end

    def upsert_calendar_event(holiday, event_type)
      date = holiday.effective_date
      timezone = ActiveSupport::TimeZone[CalendarEvent::TIMEZONE_DEFAULT]

      event = CalendarEvent.where(holiday_key: holiday.holiday_key, is_global: true, is_holiday: true).first_or_initialize
      event.assign_attributes(
        calendar_event_type_id: event_type.id,
        title: holiday.name,
        description: holiday.name,
        location: nil,
        color: nil,
        starts_at: timezone.local(date.year, date.month, date.day).beginning_of_day,
        ends_at: timezone.local(date.year, date.month, date.day).end_of_day,
        start_date: date,
        end_date: date,
        all_day: true,
        timezone: CalendarEvent::TIMEZONE_DEFAULT,
        recurrence_type: 'none',
        recurrence_rule: nil,
        recurrence_interval: 1,
        recurrence_days: [],
        recurrence_until: nil,
        recurrence_count: nil,
        source: 'holiday',
        is_global: true,
        is_holiday: true,
        is_working_day: holiday.is_working_day,
        deleted_at: nil
      )
      event.save!
      event
    end

    def build_holiday_key(date, name)
      "#{COUNTRY_CODE}-#{date.strftime('%Y-%m-%d')}-#{name.to_s.parameterize}"
    end
  end
end
