require 'open3'

namespace :db do
  desc "Backup DB and upload to Google Drive"
  task backup: :environment do
    puts "\n|==============================|"
    puts "|        CREANDO BACKUP        |"
    puts "|==============================|\n"

    tulu              = ENV.fetch("TULU")
    fraga             = ENV.fetch("FRAGA")
    montu             = ENV.fetch("MONTU")
    rails_env         = ENV.fetch("RAILS_ENV") { "development" }.downcase
    db_name           = ENV.fetch("ALMACEN")

    ENV['PGPASSWORD'] = tulu
    host              = rails_env == 'development' ? 'db-dev' : 'db-prod'
    backup_name       = "#{db_name}_#{rails_env}.sql"
    archive_path      = "#{PROJECT_PATH}/db/#{backup_name}"
    pg_dump           = "pg_dump --format=c --inserts -U #{fraga} -h #{host} --dbname=#{db_name}_#{rails_env} -f #{archive_path}"

    stdout, stderr, status = Open3.capture3(pg_dump)

    if status.success?
      puts "\n============ BACKUP #{rails_env} CREADO ============\n"
      upload_file(backup_name, montu) if rails_env != "development"
    else
      puts "\n|=========================================|"
      puts "|         ERROR AL REALIZAR BACKUP        |"
      puts "|=========================================|\n"
      puts "Error:\n#{stderr}"
    end

    FileUtils.remove_file(archive_path)
  end

  def npm_installed?
    installed = system("npm --version > /dev/null 2>&1")

    if installed
      puts "\n|===========================================|"
      puts "|         NPM INSTALADO EN EL SISTEMA       |"
      puts "|===========================================|\n"
    else
      puts "\n|=========================================================|"
      puts "|         NPM NO INSTALADO PROCEDIENDO A INSTALARLO       |"
      puts "|=========================================================|\n"
      success = system("apt-get update && apt-get install -y npm")

      if success
        installed = true
      else
        puts "\n|=========================================|"
        puts "|         NPM NO PUDO SER INSTALADO       |"
        puts "|=========================================|\n"
      end
    end

    installed
  end

  def upload_file(file_name, montu)
    script_path = "#{PROJECT_PATH}/config/initializers/google/upload_backup.js"

    return false unless npm_installed?

    if system("npm list --depth 0 googleapis")
      puts "\n|===================================================|"
      puts "|         googleapis INSTALADO en el sistema        |"
      puts "|===================================================|\n"
    else
      puts "\n|===============================================================|"
      puts "|         googleapis NO INSTALADO procediendo a instalar        |"
      puts "|===============================================================|\n"
      system("npm install googleapis")
    end

    system("node #{script_path} #{file_name} #{montu}")
  end
end