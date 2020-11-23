
def desencriptarBase64(enc)
  valor_des = Base64.decode64(enc)
  return valor_des
end

def my_query(query)
  return ActiveRecord::Base.connection.exec_query(query)
end

class String
  def numeric?
    return true if self =~ /\A\d+\Z/
    true if Float(self) rescue false
  end

  def to_boolean
    ActiveRecord::Type::Boolean.new.cast(self)
  end
end

def parsearDateTimeUTC(dateTime)
  return dateTime.getlocal.strftime("%Y-%m-%d") + " " + dateTime.getlocal.strftime("%H:%M:%S")
end

def parsearHora(dateTime, lUtc = true)
  # hora = Time.parse(DateTime.parse("#{Time.now.strftime("%Y-%m-%d")} #{hour.to_time}").to_s)
  hora = Time.parse(DateTime.parse("#{dateTime}").to_s)
  hora = hora.utc if lUtc
  hora = hora.getlocal if !lUtc

  puts "#{hora}".red
  return hora
end

class Array
  def my_paginate(page, per_page)
    itemsTem = []
    pagina = 0
    lSalir = false

    items = self

    page = page.to_i
    per_page = per_page.to_i

    index = 0
    while !lSalir and items.length > 0
      itemsTem.push items[index]
      if itemsTem.length == per_page or index == (items.length - 1)
        pagina += 1
        lSalir = pagina == page
        if !lSalir
          itemsTem = []
        end
      end
      index += 1
    end

    total_pag = (items.length.to_f / per_page.to_f).ceil

    return { data: itemsTem, total_registros: items.length, total_paginas: total_pag }
  end
end


def comparar_fecha(fecha1, fecha2, operador)
  f1 = Date.parse(fecha1).strftime("%F")
  f2 = Date.parse(fecha2).strftime("%F")
  res = eval("'#{f1}' #{operador} '#{f2}'")
  return res
end


def my_print_log(*args)
  is_show = ENV.fetch("RAILS_SHOW_LOG") { false }
  Rails.logger.info " ↳ my_print_log ->> #{is_show} ".cyan + " => (#{caller_locations.first})"
  if ActiveRecord::Type::Boolean.new.cast(is_show)
    args.each do |arg|
      Rails.logger.info arg
    end
  end
end
