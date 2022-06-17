# ruby ./setup.rb brendy

@clientes      = ['brendy', 'agrodemi']
@tipo_selected = ARGV[0]
@setup_         = {
	:brendy => {
		:DATABASE_NAME => "panaderia_brendy",
		:NAME_IMG_DEV  => "brendy-dev",
		:NAME_IMG_PROD => "brendy-prod",
		# :DB_PATH       => "db-brendy-data",
		:DB_PATH       => "db-data",
		:DB_PORT       => "3001",
	},
	:agrodemi => {
		:DATABASE_NAME => "ADM",
		:NAME_IMG_DEV  => "agrodemi-dev",
		:NAME_IMG_PROD => "agrodemi-prod",
		:DB_PATH       => "db-agrodemi-data",
		:DB_PORT       => "3000",
	}
}

@files         = [
	{ :tipo => 'move',       :file_name => 'google_api_credentials',  :extension => 'json', :path => 'config/google_api_credentials.json' },
	{ :tipo => 'move',       :file_name => 'schedule',                :extension => 'rb',   :path => 'config/schedule.rb' },
	{ :tipo => 'move',       :file_name => 'seedConstantes',          :extension => 'rb',   :path => 'config/initializers/global/seedConstantes.rb' },
	{ :tipo => 'move',       :file_name => 'server_db',               :extension => 'rake', :path => 'lib/tasks/server_db.rake' },

	{ :tipo => 'reemplazo',  :file_name => 'docker-compose.prod.yml',                       :path => 'docker-compose.prod.yml' },
	{ :tipo => 'reemplazo',  :file_name => 'docker-compose.yml',                            :path => 'docker-compose.yml' },
	{ :tipo => 'reemplazo',  :file_name => 'Dockerfile',                                    :path => 'Dockerfile' },
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
		file_data.gsub!("$$#{key}$$", @setup_[tipo.to_sym][key])
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