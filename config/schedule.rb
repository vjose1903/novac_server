
#correr este comando cuando se modifique este archivo => whenever --update-crontab

ENV.each { |k, v| env(k, v) }

set :output, {:standard => 'log/cron.log', :error => 'log/error.log'}

set :environment, ENV['RAILS_ENV']


every 1.minute do
	rake 'db:backup'
end
