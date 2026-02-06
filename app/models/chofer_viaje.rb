class ChoferViaje < ApplicationRecord
  belongs_to :user
  belongs_to :recibos_ingreso

  def self.crear_actualizar_chofer_viaje(params, padre, is_save=false)
    res = Response.new

    chofer_viaje                = ChoferViaje.where(:id => params["id"]).first_or_initialize

    chofer_viaje.user_id        = params["user_id"]
    chofer_viaje.valid?

    chofer_viaje.errors.delete(:recibos_ingreso) if !is_save


    if chofer_viaje.errors.empty? && (!is_save || (is_save && chofer_viaje.save!))
      res.set_data(chofer_viaje)
    else
      res.add_msgs(chofer_viaje.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_actualizar_chofer_viaje(item, padre, !item[:id].nil?)

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
