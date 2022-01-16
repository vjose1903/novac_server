
#correr este comando cuando se modifique este archivo => whenever --update-crontab

set :output, "log/cron.log"

# set :environment, "development"
set :environment, "production"

every :day, at: ["09:00 AM", "12:00 PM", "03:00 PM", "05:30 PM", "09:00 PM" ] do
    rake 'server_db:backup'
end

every 1.hours do
    runner "Cliente.checkBalanceClientes"
end
# every :day, at: ["09:00 AM", "12:00 PM", "02:25 PM", "04:00 PM"] do

# every 1.minutes do
#     rake 'server_db:backup'
# end
