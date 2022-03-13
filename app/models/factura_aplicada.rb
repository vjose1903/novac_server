class FacturaAplicada < ApplicationRecord
  belongs_to :nota
  belongs_to :cabecera_factura

	has_many :detalles_facturas_notas, dependent: :destroy

	def self.crear_factura_aplicada(params, padre, is_save=false)
    res = Response.new

    factura_aplicada                             = FacturaAplicada.new

    factura_aplicada.cabecera_factura_id         = params["cabecera_factura_id"]
    factura_aplicada.total                       = params["total"]

    factura_aplicada.valid?

    factura_aplicada.errors.delete(:nota) if !is_save

		dependencias                                 = [ {modelo: DetalleFacturaNota, key_object: "detalles_facturas_notas", padre: padre} ]

		res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
			factura_aplicada.detalles_facturas_notas   = dependencia_data if key_object == 'detalles_facturas_notas'
		}

		res_proceso                                  = factura_aplicada.procesos_facturas_aplicadas(params) if res.status_valid

    if res_proceso.status_valid && factura_aplicada.errors.empty? && (!is_save || (is_save && factura_aplicada.save!))
      res.set_data(factura_aplicada)
    else
			res.add_msgs(res_proceso.get_msgs.to_a)
      res.add_msgs(factura_aplicada.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

	#  --------------------------------------------------------------------------------------------------------------------------------
	def procesos_facturas_aplicadas(params)
		res                = Response.new

		res_valid          = CabeceraFactura.agregar_nota_a_CabeceraFactura(params)

		unless res_valid.status_valid
			res.add_msgs(res_valid.get_msgs.to_a)
			res.set_status(HTTP_STATUS_CODE[:conflict])
		end

		return res
	end

  #  --------------------------------------------------------------------------------------------------------------------------------

  def self.validar_e_inicializar(items, padre, save)
    res_valid  = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_factura_aplicada(item, padre, !item[:id].nil?)

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
