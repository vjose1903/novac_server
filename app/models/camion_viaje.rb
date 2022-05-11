class CamionViaje < ApplicationRecord
  belongs_to :vehiculo
  belongs_to :cabecera_factura, optional: true

  belongs_to :origen, polymorphic: true

  def self.crear_actualizar_camion_viaje(params, padre, is_save=false)
    res         = Response.new
    res_valid   = Response.new

    CamionViaje.transaction do
      camion_viaje                         = CamionViaje.where(:id => params["id"]).first_or_create

      camion_viaje.vehiculo_id             = params["vehiculo_id"]
      camion_viaje.origen                  = padre

      camion_viaje.valid?

      res_valid                            = camion_viaje.vehiculo.ajustarCantViaje("+") if padre.model_name.element == "recibos_ingreso"

      if res_valid.status_valid && camion_viaje.errors.empty? && (!is_save || (is_save && camion_viaje.save!))
        res.set_data(camion_viaje)
      else
        res.add_msgs(res_valid.get_msgs.to_a)
        res.add_msgs(camion_viaje.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless res.status_valid
    end

    return res
  end

  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_actualizar_camion_viaje(item, padre, !item[:id].nil?)

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
