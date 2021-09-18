require 'net/smtp'


class Response
	def initialize(status_=HTTP_STATUS_CODE[:ok], data=nil,  msg_=[], parametros_opcionales=nil, paginate_options=nil)
		@res = {status:status_, data: data,  msg: msg_}

		set_data(data, parametros_opcionales, paginate_options) if data && parametros_opcionales
	end
	
	def set_status(status)
		@res[:status] = status
	end
	
	def status_valid
		@res[:status] == HTTP_STATUS_CODE[:ok]
		
	end

	def set_data(data, parametros_opcionales=nil, paginate_options=nil)

		paginate = nil
		paginate = data.to_a.my_paginate(paginate_options['page'], paginate_options['per_page']) if paginate_options && paginate_options['paginado']
		
		data = serialize_parser(paginate ? paginate['data'] : data , parametros_opcionales) unless parametros_opcionales.nil?

		@res[:data] = data
		@res[:total_registros] = paginate['total_registros'] if paginate
		@res[:total_paginas] = paginate['total_paginas'] if paginate
	end
	
	def has_data
		!@res[:data].nil?
	end

	def get_data()
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
	
	def send_response(controller)
		controller.render json: @res.except(:status) , status: @res[:status]
	end
end

# ---------------------------------------------------------------------------------------------------------
def set_paginate_options(params)
	pde = {"page" => params['page'], "per_page" => params['per_page'], "paginado" => params['paginado']}
	return pde
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
		res.set_data(entidad[0])
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
		texto_traducido = I18n.t(key, others_tem)
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
class Array
	def my_includes(str)
		return  self.any? { |i| [str].include? i }
	end
end
