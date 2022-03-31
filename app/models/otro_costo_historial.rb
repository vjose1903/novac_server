class OtroCostoHistorial < ApplicationRecord
	belongs_to :otro_costo

	def self.add_historico(params)
    res = Response.new

		OtroCostoHistorial.transaction do

			otro_costo_historial                 = OtroCostoHistorial.new

			otro_costo_historial.descripcion       = params.descripcion
			otro_costo_historial.costo             = params.costo
			otro_costo_historial.otro_costo_id     = params.id

			otro_costo_historial.valid?

			if otro_costo_historial.errors.empty? && otro_costo_historial.save!
				res.set_data(otro_costo_historial)
			else
				res.add_msgs(otro_costo_historial.errors.to_a)
				res.set_status(HTTP_STATUS_CODE[:conflict])
			end
		end
    return res
  end

end
