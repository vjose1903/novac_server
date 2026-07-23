require 'net/smtp'
require "zlib"
require 'openssl'

class Response
  def initialize(params=nil, status_=HTTP_STATUS_CODE[:ok], data=nil,  msg_=[], parametros_opcionales=nil, models_includes=nil)
    @paginate_class = Paginator.new(params)

    @res = {status:status_, data: data,  msg: msg_}
    set_data(data, parametros_opcionales, models_includes) if data && (parametros_opcionales || models_includes)
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

  def get_status
    @res[:status]
  end

  def set_pagination_metadata(total_registros, total_paginas)
    @res[:total_registros] = total_registros
    @res[:total_paginas] = total_paginas
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

    # Aplica includes/preload incluso cuando no hay paginación para evitar N+1
    if models_includes

      if data.respond_to?(:includes)
        data = data.includes(models_includes)
      elsif data.is_a?(Array) && !data.empty? && data.first.is_a?(ActiveRecord::Base)
        ActiveRecord::Associations::Preloader.new(records: data, associations: models_includes).call
      elsif defined?(ActiveRecord::Base) && data.is_a?(ActiveRecord::Base)
        ActiveRecord::Associations::Preloader.new(records: [data], associations: models_includes).call
      end
    end

    @data_paginated["data"] = data
    @data_paginated         = paginate(data, models_includes) if @paginate_options["paginado"]

  end

  def paginate(items, models_includes=nil)
    page      = @paginate_options["page"].to_i
    per_page  = @paginate_options["per_page"].to_i


    # Asegurar que la página sea al menos 1
    page      = 1 if page <= 0
    # Evitar división por cero y paginación inválida
    per_page  = 1 if per_page <= 0
    inicio    = (page - 1) * per_page

    # Soporte para ActiveRecord::Relation usando offset/limit
    if defined?(ActiveRecord::Relation) && items.is_a?(ActiveRecord::Relation)

      # Calcular total de registros sin afectar el relation paginado ni sorting, y evitando duplicados por includes/joins
      base_relation = items.unscope(:order).limit(nil).offset(nil)

      total_count = begin
        if base_relation.group_values.present?
          # Si hay GROUP BY, contamos filas del conjunto agrupado usando subconsulta
          sql = "SELECT COUNT(*) AS count FROM (#{base_relation.to_sql}) subq"
          ActiveRecord::Base.connection.exec_query(sql).rows[0][0].to_i
        else
          # Sin GROUP BY: contar IDs distintos para evitar duplicados por joins/includes
          pk = base_relation.klass.primary_key
          base_relation.reselect(nil).distinct.count(pk)
        end
      rescue
        count_fallback = items.count
        count_fallback.is_a?(Hash) ? count_fallback.values.sum : count_fallback
      end

      # Mantener el orden original definido por el caller
      paginated_relation = items.offset(inicio).limit(per_page)
      itemsPaginated = paginated_relation.to_a

      total_pag = (total_count.to_f / per_page.to_f).ceil
      return { "data" => itemsPaginated , "total_registros" => total_count, "total_paginas" => total_pag }
    end

    # Array/Hash u otros enumerables: usar slice (Hash -> Array de pares)
    source_items = items.is_a?(Hash) ? items.to_a : items
    itemsPaginated = source_items[inicio, per_page] || []

    # Preload de asociaciones para el slice paginado si es un Array de AR
    if models_includes && itemsPaginated.is_a?(Array) && !itemsPaginated.empty? && itemsPaginated.first.is_a?(ActiveRecord::Base)
      ActiveRecord::Associations::Preloader.new(records: itemsPaginated, associations: models_includes).call
    end

    total_length = source_items.length
    total_pag = (total_length.to_f / per_page.to_f).ceil

    return { "data" => itemsPaginated , "total_registros" => total_length, "total_paginas" => total_pag }
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
    @paginate_options['per_page']
  end

end

# ---------------------------------------------------------------------------------------------------------
def set_paginate_options(params)
  return { "page" => params.obj_has?('page') ? params[:page] : 0, "per_page" => params.obj_has?('per_page') ? params[:per_page] : 0, "paginado" => params.obj_has?('paginado') ? params[:paginado].to_boolean : false }
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

def format_rnc(rnc)
  return rnc unless rnc

  # Asegurarnos que el RNC sea tratado como string
  rnc = rnc.to_s

  # Extraer los primeros 3 dígitos
  first_part = rnc[0..2]

  # Extraer los dígitos del medio (todos menos los 3 primeros y el último)
  middle_part = rnc[3..-2]

  # Extraer el último dígito
  last_part = rnc[-1]

  # Formato: XXX-XXXXX-X
  "#{first_part}-#{middle_part}-#{last_part}"
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
    next unless parametros[dependencia[:key_object]].kind_of?(Array)

    res_dependencia = dependencia[:modelo].validar_e_inicializar(parametros[dependencia[:key_object]], dependencia[:padre], save)
    return res_dependencia unless res_dependencia.status_valid

    yield dependencia[:key_object], res_dependencia.get_data if block_given?
  end
  return Response.new
end

def is_empty?(parametro)
	# Verifica si el parámetro es nil, un arreglo vacío, una cadena vacía o un hash vacío
	# Pero devuelve false si el parámetro es un valor booleano
	return false if parametro.is_a?(TrueClass) || parametro.is_a?(FalseClass)

	(parametro.nil? || (parametro.is_a?(String) && parametro.strip.empty?) || (parametro.is_a?(Hash) && parametro.empty?) || ( ( parametro.is_a?(Hash) || parametro.is_a?(Array) ) && parametro.empty?)  )
end

# ---------------------------------------------------------------------------------------------------------

def is_boolean?(param)
	param.is_a?(TrueClass) || param.is_a?(FalseClass)
end

# ---------------------------------------------------------------------------------------------------------


class String
	def is_number?
		!!(self =~ /\A\d+\z/)
	end
end
# ---------------------------------------------------------------------------------------------------------


class Object
	def obj_has?(key)
		self.has_key?(:"#{key}") && !is_empty?(self[:"#{key}"])
	end
end

# ---------------------------------------------------------------------------------------------------------
class Array
  def my_includes_str(str)
    return  self.any? { |item| [str].include? item }
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

    # Optimización: usar first en lugar de map + uniq para obtener la clase
    first_class = self.first.class

    # Verificar que todos los elementos sean de la misma clase de manera más eficiente
    unless self.all? { |item| item.class == first_class }
      raise 'Array cannot be converted to ActiveRecord::Relation since it does not have same elements'
    end

    # Verificar que sea una subclase de ApplicationRecord
    unless first_class.ancestors.include?(ApplicationRecord)
      raise 'Element class is not ApplicationRecord and as such cannot be converted'
    end

    # Optimización: extraer IDs una sola vez y cachear el orden
    ids = self.map(&:id)
    order_clause = self.get_order
    order_sql = order_clause.blank? ? "" : "id #{order_clause}"

    first_class.where(id: ids).order(order_sql)
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

def calculateDateUTC(date)
  # Cache por thread para evitar problemas de concurrencia
  Thread.current[:date_cache] ||= {}

  date_key = date.to_s
  return Thread.current[:date_cache][date_key] if Thread.current[:date_cache].key?(date_key)

  result = "#{date.getlocal.strftime("%Y-%m-%d")} #{date.getlocal.strftime("%H:%M:%S")}"

  Thread.current[:date_cache][date_key] = result
  result
end
