#correr este comando cuando se modifique este archivo => whenever --update-crontab

ENV.each { |k, v| env(k, v) }

set :output, {:standard => 'log/cron.log', :error => 'log/error.log'}

set :environment, ENV['RAILS_ENV']


if ENV['RAILS_ENV'] != 'development'
  # Para lunes a viernes de 9AM a 7PM cada 2 horas
  every '0 9-19/2 * * 1-5' do
    rake 'db:backup'
  end

  # Para los sábados de 9AM a 12PM cada 2 horas
  every '0 9-13 * * 6' do
    rake 'db:backup'
  end
end