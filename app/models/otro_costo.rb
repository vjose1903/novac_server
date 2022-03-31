class OtroCosto < ApplicationRecord

	def self.crear_actualizar_otro_costo(params, anterior_otro_costo, is_save=false)
    res = Response.new

		OtroCosto.transaction do
			ant_otro_costo           =  anterior_otro_costo.nil? ? nil : anterior_otro_costo

			unless params["id"]
				otro_costo             = OtroCosto.new
			else
				otro_costo             = OtroCosto.find_by_id(params["id"])
			end

			otro_costo.descripcion   = params["descripcion"]
			otro_costo.costo         = params["costo"]

			otro_costo.valid?

			if otro_costo.errors.empty? && (!is_save || (is_save && otro_costo.save!))

				ant_otro_costo         = otro_costo if ant_otro_costo.nil?

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

end
