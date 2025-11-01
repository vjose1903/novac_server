class MovimientoViaje < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :vehiculo, optional: true
  belongs_to :cabecera_factura

  def self.crear_actualizar_movimiento_viaje(params, padre, is_save=false)
    res         = Response.new
    res_valid   = Response.new

    MovimientoViaje.transaction do
      movimiento_viaje                         = MovimientoViaje.where(:id => params["id"]).first_or_initialize

      movimiento_viaje.vehiculo_id             = params["vehiculo_id"]
      movimiento_viaje.user_id                 = params["user_id"]
      movimiento_viaje.cabecera_factura_id     = params["cabecera_factura_id"]

      movimiento_viaje.valid?

      movimiento_viaje.errors.delete(:cabecera_factura) if !is_save

      res_valid                                = movimiento_viaje.vehiculo.ajustarCantViaje("+")

      if res_valid.status_valid && movimiento_viaje.errors.empty? && (!is_save || (is_save && movimiento_viaje.save!))
        res.set_data(movimiento_viaje)
      else
        res.add_msgs(res_valid.get_msgs.to_a)
        res.add_msgs(movimiento_viaje.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !movimiento_viaje.errors.empty? || !res.status_valid
    end

    return res
  end

  def self.validar_e_inicializar(items, padre)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_actualizar_movimiento_viaje(item, padre, !item[:id].nil?)

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
