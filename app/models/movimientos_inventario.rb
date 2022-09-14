class MovimientosInventario < ApplicationRecord
  belongs_to :articulo
  belongs_to :user

  # --------------------------------------------------------------------------------------------------------------------------------

  def self.movimientos_de_inventario(movimiento, operador, fecha_movimiento, accion, padre )
    res               = Response.new
		MovimientosInventario.transaction do

			articulo        = Articulo.find_by_id(movimiento["articulo_id"])
			tipo_articulo   = articulo.tipo_articulo


			if articulo.nombre != 'Transporte' && tipo_articulo.tipo != TipoArticuloType.servicio
				mov           = eval("#{articulo.existencia} #{operador} #{movimiento["cantidad_en_unidades"]}")

				mov           = 0 if mov < 0 && movimiento['vende_sin_inventario'].presence && movimiento['vende_sin_inventario']

				if operador == "-" # --------- SALIDA ---------

					if mov < 0
						res.add_msg("Cantidad introducida para el articulo << #{articulo.nombre.titleize} >> excede la cantidad disponible en inventario. ")
						res.set_status(HTTP_STATUS_CODE[:conflict])
						return res
					end
				end

				motivo = ""

				motivo = "#{operador == "+" ? "Entrada" : "Salida"} de mercancia por la #{accion.split("_").join(" ")} con el ncf: #{padre['numero_comprobante']} de la fecha #{fecha_movimiento}" if accion.include? "nota"
				motivo = "#{operador == "+" ? "Compra" : "Venta"} de mercancia en la factura con el ncf: #{padre['numero_comprobante']} de la fecha #{fecha_movimiento}" if accion == 'factura'
				motivo = "Salida de mercancia en el conduce con el número: #{padre['numero_conduce']} de la fecha #{fecha_movimiento}" if accion == 'conduce'
				motivo = movimiento['motivo'] if accion == 'movimiento'

				movimientos_inventario                          = MovimientosInventario.new

				movimientos_inventario.user_id                  = get_current_user["id"]
				movimientos_inventario.articulo_id              = movimiento["articulo_id"]
				movimientos_inventario.cantidad                 = movimiento["cantidad"]
				movimientos_inventario.cantidad_en_unidades     = movimiento["cantidad_en_unidades"]
				movimientos_inventario.accion                   = OperadoresMovimiento.return_tipo(operador)
				movimientos_inventario.motivo                   = motivo
				movimientos_inventario.medida                   = movimiento["medida"] || movimiento["unidad"]
				movimientos_inventario.tipo_salida              = accion == 'movimiento' ? movimiento['tipo_salida'] : nil

				unless movimientos_inventario.save!
					res.add_msgs(movimientos_inventario.errors.to_a)
					res.set_status(HTTP_STATUS_CODE[:conflict])
					return res
				end

				articulo.existencia = mov

				articulo.valid?
				my_print_log("articulo.errors.to_a ".red + "#{articulo.errors.to_a}")

				unless articulo.save!
					res.add_msgs(articulo.errors.to_a)
					res.set_status(HTTP_STATUS_CODE[:conflict])
				end

			end
		end

    return res
  end
end
