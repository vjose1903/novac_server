require 'base64'
require "zlib"
require 'openssl'
require 'json'

class Response
  def initialize(params=nil, status_=HTTP_STATUS_CODE[:ok], data=nil,  msg_=[], parametros_opcionales=nil, models_includes=nil)
    status_ ||= HTTP_STATUS_CODE[:ok]
    @paginate_class = Paginator.new(params)

    @res = {status:status_, data: data,  msg: msg_}
    set_data(data, parametros_opcionales, models_includes) if data && (parametros_opcionales || models_includes)
  end

  def set_status(status)
    @res[:status]            = status
  end

  def status_valid
    @res[:status]            == HTTP_STATUS.ok
  end

  def set_data(data, parametros_opcionales=nil, models_includes=nil)
    @paginate_class.paginate_data(data, models_includes)

    datos                    = parametros_opcionales.nil? ? @paginate_class.get_data() : serialize_response_data(@paginate_class.get_data(), parametros_opcionales)
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

  def set_summary(summary, total_registros=nil)
    @res[:summary] = summary
    @res[:total_registros] = total_registros unless total_registros.nil?
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

  def manage_error_transaction(entity, http_status=HTTP_STATUS.conflict)
    if !entity.errors.empty? || !self.status_valid
      self.set_status(http_status)
      self.add_msgs(entity.errors.to_a)

      transaction_rollback
    end
  end

  def send_response(controller)
    controller.render body: @res.except(:status).to_json, status: @res[:status], content_type: 'application/json'
  end

  private

  def serialize_response_data(data, parametros_opcionales)
    serializer = fast_serializer_for(data)
    return serialize_parser(data, parametros_opcionales) unless serializer

    if collection_data?(data)
      serializer.collection_to_hash(data, parametros_opcionales)
    else
      serializer.to_hash(data, parametros_opcionales)
    end
  end

  def fast_serializer_for(data)
    model_class = serialized_model_class(data)
    return nil unless model_class

    serializer = "#{model_class.name}Serializer".safe_constantize
    return nil unless serializer
    return serializer if serializer.respond_to?(:to_hash) && serializer.respond_to?(:collection_to_hash)

    nil
  end

  def serialized_model_class(data)
    return data.klass if defined?(ActiveRecord::Relation) && data.is_a?(ActiveRecord::Relation)
    return data.class if defined?(ActiveRecord::Base) && data.is_a?(ActiveRecord::Base)
    return data.first.class if data.is_a?(Array) && data.first && defined?(ActiveRecord::Base) && data.first.is_a?(ActiveRecord::Base)

    nil
  end

  def collection_data?(data)
    (defined?(ActiveRecord::Relation) && data.is_a?(ActiveRecord::Relation)) || data.is_a?(Array)
  end
end


