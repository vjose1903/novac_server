class MovimientosInventario < ApplicationRecord
  belongs_to :articulo
  belongs_to :user

  # --------------------------------------------------------------------------------------------------------------------------------

  def self.movimientos_de_inventario(movimiento, operador, fecha_movimiento, accion, padre )
    # puts "----- 1 -----".red
    res          = Response.new
		MovimientosInventario.transaction do

			articulo   = Articulo.find_by_id(movimiento["articulo_id"])
			# puts "movimiento[articulo_id]".blue + " #{movimiento[:articulo_id]}"
			# puts "movimiento[articulo_id]".yellow + " #{movimiento["articulo_id"]}"
			# puts "articulo".red + " #{articulo.to_json}"

			if articulo.nombre != 'Transporte'
				# puts "----- 2 -----".red

				# puts "articulo.existencia ".yellow + "#{articulo.existencia }"
				# puts "operador ".green + "#{operador }"
				# puts "movimiento[cantidad_en_unidades] ".magenta + "#{movimiento["cantidad_en_unidades"] }"

				mov      = eval("#{articulo.existencia} #{operador} #{movimiento["cantidad_en_unidades"]}")
				# puts "----- 3 -----".red

				if operador == "-" # --------- SALIDA ---------
					# puts "----- 4 -----".red
					if mov < 0
						# puts "----- 5 -----".red
						res.add_msg("Cantidad introducida para el articulo << #{articulo.nombre.titleize} >> excede la cantidad disponible en inventario. ")
						res.set_status(HTTP_STATUS_CODE[:conflict])
						return res
					end
				end
				# puts "----- 6 -----".red
				# fecha_fact = fecha_movimiento.fecha_equivalente.strftime("%d/%m/%Y")


				motivo = ""

				motivo = "#{operador == "+" ? "Entrada" : "Salida"} de mercancia por la #{accion.split("_").join(" ")} con el ncf: #{padre['numero_comprobante']} de la fecha #{fecha_movimiento}" if accion.include? "nota"
				motivo = "#{operador == "+" ? "Compra" : "Venta"} de mercancia en la factura con el ncf: #{padre['numero_comprobante']} de la fecha #{fecha_movimiento}" if accion == 'factura'
				motivo = "Salida de mercancia en el conduce con el número: #{padre['numero_conduce']} de la fecha #{fecha_movimiento}" if accion == 'conduce'
				motivo = movimiento['motivo'] if accion == 'movimiento'

				movimientos_inventario                          = MovimientosInventario.new
				# puts "----- 7 -----".red

				movimientos_inventario.user_id                  = get_current_user["id"]
				movimientos_inventario.articulo_id              = movimiento["articulo_id"]
				movimientos_inventario.cantidad                 = movimiento["cantidad"]
				movimientos_inventario.cantidad_en_unidades     = movimiento["cantidad_en_unidades"]
				movimientos_inventario.accion                   = OperadoresMovimiento.return_tipo(operador)
				movimientos_inventario.motivo                   = motivo
				movimientos_inventario.medida                   = movimiento["medida"] || movimiento["unidad"]
				movimientos_inventario.tipo_salida              = accion == 'movimiento' ? movimiento['tipo_salida'] : nil
				# puts "----- 8 -----".red

				unless movimientos_inventario.save!
					# puts "----- 9 -----".red
					res.add_msgs(movimientos_inventario.errors.to_a)
					res.set_status(HTTP_STATUS_CODE[:conflict])
					return res
				end

				# puts "----- 10 -----".red
				articulo.existencia = mov

				articulo.valid?
				# puts "articulo ".green + "#{articulo.to_json}"
				my_print_log("articulo.errors.to_a ".red + "#{articulo.errors.to_a}")

				if articulo.save!
					# puts "----- 11 -----".red

					# puts "::::::::::::::::::::::::::::::::::::::::::"
					# puts "::::                                  ::::"
					# puts "::::         #{operador == "-" ? "SALIDA " : "ENTRADA"} EXITOSA           ::::"
					# puts "::::                                  ::::"
					# puts "::::::::::::::::::::::::::::::::::::::::::"
				else
					# puts "----- 12 -----".red
					res.add_msgs(articulo.errors.to_a)
					res.set_status(HTTP_STATUS_CODE[:conflict])
				end

			end
		end

    # puts "----- 13 -----".red
    return res
  end
end
