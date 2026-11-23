namespace :db do
  desc "Backup DB and upload to Google Drive"
  task backup: :environment do
    puts " "
    puts "|==============================|"
    puts "|        CREANDO BACKUP        |"
    puts "|==============================|"
    puts " "

    rails_env              = ENV.fetch("RAILS_ENV") { "development" }

		tulu                 = ENV.fetch("TULU")
		timestamp            = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
		archive_path         = "#{Rails.root}/db/ADM_#{rails_env.downcase}_#{timestamp}.sql"

		ENV['PGPASSWORD'] = tulu
		host                 = rails_env == 'development' ? 'db-dev' : 'db-prod'

		pg_dump              = "pg_dump --format=c --inserts -U novacSystem -h #{host} --dbname=ADM_#{rails_env.downcase} -f #{archive_path}"

		`cd #{Rails.root}/public && #{pg_dump}`

    if rails_env != "development"
			require 'google/apis/drive_v2'

      ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "#{Rails.root}/config/google_api_credentials.json"
      drive                = Google::Apis::DriveV2::DriveService.new
      drive.authorization  = Google::Auth.get_application_default([Google::Apis::DriveV2::AUTH_DRIVE_FILE])

      metadata             = {title: File.basename(archive_path, '.sql')}
      file                 = drive.insert_file(metadata, upload_source: archive_path, content_type: 'application/sql')

      EMAILS               = ['novacagrodemi@gmail.com']
      EMAILS.each do |email|
        perm_id   = drive.get_permission_id_for_email(email)
        perm      = Google::Apis::DriveV2::Permission.new(role: 'writer', id: perm_id.id, type: 'user')
        drive.insert_permission(file.id, perm, send_notification_emails: false)
      end

      FileUtils.remove_file(archive_path)

      puts " "
      puts "|==============================|"
      puts "|         BACKUP CREADO        |"
      puts "|==============================|"
      puts " "
		else
      puts " "
      puts "|==============================|"
      puts "|  BACKUP DEVELOPMENT CREADO   |"
      puts "|==============================|"
      puts " "
    end
  end

end
