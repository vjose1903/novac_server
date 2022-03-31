class OtroCostoMantenimientoArticulo < ApplicationRecord
  belongs_to :otro_costo_historial
  belongs_to :mantenimiento_articulo


	def self.crear_otro_costo_mantenimiento(otro_costo, historico_articulo)
    res = Response.new

		OtroCostoMantenimientoArticulo.transaction do
			unless params["id"]
				otro_costo_mantenimiento_articulo                            = OtroCostoMantenimientoArticulo.new
			else
				otro_costo_mantenimiento_articulo                            = OtroCostoMantenimientoArticulo.find_by_id(params["id"])
			end

			last_otro_costo_historial = OtroCostoHistorial.where({otro_costo_id: otro_costo.id}).limit(1).order("id DESC").first

			otro_costo_mantenimiento_articulo.otro_costo_historial_id      = last_otro_costo_historial.id
			otro_costo_mantenimiento_articulo.mantenimiento_articulo_id    = historial_articulo.id

			otro_costo_mantenimiento_articulo.valid?

			if otro_costo_mantenimiento_articulo.errors.empty? && (!is_save || (is_save && otro_costo_mantenimiento_articulo.save!))

				res.set_data(otro_costo_mantenimiento_articulo)
			else
				res.add_msgs(otro_costo_mantenimiento_articulo.errors.to_a)
				res.set_status(HTTP_STATUS_CODE[:conflict])
			end
		end
    return res
  end

	def self.add_historico(historico, otros_costos)
    res_valid      = Response.new
    array_valid    = []

    otros_costos.to_a.each do |item|
      res_temp     = self.crear_otro_costo_mantenimiento(item, historico)

      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp
      end
    end

    res_valid.set_data array_valid
    return res_valid
  end

end
