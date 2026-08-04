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
  end
end
