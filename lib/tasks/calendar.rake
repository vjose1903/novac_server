namespace :calendar do
  namespace :holidays do
    desc 'Sincroniza feriados RD para los años indicados. Uso: rails calendar:holidays:sync[2026,2027,2028]'
    task :sync, [:years] => :environment do |_task, args|
      years = args[:years].to_s.split(',').map(&:to_i).select(&:positive?)
      raise 'Debe indicar al menos un año.' if years.empty?

      result = Calendar::HolidaySyncService.new(years: years).call
      raise result.get_msgs.join(', ') unless result.status_valid

      puts result.get_msgs.join(', ')
    end

    desc 'Sincroniza feriados RD para el año actual y los próximos 2 años'
    task sync_next_three_years: :environment do
      years = [Date.current.year, Date.current.year + 1, Date.current.year + 2]
      result = Calendar::HolidaySyncService.new(years: years).call
      raise result.get_msgs.join(', ') unless result.status_valid

      puts result.get_msgs.join(', ')
    end

    desc 'Genera los feriados faltantes del año actual y los próximos 2 años'
    task ensure_next_three_years: :environment do
      years = [Date.current.year, Date.current.year + 1, Date.current.year + 2]
      required_tables = %w[global_holidays calendar_events calendar_event_types]
      missing_tables = required_tables.reject { |table| ActiveRecord::Base.connection.data_source_exists?(table) }

      unless missing_tables.empty?
        puts "Se omite la sincronización de feriados; faltan tablas: #{missing_tables.join(', ')}."
        next
      end

      expected_holidays = Calendar::HolidayPythonProvider.new(years: years).call
      holidays_by_year = expected_holidays.group_by do |holiday|
        Date.parse((holiday['observed_date'].presence || holiday['date']).to_s).year
      end

      missing_years = years.select do |year|
        holidays = holidays_by_year[year] || []
        raise "No se recibieron feriados esperados para el año #{year}." if holidays.empty?

        holiday_keys = holidays.map do |holiday|
          holiday['holiday_key'].presence || begin
            date = Date.parse(holiday['date'].to_s)
            "#{Calendar::HolidaySyncService::COUNTRY_CODE}-#{date.strftime('%Y-%m-%d')}-#{holiday['name'].to_s.parameterize}"
          end
        end.uniq

        global_keys = GlobalHoliday.where(
          country_code: Calendar::HolidaySyncService::COUNTRY_CODE,
          year: year,
          holiday_key: holiday_keys
        ).pluck(:holiday_key)
        event_keys = CalendarEvent.active.where(
          holiday_key: holiday_keys,
          is_global: true,
          is_holiday: true
        ).pluck(:holiday_key)

        holiday_keys.any? { |key| !global_keys.include?(key) || !event_keys.include?(key) }
      end

      if missing_years.empty?
        puts 'Los feriados requeridos ya existen.'
        next
      end

      missing_holidays = expected_holidays.select do |holiday|
        effective_year = Date.parse((holiday['observed_date'].presence || holiday['date']).to_s).year
        missing_years.include?(effective_year)
      end
      provider = Object.new
      provider.define_singleton_method(:call) { missing_holidays }

      result = Calendar::HolidaySyncService.new(years: missing_years, provider: provider).call
      raise result.get_msgs.join(', ') unless result.status_valid

      puts result.get_msgs.join(', ')
    end
  end
end
