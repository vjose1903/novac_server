class MovimientoViaje < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :vehiculo, optional: true
  belongs_to :cabecera_factura

  after_create :incrementar_cantidad_viajes
  after_update :ajustar_cantidad_viajes_si_cambio
  after_destroy :decrementar_cantidad_viajes

  def self.crear_actualizar_movimiento_viaje(params, padre, is_save=false)
    res = Response.new

    MovimientoViaje.transaction do
      vehiculo = Vehiculo.where(id: params["vehiculo_id"], estado: true).first
      movimiento_viaje = build_movimiento_viaje(params, is_save)

      unless vehiculo
        res.add_msg('El camión seleccionado no existe o está inactivo.')
        res.set_status(HTTP_STATUS_CODE[:conflict])
        raise ActiveRecord::Rollback
      end

      res = persist_movimiento_viaje(movimiento_viaje, res, is_save)

      raise ActiveRecord::Rollback if !movimiento_viaje.errors.empty? || !res.status_valid
    end

    return res
  end

  private_class_method def self.build_movimiento_viaje(params, is_save)
    movimiento_viaje                         = MovimientoViaje.where(:id => params["id"]).first_or_initialize
    movimiento_viaje.vehiculo_id             = params["vehiculo_id"]
    movimiento_viaje.user_id                 = params["user_id"]
    movimiento_viaje.cabecera_factura_id     = params["cabecera_factura_id"]
    movimiento_viaje.valid?
    movimiento_viaje.errors.delete(:cabecera_factura) unless is_save
    movimiento_viaje
  end

  private_class_method def self.persist_movimiento_viaje(movimiento_viaje, res_valid, is_save)
    if res_valid.status_valid && movimiento_viaje.errors.empty? && (!is_save || movimiento_viaje.save!)
      res = Response.new
      res.set_data(movimiento_viaje)
      return res
    end

    res = Response.new
    res.add_msgs(res_valid.get_msgs.to_a)
    res.add_msgs(movimiento_viaje.errors.to_a)
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end

  def self.validar_e_inicializar(items, padre, save)
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

  private

  def incrementar_cantidad_viajes
    vehiculo&.ajustarCantViaje('+')
  end

  def ajustar_cantidad_viajes_si_cambio
    return unless saved_changes.key?('vehiculo_id')

    vehiculo_anterior_id, vehiculo_nuevo_id = saved_changes['vehiculo_id']
    Vehiculo.find_by(id: vehiculo_anterior_id)&.ajustarCantViaje('-')
    Vehiculo.find_by(id: vehiculo_nuevo_id)&.ajustarCantViaje('+')
  end

  def decrementar_cantidad_viajes
    vehiculo&.ajustarCantViaje('-')
  end
end
