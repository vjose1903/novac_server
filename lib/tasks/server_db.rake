namespace :server_db do
  desc 'Backup DB and upload to Google Drive'
  task :backup do
    rails_env = ENV.fetch("RAILS_ENV") { "development" }
    
    timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
    archive_path = "#{Rails.root}/db/ADM_#{rails_env.downcase}_#{timestamp}.sql"

    host = ENV.fetch("PGHOST") { "admservidor.ddns.net" }
    puts "host ==> ".red + "#{host}"
    ENV['PGPASSWORD'] = "Vasquez1903"
    pg_dump = "pg_dump --verbose --format=c --inserts -U postgres -h admservidor.ddns.net --dbname=ADM_#{rails_env.downcase} -f #{archive_path}"
    `cd #{Rails.root}/public && #{pg_dump}`

    require 'google/apis/drive_v2'
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "#{Rails.root}/config/google_api_credentials.json"
    drive = Google::Apis::DriveV2::DriveService.new
    drive.authorization = Google::Auth.get_application_default([Google::Apis::DriveV2::AUTH_DRIVE_FILE])

    metadata = {title: File.basename(archive_path, '.sql')}
    file = drive.insert_file(metadata, upload_source: archive_path, content_type: 'application/sql')

    EMAILS = ['vjposystem@gmail.com']
    EMAILS.each do |email|
      perm_id = drive.get_permission_id_for_email(email)
      perm = Google::Apis::DriveV2::Permission.new(role: 'writer', id: perm_id.id, type: 'user')
      drive.insert_permission(file.id, perm)
    end
    

    #prueba de application sql
    # FileUtils.remove_file(archive_path)
  end
end

