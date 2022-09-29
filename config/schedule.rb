
#correr este comando cuando se modifique este archivo => whenever --update-crontab

ENV.each { |k, v| env(k, v) }

set :output, {:standard => 'log/cron.log', :error => 'log/error.log'}

set :environment, ENV['RAILS_ENV']

every 1.hours do
	rake 'server_db:backup'
end



# every :day, at: ["09:00 AM", "12:00 PM", "03:00 PM", "05:30 PM", "09:00 PM" ] do
#     rake 'server_db:backup'
# end