class OtroCosto < ApplicationRecord

	validates :descripcion,              presence: { :message => "Descripcion del otro costo no puede estar vacio." },         uniqueness: { scope: :estado, case_sensitive: false, :message => "Otro costo ya esta registrado." }, :if => :estado

	def self.crear_actualizar_otro_costo(params, anterior_otro_costo)
    res = Response.new

		OtroCosto.transaction do
			ant_otro_costo           =  anterior_otro_costo.nil? ? nil : anterior_otro_costo
			puts "  "
			puts "ant_otro_costo ".magenta + "#{ant_otro_costo.to_json}"
			puts "  "

			unless params["id"]
				otro_costo             = OtroCosto.new
			else
				otro_costo             = OtroCosto.find_by_id(params["id"])
			end

			otro_costo.descripcion   = params["descripcion"]
			otro_costo.costo         = params["costo"]
			otro_costo.estado        = params["estado"]

			otro_costo.valid?

			if otro_costo.errors.empty? && otro_costo.save!

				ant_otro_costo         = otro_costo if ant_otro_costo.nil?
				puts "  "
				puts "ant_otro_costo ".green + "#{ant_otro_costo.to_json}"
				puts "  "

				res_proceso            = OtroCostoHistorial.add_historico(ant_otro_costo)

				if res_proceso.status_valid
					res.set_data(otro_costo)
				else
					res.add_msgs(res_proceso.errors.to_a)
					res.set_status(HTTP_STATUS_CODE[:conflict])
				end

			else
				res.add_msgs(otro_costo.errors.to_a)
				res.set_status(HTTP_STATUS_CODE[:conflict])
			end
		end
    return res
  end

	# =========================================================================================================================================================

	def self.filtrarOtroCosto(arg, params)
    res = Response.new(params)

    otros_costos = OtroCosto
    .where("lower(otros_costos.descripcion || ' ' || otros_costos.costo) like lower('%#{arg}%')  AND otros_costos.estado = true")
    .order("otros_costos.id ASC").to_a

    if otros_costos.length > 0
      res.set_data(otros_costos, {all: true})
    else
      res.set_data([])
			cantidad_registros = OtroCosto.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? "No existen datos registrados." : "No existen otros costos con las especificaciones introducidas.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
