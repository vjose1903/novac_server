namespace :server_db do
  desc 'Backup DB and upload to Google Drive'
  task :backup do
    rails_env = ENV.fetch("RAILS_ENV") { "development" }
    db = "ADM_#{rails_env.downcase}"
    
    pg_dump = "pg_dump --no-acl --no-owner -U postgres ADM_#{rails_env.downcase}"
    timestamp = Time.now.strftime('%Y-%m-%d-%H%M%S')
    archive_path = "#{Rails.root}/db/ADM_#{rails_env.downcase}_#{timestamp}.sql"

    cmd = nil
    # with_config do |app, host, db, user|
        # cmd = "pg_dump -U postgres -W -F t #{db} > #{archive_path}"

        
        cmd = "pg_dump --verbose --format=c --inserts --dbname=#{db} -f #{archive_path}"

    # end

    puts cmd
    exec cmd

    # 
    # 
    # 


    # `cd #{Rails.root}/public && #{pg_dump} | bzip2 - - > #{archive_path}`
    # `cd #{Rails.root}/public && #{pg_dump} > #{archive_path}`

    # require 'google/apis/drive_v2'
    # ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "#{Rails.root}/config/google_api_credentials.json"
    # drive = Google::Apis::DriveV2::DriveService.new
    # drive.authorization = Google::Auth.get_application_default([Google::Apis::DriveV2::AUTH_DRIVE_FILE])

    # metadata = {title: File.basename(archive_path, '.sql')}
    # file = drive.insert_file(metadata, upload_source: archive_path, content_type: 'application/x-bzip2')

    # EMAILS = ['vjposystem@gmail.com']
    # EMAILS.each do |email|
    #   perm_id = drive.get_permission_id_for_email(email)
    #   perm = Google::Apis::DriveV2::Permission.new(role: 'writer', id: perm_id.id, type: 'user')
    #   drive.insert_permission(file.id, perm)
    # end
    

    # FileUtils.remove_file(archive_path)
  end
end

# export GOOGLE_APPLICATION_CREDENTIALS="/Users/domingoconcepcion/git/servidorADMAgro/config/google_api_credentials.json"

# pg_dump -U postgres -W -F t ADM_development > /Users/vjose1903/git/personal/serverRa
