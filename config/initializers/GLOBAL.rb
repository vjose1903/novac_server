require 'net/smtp'

# ---------------------------------------------------------------------------------------------------------
def sendEmail( msg, asunto="Error realizando una tarea")
	email     = "vjposystem@gmail.com"
	password  = "Vasquez1903"
	listEmail = [
		email, "vjose1903@outlook.es"
	]

	style = 'style="font-weight: normal;"'

message = <<MESSAGE_END
From: VJpos<#{email}>
To: <#{listEmail}>
Content-type: text/html
Subject: #{asunto}

<h3><span #{style}>#{msg}</span></h3>

MESSAGE_END

	smtp = Net::SMTP.new 'smtp.gmail.com', 587
	smtp.enable_starttls
	smtp.start('gmail.com', email, password, :login) do
		smtp.send_message(message, email, listEmail)
	end

end
# ---------------------------------------------------------------------------------------------------------
def my_query(query)
  return ActiveRecord::Base.connection.exec_query(query)
end

# ---------------------------------------------------------------------------------------------------------

class Numeric
  def is_number?
    true if Float(self) rescue false
  end
end

class String
  def is_number?
    true if Float(self) rescue false
  end

  def to_boolean
    ActiveRecord::Type::Boolean.new.cast(self)
  end
end

# ---------------------------------------------------------------------------------------------------------
def calculateDateUTC(dateTime)
  return "#{dateTime.getlocal.strftime("%Y-%m-%d")} #{dateTime.getlocal.strftime("%H:%M:%S")}"
end

def pruebaArchivo()
	archivo = "#{PROJECT_PATH}prueba.rb"

	text = File.read(archivo)

	puts "esta el patron en el archivo ===>".yellow + "#{text.include? "aqui esta el patron buscado"}"

	# pattern_field = /field/
	# last_ocurrence_index = text.rindex(pattern_field)

	# texto_cortado = text[last_ocurrence_index, text.length]
	# puts "texto_cortado ".green + "#{texto_cortado}"
	# pattern_salto = /\n/
	# salto_de_linea = texto_cortado.index(pattern_salto)

	# escribir_en = last_ocurrence_index + salto_de_linea + 1
	# text[escribir_en] = "		## =============================
	# # BELONGS_TO
	# ## =============================
	# field :pantalla, Types::PantallaType, null: false
	# field :sector_area, Types::SectorAreaType, null: false"

	# puts "salto_de_linea ".green + "#{salto_de_linea}"

	# File.open(archivo, "w") {|file| file.puts text }

	puts "#{text}".red

end

# ---------------------------------------------------------------------------------------------------------
def parsearHora(dateTime, lUtc = true)
  # hora = Time.parse(DateTime.parse("#{Time.now.strftime("%Y-%m-%d")} #{hour.to_time}").to_s)
  hora = Time.parse(DateTime.parse("#{dateTime}").to_s)
  hora = hora.utc if lUtc
  hora = hora.getlocal if !lUtc

  return hora
end

# ---------------------------------------------------------------------------------------------------------

class Array
  def my_paginate(page, per_page)
    items = self
    page = page.to_i
    per_page = per_page.to_i

    inicio = (1 - page).abs * per_page

    itemsPaginated = items[inicio , per_page]

    total_pag = (items.length.to_f / per_page.to_f).ceil
    return { "data" => itemsPaginated, "total_registros" => items.length, "total_paginas" => total_pag }
    # return { :data =>  itemsPaginated, :total_registros =>  items.length, :total_paginas => total_pag }
  end
end

# ---------------------------------------------------------------------------------------------------------
def hora_12(fecha)
  hora =("%02d" % (((DateTime.parse(fecha).hour + 11) % 12) + 1))
  minuto =("%02d" % DateTime.parse(fecha).minute)
  return "#{hora}:#{minuto}"
end

# ---------------------------------------------------------------------------------------------------------
def formatearFecha(fecha, tipo)
  fecha_   = ''
  if tipo == TipoFecha.sin_hora
    fecha_ = Date.parse(fecha).strftime("%d/%m/%Y")
  else
    fecha_ = "#{Date.parse(fecha).strftime("%d/%m/%Y")} - #{hora_12(fecha)}"
  end
  return fecha_
end

# ---------------------------------------------------------------------------------------------------------
def comparar_fecha(fecha1, fecha2, operador)
  f1 = Date.parse(fecha1).strftime("%F")
  f2 = Date.parse(fecha2).strftime("%F")
  res = eval("'#{f1}' #{operador} '#{f2}'")
  return res
end


# ---------------------------------------------------------------------------------------------------------
def my_print_log(*args)
  is_show = ENV.fetch("RAILS_SHOW_LOG") { false }
  # Rails.logger.info "  ->> (#{caller_locations.first})".black.on_light_black
  Rails.logger.info "                      ".black.on_light_black
	args.each do |arg|
		Rails.logger.info arg
	end

  if ActiveRecord::Type::Boolean.new.cast(is_show)
  end
end
