class MovimientosInventario < ApplicationRecord
  belongs_to :articulo
  belongs_to :user

  # --------------------------------------------------------------------------------------------------------------------------------

  def self.movimientos_de_inventario(movimiento, operador, fecha_movimiento, accion, padre )
    res = Response.new
		MovimientosInventario.transaction do

			articulo        = Articulo.find_by_id(movimiento["articulo_id"])
			tipo_articulo   = articulo.tipo_articulo
      return res unless registra_movimiento_inventario?(articulo, tipo_articulo)

      mov = nueva_existencia(articulo, movimiento, operador)
      mov = 0 if vende_sin_inventario?(movimiento, mov)
      return inventario_insuficiente_response(res, articulo) if salida_sin_existencia?(operador, mov)

      movimientos_inventario = build_movimiento_inventario(movimiento, operador, fecha_movimiento, accion, padre)
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

    return res
  end

  private_class_method def self.registra_movimiento_inventario?(articulo, tipo_articulo)
    articulo.nombre != 'Transporte' && tipo_articulo.tipo != TipoArticuloType.servicio
  end

  private_class_method def self.nueva_existencia(articulo, movimiento, operador)
    cantidad = movimiento["cantidad_en_unidades"].to_f
    operador == "+" ? articulo.existencia + cantidad : articulo.existencia - cantidad
  end

  private_class_method def self.vende_sin_inventario?(movimiento, mov)
    mov < 0 && movimiento['vende_sin_inventario'].present? && movimiento['vende_sin_inventario']
  end

  private_class_method def self.salida_sin_existencia?(operador, mov)
    operador == "-" && mov < 0
  end

  private_class_method def self.inventario_insuficiente_response(res, articulo)
    res.add_msg("Cantidad introducida para el articulo << #{articulo.nombre.titleize} >> excede la cantidad disponible en inventario. ")
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end

  private_class_method def self.build_movimiento_inventario(movimiento, operador, fecha_movimiento, accion, padre)
    movimientos_inventario                          = MovimientosInventario.new
    movimientos_inventario.user_id                  = get_current_user["id"]
    movimientos_inventario.articulo_id              = movimiento["articulo_id"]
    movimientos_inventario.cantidad                 = movimiento["cantidad"]
    movimientos_inventario.cantidad_en_unidades     = movimiento["cantidad_en_unidades"]
    movimientos_inventario.accion                   = OperadoresMovimiento.return_tipo(operador)
    movimientos_inventario.motivo                   = motivo_movimiento(operador, fecha_movimiento, accion, padre, movimiento)
    movimientos_inventario.medida                   = movimiento["medida"] || movimiento["unidad"]
    movimientos_inventario.tipo_salida              = accion == 'movimiento' ? movimiento['tipo_salida'] : nil
    movimientos_inventario
  end

  private_class_method def self.motivo_movimiento(operador, fecha_movimiento, accion, padre, movimiento)
    return "#{operador == "+" ? "Entrada" : "Salida"} de mercancia por la #{accion.split("_").join(" ")} con el ncf: #{padre['numero_comprobante']} de la fecha #{fecha_movimiento}" if accion.include? "nota"
    return "#{operador == "+" ? "Compra" : "Venta"} de mercancia en la factura con el ncf: #{padre['numero_comprobante']} de la fecha #{fecha_movimiento}" if accion == 'factura'
    return "Salida de mercancia en el conduce con el número: #{padre['numero_conduce']} de la fecha #{fecha_movimiento}" if accion == 'conduce'
    return movimiento['motivo'] if accion == 'movimiento'

    ""
  end
end
