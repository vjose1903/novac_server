require 'net/smtp'
require "zlib"
require 'openssl'

class Response
  def initialize(params=nil, status_=HTTP_STATUS_CODE[:ok], data=nil,  msg_=[], parametros_opcionales=nil)
    @paginate_class = Paginator.new(params)

    @res = {status:status_, data: data,  msg: msg_}
    set_data(data, parametros_opcionales) if data && parametros_opcionales
  end

  def set_status(status)
    @res[:status] = status
  end

  def status_valid
    @res[:status] == HTTP_STATUS_CODE[:ok]
  end

  def set_data(data, parametros_opcionales=nil, models_includes=nil)

    @paginate_class.paginate_data(data, models_includes)

    datos                    = parametros_opcionales.nil? ? @paginate_class.get_data() : serialize_parser(@paginate_class.get_data(), parametros_opcionales)
    @res[:data]              = datos
    @res[:total_registros]   = @paginate_class.get_total_registros()  if @paginate_class.is_paginated()
    @res[:total_paginas]     = @paginate_class.get_total_paginas()    if @paginate_class.is_paginated()

  end

  def has_data
    !@res[:data].nil?
  end

  def get_data
    @res[:data]
  end

  def add_msg(msg)
    @res[:msg].push(msg) if msg.length > 0
  end

  def add_msgs(msgs)
    msgs.each do |msg|
      @res[:msg].push(msg) if msg.length > 0
    end
  end

  def get_msgs
    @res[:msg]
  end

  def send_response(controller)
    controller.render json: @res.except(:status) , status: @res[:status]
  end
end


class Paginator
  def initialize(params)
    @paginate_options  = {"page" => nil, "per_page" =>  nil, "paginado" =>  false }
    @data_paginated    ={"data" => nil, "total_registros" => nil, "total_paginas" => nil }
    set_pagination_options(params)
  end

  def set_pagination_options(params)
    @paginate_options["page"]     = params['page']       if params && !params['page'].nil?
    @paginate_options["per_page"] = params['per_page']   if params && !params['per_page'].nil?
    @paginate_options["paginado"] = params['paginado']   if params && !params['paginado'].nil?
  end


  def paginate_data(data, models_includes=nil)
    @data_paginated["data"] = data
    @data_paginated         = paginate(data, models_includes) if @paginate_options["paginado"]
  end

  def paginate(items, models_includes=nil)
    page      = @paginate_options["page"].to_i
    per_page  = @paginate_options["per_page"].to_i


    inicio    = (page - 1).abs * per_page

    itemsPaginated = items[inicio, per_page]

    total_pag = (items.length.to_f / per_page.to_f).ceil

    return { "data" => models_includes.nil? ? itemsPaginated : itemsPaginated.to_activerecord_relation.includes(models_includes) , "total_registros" => items.length, "total_paginas" => total_pag }
  end

  def is_paginated
    @paginate_options['paginado']
  end

  def set_page(page)
    @paginate_options['page'] = page
  end


  def data_paginated
    @data_paginated
  end

  def get_data
    @data_paginated["data"]
  end

  def get_total_registros()
    @data_paginated["total_registros"]
  end

  def get_total_paginas()
    @data_paginated["total_paginas"]
  end

  def get_page
    @paginate_options['page']
  end

  def get_per_page
    puts " @paginate_options ==> " + " #{@paginate_options.to_json}"
    @paginate_options['per_page']
  end

end

# ---------------------------------------------------------------------------------------------------------
def set_paginate_options(params)
  pde = {"page" => params['page']|| 0, "per_page" => params['per_page'] || 0, "paginado" => params['paginado'].to_boolean || false}
  return pde
end
# ---------------------------------------------------------------------------------------------------------
def validate_optional_param(params, key)
  params.obj_has?(key) && ["true", "false"].include?(params[key])
end
# ---------------------------------------------------------------------------------------------------------

def serialize_parser(modelo, params={})
  ActiveModelSerializers::SerializableResource.new(modelo, params)
end
# ---------------------------------------------------------------------------------------------------------

def set_entidad(modelo, params, key="id")
  res = Response.new
  where = { "#{key}": params[key]}
  entidad = modelo.where(where)

  unless entidad.length == 0
    res.set_data(entidad.first)
  else
    res.set_status(HTTP_STATUS_CODE[:not_found])
    res.add_msg(traducir(:no_existe, entidad: "modelo.#{modelo.new.model_name.element}", otro_valor:""))
  end

  return res
end

# ---------------------------------------------------------------------------------------------------------

def traducir(key, others=nil)
  others_tem = {}
  unless others.nil?
    others.keys.each do |key_|
      others_tem[key_] = (:valor == key_ or :otro_valor == key_) ? others[key_] : I18n.t(others[key_])
    end

    texto_traducido = I18n.t(key, **others_tem)
  else
    texto_traducido = I18n.t(key)
  end

  texto_traducido = texto_traducido.kind_of?(Array)? texto_traducido : [texto_traducido]

  return texto_traducido.join(" ")
end
# ---------------------------------------------------------------------------------------------------------
def borrar_entidad(obj)
  res = Response.new

  begin
    obj.destroy
  rescue => exception
    obj.estado = false
    unless obj.save!
      res.set_status(HTTP_STATUS_CODE[:conflict])
      res.add_msg("Error borrando #{obj.model_name.element}.")
      return res
    end
  end
  res.add_msg(traducir(:borrar_un, entidad: "modelo.#{obj.model_name.element}"))
  return res
end

# ---------------------------------------------------------------------------------------------------------


