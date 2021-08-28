require 'net/smtp'

def desencriptarBase64(enc)
  valor_des = Base64.decode64(enc)
  return valor_des
end

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
class String
  def numeric?
    return true if self =~ /\A\d+\Z/
    true if Float(self) rescue false
  end

  def to_boolean
    ActiveRecord::Type::Boolean.new.cast(self)
  end
end

# ---------------------------------------------------------------------------------------------------------
def parsearDateTimeUTC(dateTime)
  return dateTime.getlocal.strftime("%Y-%m-%d") + " " + dateTime.getlocal.strftime("%H:%M:%S")
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
    puts "items --> ".blue + "#{items.to_json}"
    page = page.to_i
    per_page = per_page.to_i
    
    inicio = (1 - page).abs * per_page
    puts "inicio --> ".blue + "#{inicio}"
    
    itemsPaginated = items[inicio , per_page]
    puts "itemsPaginated --> ".blue + "#{itemsPaginated}"
    puts "page --> ".blue + "#{page}"
    puts "per_page --> ".blue + "#{per_page}"
    
    total_pag = (items.length.to_f / per_page.to_f).ceil
    # return { "data" => itemsPaginated, "total_registros" => items.length, "total_paginas" => total_pag }
    return { :data =>  itemsPaginated, :total_registros =>  items.length, :total_paginas => total_pag }
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
  fecha_ = ''
  if tipo == 1
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
  Rails.logger.info "  ->> (#{caller_locations.first})".black.on_light_black
  if ActiveRecord::Type::Boolean.new.cast(is_show)
    args.each do |arg|
      Rails.logger.info arg
    end
  end
end
