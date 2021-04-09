
#correr este comando cuando se modifique este archivo => whenever --update-crontab

set :output, "log/cron.log"

# set :environment, "development"
set :environment, "production"

# every :day, at: ["09:00 AM", "12:00 PM", "03:00 PM", "05:30 PM", "09:00 PM" ] do
#     puts "-------- EJECUTANDO TAREAS PARA EL BACKUP --------"
#     rake 'server_db:backup'
# end

# every :day, at: ["09:00 AM", "12:00 PM", "04:00 PM"] do
#     puts "-------- EJECUTANDO TAREAS PARA CHEQUEAR EL BALANCE DE LOS CLIENTES --------"
#     runner "Cliente.checkBalanceClientes"
# end

# every 1.minutes do
#     puts "-------- EJECUTANDO TAREAS PARA EL BACKUP --------"
#     rake 'server_db:backup'
# end
