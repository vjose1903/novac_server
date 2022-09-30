# ruby ./setup.rb brendy

@clientes             = ['brendy', 'agrodemi', 'vasquez']
@cliente_selected        = ARGV[0]
@environment_selected = ARGV[1]

@setup_               = {
	:agrodemi => {
		:ALMACEN                => "ADM",
		:ALMACEN_MAIL           => "novacagrodemi@gmail.com",
		:ENVIRONMENT_NAME_IMG   => "agrodemi-",
		:DB_PATH                => "db-agrodemi-data",
		:DB_PORT                => "3000",
		:CORS_PORT              => "5220",
		:FRONT_PORT             => "9090",
		:NGINX_SERVER_NAME      => "localhost admservidor.ddns.net *.admservidor.ddns.net"
	},
	:brendy => {
		:ALMACEN                => "panaderia_brendy",
		:ALMACEN_MAIL           => "novacbrendy@gmail.com",
		:ENVIRONMENT_NAME_IMG   => "brendy-",
		:DB_PATH                => "db-brendy-data",
		:DB_PORT                => "3001",
		:CORS_PORT              => "5221",
		:FRONT_PORT             => "9091",
		:NGINX_SERVER_NAME      => "localhost novac-brendy.ddns.net *.novac-brendy.ddns.net"
	},
	:vasquez => {
		:ALMACEN                => "vasquez_services",
		:ALMACEN_MAIL           => "novacvasquez@gmail.com",
		:ENVIRONMENT_NAME_IMG   => "vasquez-",
		:DB_PATH                => "db-vasquez-data",
		:DB_PORT                => "3002",
		:CORS_PORT              => "5222",
		:FRONT_PORT             => "9092",
		:NGINX_SERVER_NAME      => "localhost novac-vasquez.ddns.net *.novac-vasquez.ddns.net"
	},
}

@files         = [
	{ :tipo => 'move',       :file_name => 'google_api_credentials',  :extension => 'json', :path => 'config/google_api_credentials.json' },
	{ :tipo => 'move',       :file_name => 'seedConstantes',          :extension => 'rb',   :path => 'config/initializers/global/seedConstantes.rb' },
	# { :tipo => 'move',       :file_name => 'server_db',               :extension => 'rake', :path => 'lib/tasks/server_db.rake' },

	{ :tipo => 'reemplazo',  :file_name => 'docker-compose.prod.yml',                       :path => 'docker-compose.prod.yml' },
	{ :tipo => 'reemplazo',  :file_name => 'docker-compose.yml',                            :path => 'docker-compose.yml' },
	{ :tipo => 'reemplazo',  :file_name => 'Dockerfile',                                    :path => 'docker/services/server/Dockerfile' },
	{ :tipo => 'reemplazo',  :file_name => 'default.conf',                                  :path => 'docker/services/nginx/default.conf' },
	{ :tipo => 'reemplazo',  :file_name => 'run_server.sh',                                 :path => 'run_server.sh' },
	{ :tipo => 'reemplazo',  :file_name => 'cors.rb',                                       :path => 'config/initializers/cors.rb' },
	{ :tipo => 'reemplazo',  :file_name => 'server_db.rake',                                :path => 'lib/tasks/server_db.rake' },
]


def makeSetup(cliente)
	puts " "
	puts " "
	puts " "
	if @clientes.any? { |item| [cliente].include? item }
		puts "--------" * 10
		puts "         " * 4 + "#{@cliente_selected}"
		puts "--------" * 10
		puts " "

		@files.each do | obj_file |
			if obj_file[:tipo] == 'reemplazo'
				puts "-=-=-=-=-=-=- "  + "ARCHIVO CON REEMPLAZO"
				remplace_files(cliente, obj_file)
			else
				puts "-=-=-=-=-=-=- "  + "ARCHIVO A MOVER"
				move_files(cliente, obj_file)
			end

			puts " "
		end

		File.write('config_setup/actual_cliente.txt', cliente)
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
def remplace_files(cliente, obj_file)
	file_data = File.read("config_setup/#{obj_file[:file_name]}")

	@setup_[cliente.to_sym].each_key do | key |
		remplace_string = @setup_[cliente.to_sym][key]

		remplace_string += @environment_selected if key.to_s.include? "ENVIRONMENT_"

		file_data.gsub!("$$#{key}$$", remplace_string)
	end

	File.write(obj_file[:path], file_data)
	puts " "
	puts "ARCHIVO: #{obj_file[:file_name]} reemplado."
end

# ============= MOVER =============
def move_files(cliente, obj_file)
	file_data = File.read("config_setup/#{obj_file[:file_name]}_#{cliente}.#{obj_file[:extension]}")

	File.write(obj_file[:path], file_data)
	puts " "
	puts "ARCHIVO: #{obj_file[:file_name]} movido."
end



makeSetup(@cliente_selected)
return 1