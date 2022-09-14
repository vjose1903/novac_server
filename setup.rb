# ruby ./setup.rb brendy

@clientes             = ['brendy', 'agrodemi', 'vasquez']
@tipo_selected        = ARGV[0]
@environment_selected = ARGV[1]

@setup_               = {
	:agrodemi => {
		:DATABASE_NAME          => "ADM",
		:ENVIRONMENT_NAME_IMG   => "agrodemi-",
		:DB_PATH                => "db-agrodemi-data",
		:DB_PORT                => "3000",
		:FRONT_PORT             => "9090",
		:NGINX_SERVER_NAME      => "localhost admservidor.ddns.net *.admservidor.ddns.net"
	},
	:brendy => {
		:DATABASE_NAME          => "panaderia_brendy",
		:ENVIRONMENT_NAME_IMG   => "brendy-",
		:DB_PATH                => "db-brendy-data",
		:DB_PORT                => "3001",
		:FRONT_PORT             => "9091",
		:NGINX_SERVER_NAME      => "localhost novac-brendy.ddns.net *.novac-brendy.ddns.net"
	},
	:vasquez => {
		:DATABASE_NAME          => "vasquez_services",
		:ENVIRONMENT_NAME_IMG   => "vasquez-",
		:DB_PATH                => "db-vasquez-data",
		:DB_PORT                => "3002",
		:FRONT_PORT             => "9092",
		:NGINX_SERVER_NAME      => "localhost"
	},
}

@files         = [
	{ :tipo => 'move',       :file_name => 'google_api_credentials',  :extension => 'json', :path => 'config/google_api_credentials.json' },
	{ :tipo => 'move',       :file_name => 'schedule',                :extension => 'rb',   :path => 'config/schedule.rb' },
	{ :tipo => 'move',       :file_name => 'seedConstantes',          :extension => 'rb',   :path => 'config/initializers/global/seedConstantes.rb' },
	{ :tipo => 'move',       :file_name => 'server_db',               :extension => 'rake', :path => 'lib/tasks/server_db.rake' },

	{ :tipo => 'reemplazo',  :file_name => 'docker-compose.prod.yml',                       :path => 'docker-compose.prod.yml' },
	{ :tipo => 'reemplazo',  :file_name => 'docker-compose.yml',                            :path => 'docker-compose.yml' },
	{ :tipo => 'reemplazo',  :file_name => 'Dockerfile',                                    :path => 'docker/services/server/Dockerfile' },
	{ :tipo => 'reemplazo',  :file_name => 'default.conf',                                  :path => 'docker/services/nginx/default.conf' },
	{ :tipo => 'reemplazo',  :file_name => 'run_server.sh',                                 :path => 'run_server.sh' },
]


def makeSetup(tipo)
	puts " "
	puts " "
	puts " "
	if @clientes.any? { |item| [tipo].include? item }
		puts "--------" * 10
		puts "         " * 4 + "#{@tipo_selected}"
		puts "--------" * 10
		puts " "

		@files.each do | obj_file |
			if obj_file[:tipo] == 'reemplazo'
				puts "-=-=-=-=-=-=- "  + "ARCHIVO CON REEMPLAZO"
				remplace_files(tipo, obj_file)
			else
				puts "-=-=-=-=-=-=- "  + "ARCHIVO A MOVER"
				move_files(tipo, obj_file)
			end

			puts " "
		end

		File.write('config_setup/actual_cliente.txt', tipo)
	else
		puts "********************************************"
		puts "**                                        **"
		puts "**          CLIENTE NO EXISTE             **"
		puts "**                                        **"
		puts "********************************************"
		return 0
	end
end

# ============= REEMPLAZO =============
def remplace_files(tipo, obj_file)
	file_data = File.read("config_setup/#{obj_file[:file_name]}")

	@setup_[tipo.to_sym].each_key do | key |
		remplace_string = @setup_[tipo.to_sym][key]

		remplace_string += @environment_selected if key.to_s.include? "ENVIRONMENT_"

		file_data.gsub!("$$#{key}$$", remplace_string)
	end

	File.write(obj_file[:path], file_data)
	puts " "
	puts "ARCHIVO: #{obj_file[:file_name]} reemplado."
end

# ============= MOVER =============
def move_files(tipo, obj_file)
	file_data = File.read("config_setup/#{obj_file[:file_name]}_#{tipo}.#{obj_file[:extension]}")

	File.write(obj_file[:path], file_data)
	puts " "
	puts "ARCHIVO: #{obj_file[:file_name]} movido."
end



makeSetup(@tipo_selected)
return 1