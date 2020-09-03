class String
  def numeric?
    return true if self =~ /\A\d+\Z/
    true if Float(self) rescue false
  end
end

def desencriptarBase64(enc)
  valor_des = Base64.decode64(enc)
  return valor_des
end

def my_query(query)
  return ActiveRecord::Base.connection.exec_query(query)
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