def encrypt(str)
  cipher_salt1 = '013213810'
  cipher_salt2 = '013213810'
  cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt
  cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(cipher_salt1, cipher_salt2, 20_000, cipher.key_len)
  encrypted = cipher.update(str) + cipher.final
  encrypted.unpack('H*')[0].upcase
end
# ---------------------------------------------------------------------------------------------------------

def decrypt(str)
  cipher_salt1 = 'some-random-salt-'
  cipher_salt2 = 'another-random-salt-'
  cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').decrypt
  cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(cipher_salt1, cipher_salt2, 20_000, cipher.key_len)
  decrypted = [encrypted_str].pack('H*').unpack('C*').pack('c*')

  cipher.update(decrypted) + cipher.final
end

# ---------------------------------------------------------------------------------------------------------

def round_to_nearest_multiple_of_5(number)
  (number / 5.0).ceil * 5
end

# ---------------------------------------------------------------------------------------------------------

def encriptarBase64(value)
  valor_encrip = Base64.encode64(value)
  return valor_encrip
end

# ---------------------------------------------------------------------------------------------------------
def desencriptarBase64(enc)
  valor_des = Base64.decode64(enc)
  return valor_des
end


# ---------------------------------------------------------------------------------------------------------

def encriptarZlib(data_to_compress)
  data_compressed = Zlib::Deflate.deflate(data_to_compress)
  return data_compressed
end

# ---------------------------------------------------------------------------------------------------------

def desencriptarZlib(data_compressed)
  uncompressed_data = Zlib::Inflate.inflate(data_compressed)
  return uncompressed_data
end

# ---------------------------------------------------------------------------------------------------------

def dobleEncriptar(data_to_compress)
  data_compressed            = encriptarZlib(data_to_compress)
  data_doble_compressed      = encriptarBase64(data_compressed)
  return data_doble_compressed
end

# ---------------------------------------------------------------------------------------------------------

def dobleDesEncriptar(data_to_compress)
  data_doble_compressed      = desencriptarBase64(data_compressed)
  data_uncompressed          = desencriptarZlib(data_doble_compressed)
  return data_uncompressed
end
# ---------------------------------------------------------------------------------------------------------
def updateSecuencias(tipo_secuencia_id)
    res                         = Response.new

    secuenciaBackend            = SecuenciaFactura.find_by_id(tipo_secuencia_id)
    actual                      = secuenciaBackend.secuencia
    secuenciaBackend.secuencia  = actual + 1

    unless secuenciaBackend.save!
      res.add_msg("Error actualizando la secuencia.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
# ---------------------------------------------------------------------------------------------------------

def crear_actualizar_dependencias(dependencias, parametros, save)
  dependencias.each do |dependencia|

    if !parametros[dependencia[:key_object]].nil? && parametros[dependencia[:key_object]].kind_of?(Array)
      res_dependencia = dependencia[:modelo].validar_e_inicializar(parametros[dependencia[:key_object]], dependencia[:padre], save)
      if res_dependencia.status_valid
        yield dependencia[:key_object], res_dependencia.get_data if block_given?
      else
        return res_dependencia
      end
    end
  end
  return Response.new
end

# ---------------------------------------------------------------------------------------------------------
def isEmpty?(parametro)
  # Verifica si el parámetro es nil, un arreglo vacío, una cadena vacía o un hash vacío
  # Pero devuelve false si el parámetro es un valor booleano
  return false  if parametro.is_a?(TrueClass) || parametro.is_a?(FalseClass)
  (parametro.nil? || (parametro.is_a?(String) && parametro.strip.empty?) || (parametro.is_a?(Hash) && parametro.empty?) || ( ( parametro.is_a?(Hash) || parametro.is_a?(Array) ) && parametro.empty?)  )
end
# ---------------------------------------------------------------------------------------------------------
class Object
  def obj_has?(key)
    self.has_key?(:"#{key}") && !isEmpty?(self[:"#{key}"])
  end
end

# ---------------------------------------------------------------------------------------------------------
class Array
  def my_includes_str(str)
    return  self.any? { |i| [str].include? i }
  end

  def my_includes_obj(key, value)
    return  self.any? { |item| item[key] == value }
  end

  def get_order
    return "" if self.empty? || self[0]["id"].nil?

    is_ascending = self.each_cons(2).all?{|left, right| left["id"] <= right["id"]}
    is_desending = self.each_cons(2).all?{|left, right| left["id"] >= right["id"]}

    return is_ascending ? "ASC" : is_desending ? "DESC" : ""

  end

  def to_activerecord_relation
    return ApplicationRecord.none if self.empty?

    clazzes = self.map(&:class).uniq
    raise 'Array cannot be converted to ActiveRecord::Relation since it does not have same elements' if clazzes.size > 1

    clazz = clazzes.first
    raise 'Element class is not ApplicationRecord and as such cannot be converted' unless clazz.ancestors.include? ApplicationRecord

    clazz.where(id: self.map(&:id)).order(self.get_order.blank? ? "" : "id #{self.get_order}")
  end
end

# ---------------------------------------------------------------------------------------------------------

def roundNumberToDecimal(num)

	num = num.to_s
	num_split = num.split(".")
	decimales = num_split.length > 1 ? num_split.last : nil

	if decimales.nil? || decimales.length == 1
		num = "#{("%.2f" % num)}"
	elsif decimales.length > 2
		num = num.to_f.round(2).to_s
	end

	return "#{num.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
end

# ---------------------------------------------------------------------------------------------------------
def get_current_user
  return Thread.current[:current_user]
end
