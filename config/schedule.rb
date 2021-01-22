
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
# every(:day, at: '16:54') do 
# # every 2.minutes do 
#   puts "ejecutando tarea....."
#   command "rake 'server_db:backup'"
# end