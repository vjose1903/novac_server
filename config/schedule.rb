
#correr este comando cuando se modifique este archivo => whenever --update-crontab

set :output, "log/cron.log"

set :environment, "development"

# # every(:day, at: '4:47:21 pm') do #{ rake 'server_db:backup' }
# every 1.minutes, roles: [:app] do
#   puts "ejecutando tarea 000 ....."
#   rake 'server_db:backup'
# end

# every :day, at: '04:18pm' do 
#   puts "ejecutando tarea....."
#   command "rake 'server_db:backup'"
# end

every :day, at: ["10:05 AM", "10:07 AM"] do
    puts "-------- EJECUTANDO TAREAS PARA EL BACKUP --------"
    rake 'server_db:backup'
end

# every :day, at: ["9:48 AM", "12:00 PM"] do
# # every 2.minutes do
#   puts "ejecutando tarea....."
#   command "rake 'server_db:backup'"
# end




# 48 9 * * * /bin/bash -l -c 'rake '\''server_db:backup'\'' >> log/cron.log 2>&1'

# 0 12 * * * /bin/bash -l -c 'rake '\''server_db:backup'\'' >> log/cron.log 2>&1'

# 48 9 * * * /bin/bash -l -c 'rake '\''server_db:backup'\'' >> log/cron.log 2>&1'
# * * * * * /bin/bash -l -c 'cd /Users/vjose1903/git/personal/serverRa && RAILS_ENV=development bundle exec rake server_db:backup --silent >> log/cron.log 2>&1'

# 0 12 * * * /bin/bash -l -c 'rake '\''server_db:backup'\'' >> log/cron.log 2>&1'