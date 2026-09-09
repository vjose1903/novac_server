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
      missing_years = years.select do |year|
        holidays = GlobalHoliday.where(country_code: Calendar::HolidaySyncService::COUNTRY_CODE, year: year)
        holiday_keys = holidays.pluck(:holiday_key)
        events_count = CalendarEvent.where(
          holiday_key: holiday_keys,
          is_global: true,
          is_holiday: true
        ).count

        holiday_keys.empty? || events_count < holiday_keys.length
      end

      if missing_years.empty?
        puts 'Los feriados requeridos ya existen.'
        next
      end

      result = Calendar::HolidaySyncService.new(years: missing_years).call
      raise result.get_msgs.join(', ') unless result.status_valid

      puts result.get_msgs.join(', ')
    end
  end
end