class Paginator
  def initialize(params)
    @paginate_options  = { page: nil, per_page:  nil, paginado:  false }.with_indifferent_access
    @data_paginated    = { data: nil, total_registros: nil, total_paginas: nil }.with_indifferent_access

    set_pagination_options(params)
  end

  def set_pagination_options(params)
    @paginate_options["page"]     = params['page']       if params && !params['page'].nil?
    @paginate_options["per_page"] = params['per_page']   if params && !params['per_page'].nil?
    @paginate_options["paginado"] = params['paginado'].to_s.to_boolean if params && !params['paginado'].nil?
  end


  def paginate_data(data, models_includes=nil)
    @is_paginated = @paginate_options[:paginado] && collection_data?(data)

    # Aplica includes/preload incluso cuando no hay paginación para evitar N+1
    if models_includes

      if data.respond_to?(:includes)
        data = data.includes(models_includes)
      elsif data.is_a?(Array) && !@is_paginated && !data.empty? && data.first.is_a?(ActiveRecord::Base)
        ActiveRecord::Associations::Preloader.new(records: data, associations: models_includes).call
      elsif defined?(ActiveRecord::Base) && data.is_a?(ActiveRecord::Base)
        ActiveRecord::Associations::Preloader.new(records: [data], associations: models_includes).call
      end
    end

    @data_paginated[:data] = data
    @data_paginated = paginate(data, models_includes) if @is_paginated

  end

  def paginate(items, models_includes=nil)
    page      = @paginate_options[:page].to_i
    per_page  = @paginate_options[:per_page].to_i


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
          base_relation.reselect(base_relation.klass.arel_table[base_relation.klass.primary_key]).distinct.count
        end
      rescue
        count_fallback = items.count
        count_fallback.is_a?(Hash) ? count_fallback.values.sum : count_fallback
      end

      # Mantener el orden original definido por el caller
      paginated_relation = items.offset(inicio).limit(per_page)
      itemsPaginated = paginated_relation.to_a

      total_pag = (total_count.to_f / per_page.to_f).ceil
      return { "data" => itemsPaginated , "total_registros" => total_count, "total_paginas" => total_pag }.with_indifferent_access
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

    return { "data" => itemsPaginated , "total_registros" => total_length, "total_paginas" => total_pag }.with_indifferent_access
  end

  def is_paginated
    !!@is_paginated
  end

  def set_page(page)
    @paginate_options[:page] = page
  end


  def data_paginated
    @data_paginated
  end

  def get_data
    @data_paginated[:data]
  end

  def get_total_registros()
    @data_paginated[:total_registros]
  end

  def get_total_paginas()
    @data_paginated[:total_paginas]
  end

  def get_page
    page = @paginate_options[:page].to_i
    page > 0 ? page : 1
  end

  def get_per_page
    per_page = @paginate_options[:per_page].to_i
    per_page > 0 ? per_page : 1
  end

  private

  def collection_data?(data)
    (defined?(ActiveRecord::Relation) && data.is_a?(ActiveRecord::Relation)) || data.is_a?(Array)
  end

end

# ---------------------------------------------------------------------------------------------------------
def set_paginate_options(params)
  return { "page" => params.obj_has?('page') ? params[:page] : 0, "per_page" => params.obj_has?('per_page') ? params[:per_page] : 0, "paginado" => params.obj_has?('paginado') ? params[:paginado].to_boolean : false }
end

# Keep the pagination contract used by controller/model filter endpoints.
def parse_pagination_params(params)
  set_paginate_options(params)
end

# ---------------------------------------------------------------------------------------------------------

def validate_optional_param(params, key)
  params.obj_has?(key) && ["true", "false"].include?(params[key])
end

# ---------------------------------------------------------------------------------------------------------

def set_entidad(modelo, params, models_includes= nil, key='id')
  if models_includes.is_a?(String) || models_includes.is_a?(Symbol)
    key = models_includes
    models_includes = nil
  end

  res      = Response.new
  where    = { "#{key}": params[key]}

  if models_includes.nil?
    entidad  = modelo.where(where)
  else
    entidad  = modelo.where(where).includes(models_includes)
  end

  unless entidad.empty?
    res.set_data(entidad.first)
  else
    res.set_status(HTTP_STATUS.not_found)
    res.add_msg(traducir(:no_existe, entidad: "modelo.#{modelo.new.model_name.element}", otro_valor:""))
  end

  return res
end

# ---------------------------------------------------------------------------------------------------------

def has_paginate_options(params)
  return params.has_key?(:page) && params.has_key?(:per_page) && params.has_key?(:paginado)
end

# ---------------------------------------------------------------------------------------------------------

def has_filter_target(params)
  return params.has_key?(:filter_target) && !params[:filter_target].nil? && params[:filter_target].strip != ''
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

  texto_traducido = texto_traducido.kind_of?(Array) ? texto_traducido : [texto_traducido]

  return texto_traducido.join(" ")
end



# ---------------------------------------------------------------------------------------------------------

