class OtroCostoArticulo < ApplicationRecord
  belongs_to :articulo
  belongs_to :otro_costo

	def self.crear_actualizar_otro_costo_articulo(params, padre, is_save=false)
    res = Response.new

		OtroCostoArticulo.transaction do

			unless params["id"]
				otro_costo_articulo                    = OtroCostoArticulo.new
			else
				otro_costo_articulo                    = OtroCostoArticulo.find_by_id(params["id"])
			end

			otro_costo_articulo.otro_costo_id        = params["otro_costo_id"]

			otro_costo_articulo.valid?

			otro_costo_articulo.errors.delete(:articulo) if !is_save

			if otro_costo_articulo.errors.empty? && (!is_save || (is_save && otro_costo_articulo.save!))
				res.set_data(otro_costo_articulo)
			else
				res.add_msgs(otro_costo_articulo.errors.to_a)
				res.set_status(HTTP_STATUS_CODE[:conflict])
			end

		end

		return res
  end

  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_actualizar_otro_costo_articulo(item, padre, !item[:id].nil?)

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
