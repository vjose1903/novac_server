# ruby ./setup.rb brendy
@tipo_selected = ARGV[0]
puts "--------" * 10
puts "         " * 4 + "#{@tipo_selected}"
puts "--------" * 10
@setup = {
	:brendy => {
		:DATABASE_NAME => "panaderia_brendy",
		:NAME_IMG_DEV => "brendy-dev",
		:NAME_IMG_PROD => "brendy-prod",
		:DB_PATH => "db-data",
	}
}

@files = {
	:to_remplace => [
		{ :file_name => 'docker-compose.prod.yml', :path => 'docker-compose.prod.yml' },
		{ :file_name => 'docker-compose.yml', :path => 'docker-compose.yml' },
	],
  :to_move => [
		{ :file_name => 'google_api_credentials', :extension => 'json', :path => 'config/google_api_credentials.json' },
		{ :file_name => 'schedule', :extension => 'rb', :path => 'config/schedule.rb' },
		{ :file_name => 'seedConstantes', :extension => 'rb', :path => 'config/initializers/global/seedConstantes.rb' },
		{ :file_name => 'server_db', :extension => 'rake', :path => 'lib/tasks/server_db.rake' },
	]
}


def makeSetup(tipo)
	@files[:to_remplace].each do | obj_file |
		remplace_files(tipo, obj_file)
	end
end

def remplace_files(tipo, obj_file)
	file_data = File.read("config_setup/#{obj_file[:file_name]}")

	@setup[tipo.to_sym].each_key do | key |
		file_data.gsub!("$$#{key}$$", @setup[tipo.to_sym][key])
	end

	File.write(obj_file[:path], file_data)

	puts "ARCHIVO: #{obj_file[:file_name]} reemplado."

end

def move_files(tipo)

end

makeSetup(@tipo_selected)

# seed_panaderia= "seedConstantes_panaderia.rb"




# fulano = {
# 	:DATABASE_NAME => "panaderia_brendy",
#   :NAME_IMG => "brendy-dev",
#   :PATH_DB => "db-data",
# }

# seed_fulano= "seedConstantes_panaderia.rb"



# if ar == pan

# cambio(panaderia, seed_panaderia)

# else
# 	cambio(fulano, seed_fulano)




# cambio(compose, seed_filename, googlepi){


# }

# str = ":dsdssds"
# panaderia.keys()
# [DATABASE_NAME,NAME_IMG]

# itm = "DATABASE_NAME"

# str.replaceAll("$$#{itm}$$", panaderia[itm])