def borrar_entidad(obj)
  res  = Response.new
  data = { deleted: false, disabled: false }.with_indifferent_access

  tipo       = get_typeof(obj, :estado)
  is_boolean = tipo == :boolean
  is_string  = tipo == :string


  begin
    obj.destroy
    data[:deleted] = true
  rescue => exception
    obj.estado = false         if is_boolean
    obj.estado = STATUS.delete if is_string

    unless obj.save!
      res.set_status(HTTP_STATUS.conflict)
      res.add_msg("Error borrando #{obj.model_name.element}.")
      return res
    end
    data[:disabled] = true
  end
  res.set_data(data)
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
  Base64.strict_encode64(str.to_s.encode(Encoding::UTF_8))
end

# ---------------------------------------------------------------------------------------------------------

def decrypt(str)
  decoded = Base64.strict_decode64(str.to_s).force_encoding(Encoding::UTF_8)
  raise ArgumentError, 'El texto descifrado no contiene UTF-8 válido.' unless decoded.valid_encoding?

  decoded
end


# ---------------------------------------------------------------------------------------------------------
def pretty_json(json)
  return JSON.pretty_generate(json)
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

def updateSecuencias(tipo_factura_id)
    res                         = Response.new

    secuenciaBackend            = SecuenciaFactura.find_by_tipo_factura_id(tipo_factura_id)
    actual                      = secuenciaBackend.secuencia
    secuenciaBackend.secuencia  = actual + 1

    unless secuenciaBackend.save!
      res.add_msg('Error actualizando la secuencia.')
      res.set_status(HTTP_STATUS.conflict)
    end

    return res
  end

# ---------------------------------------------------------------------------------------------------------

def crear_actualizar_dependencias(dependencias, parametros, save=false)
  dependencias.each do |dependencia|
    next unless parametros[dependencia[:key_object]].kind_of?(Array)

    validar_dependencia = dependencia[:modelo].method(:validar_e_inicializar)
    res_dependencia = if validar_dependencia.arity == 2
      validar_dependencia.call(parametros[dependencia[:key_object]], dependencia[:padre])
    else
      validar_dependencia.call(parametros[dependencia[:key_object]], dependencia[:padre], save)
    end
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

def fetch_related_object(record, prefix)
  key_type = "#{prefix}_type"
  key_id   = "#{prefix}_id"

  # Verificar que el registro contenga los campos polimórficos especificados
  unless record.respond_to?(key_type) && record.respond_to?(key_id)
    raise ArgumentError, "The record does not have the specified polymorphic association keys with prefix '#{prefix}'"
  end

  # Obtener el tipo y el ID y devolver el objeto relacionado
  record.send(key_type).constantize.find(record.send(key_id))
end

# ---------------------------------------------------------------------------------------------------------

class Object
  def obj_has?(key)
    self.has_key?(:"#{key}") && !is_empty?(self[:"#{key}"])
  end
end

# ---------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------
class Array
  def my_includes_str(str)
    return  self.any? { |item| [str].include? item }
  end

  def my_includes_obj(key, value)
    return self.any? do |item|
      item_value = if item.respond_to?(:attributes)
        item.attributes[key.to_s]
      elsif item.respond_to?(:key?) && item.key?(key)
        item[key]
      elsif item.respond_to?(:key?) && item.key?(key.to_s)
        item[key.to_s]
      elsif item.respond_to?(:key?) && item.key?(key.to_sym)
        item[key.to_sym]
      end

      item_value.to_s == value.to_s
    end
  end

  def get_order
    return "" if self.empty?

    ids = self.map do |item|
      if item.respond_to?(:id)
        item.id
      elsif item.respond_to?(:key?) && item.key?(:id)
        item[:id]
      elsif item.respond_to?(:key?) && item.key?('id')
        item['id']
      end
    end
    return "" if ids.any?(&:nil?)

    is_ascending = ids.each_cons(2).all? { |left, right| left <= right }
    is_desending = ids.each_cons(2).all? { |left, right| left >= right }

    return is_ascending ? 'ASC' : is_desending ? 'DESC' : ''

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

def system_has_contabilidad
  return Thread.current[:has_contabilidad]
end

def transaction_rollback
  raise ActiveRecord::Rollback
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
