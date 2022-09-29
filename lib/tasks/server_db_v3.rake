namespace :server_db do
  desc 'Backup DB and upload to Google Drive'
  task :backup_v3 do
    rails_env         = ENV.fetch("RAILS_ENV") { "development" }
    tulu              = ENV.fetch("TULU")
    timestamp         = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
    archive_path      = "#{Rails.root}/db/ADM_#{rails_env.downcase}_#{timestamp}.sql"

    ENV['PGPASSWORD'] = tulu

    pg_dump           = "pg_dump --verbose --format=c --inserts -U novacSystem -h db-dev --dbname=ADM_#{rails_env.downcase} -f #{archive_path}"
    `cd #{Rails.root}/public && #{pg_dump}`


    require "google/apis/drive_v3"
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "#{Rails.root}/config/google_api_credentials.json"

    drive                = Google::Apis::DriveV3::DriveService.new
    drive.authorization  = Google::Auth.get_application_default([Google::Apis::DriveV3::AUTH_DRIVE_FILE])

    metadata             = {title: File.basename(archive_path, '.sql')}
    file                 = drive.create_file(metadata, upload_source: archive_path, content_type: 'application/sql')

    EMAILS               = ['novacagrodemi@gmail.com']
    EMAILS.each do |email|
      perm_id   = drive.get_permission('novacagrodemi@gmail.com')
      perm_id   = drive.get_permission_id_for_email(email)
      perm      = Google::Apis::DriveV3::Permission.new(role: 'writer', id: perm_id.id, type: 'user')
      drive.insert_permission(file.id, perm)
    end


    FileUtils.remove_file(archive_path)
  end
end