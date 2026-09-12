#correr este comando cuando se modifique este archivo => whenever --update-crontab

ENV.each { |k, v| env(k, v) }

set :output, {:standard => 'log/cron.log', :error => 'log/error.log'}

set :environment, ENV['RAILS_ENV']


# Para lunes a viernes de 9AM a 7PM cada 2 horas
every '0 9-19/2 * * 1-5' do
	rake 'db:backup'
end

# Para los sábados de 9AM a 12PM cada 2 horas
every '0 9-13 * * 6' do
	rake 'db:backup'
end

# Verifica diariamente los feriados globales de República Dominicana para el año actual
# y los próximos 2 años. La tarea solo genera los años faltantes.
every '0 3 * * *' do
	rake 'calendar:holidays:ensure_next_three_years'
end
