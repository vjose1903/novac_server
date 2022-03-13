class FacturaAplicada < ApplicationRecord
  belongs_to :nota
  belongs_to :cabeza_factura


	def self.crear_factura_aplicada(params, padre, is_save=false)
    res = Response.new

    factura_aplicada                           = DetalleFactura.new

    factura_aplicada.cabecera_factura_id       = params["cabecera_factura_id"]
    factura_aplicada.total                     = params["total"]

    factura_aplicada.valid?

    factura_aplicada.errors.delete(:nota) if !is_save

    res_proceso                               = factura_aplicada.procesos_facturas_aplicadas(params, padre)

    if res_proceso.status_valid && factura_aplicada.errors.empty? && (!is_save || (is_save && factura_aplicada.save!))
      res.set_data(factura_aplicada)
    else
      res.add_msgs(factura_aplicada.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

	#  --------------------------------------------------------------------------------------------------------------------------------
	def procesos_facturas_aplicadas(params, nota)
		res                = Response.new

		begin
			operador         = nota.tipo_factura_id == TiposNotasId.credito ? "+" : "-"
			fecha            = nota.fecha_equivalente
			accion           = nota.tipo_nota
		rescue => exception
			operador         = nota["tipo_factura_id"] == TiposNotasId.credito ? "+" : "-"
			fecha            = nota["fecha_equivalente"]
			accion           = TiposNotas.get_tipo(nota["tipo_factura_id"])
		end

		res_valid          = MovimientosInventario.movimientos_de_inventario_(params, operador, fecha, accion, nota )

		res_valid          = CabeceraFactura.agregar_nota_a_CabeceraFactura(params)  if res_valid.status_valid

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
