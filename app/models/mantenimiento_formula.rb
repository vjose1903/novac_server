class MantenimientoFormula < ApplicationRecord

  def self.crear_historico(parametros, secuencia)
		res                            = Response.new
    MantenimientoFormula.transaction do

      historico                    = MantenimientoFormula.new

      historico.articulo_id        = parametros["articulo_id"]
      historico.articulo_combo     = parametros["articulo_combo"]
      historico.cantidad           = parametros["cantidad"]
      historico.costo              = parametros["costo"]
      historico.precio             = parametros["precio"]
      historico.secuencia          = secuencia


      unless historico.save!
        res.add_msgs(historico.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

			raise ActiveRecord::Rollback unless res.status_valid
    end

		return res
  end

  def self.add_historico(parametros, secuencia)

    res_valid      = Response.new
    array_valid    = []

    parametros.to_a.each do |item|
      res_temp     = self.crear_historico(item, secuencia)

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
