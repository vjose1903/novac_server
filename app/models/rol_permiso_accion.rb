class RolPermisoAccion < ApplicationRecord
  belongs_to :role
  belongs_to :permiso_accion


	def self.crear_actualizar(params, padre, is_save=false)
    res = Response.new

    unless params["id"]
      rolPermisoAccion                   = RolPermisoAccion.new
    else
      rolPermisoAccion                   = RolPermisoAccion.find_by_id(params["id"])
    end

    rolPermisoAccion.permiso_accion_id   = params["permiso_accion_id"]

    rolPermisoAccion.valid?

    rolPermisoAccion.errors.delete(:role) if !is_save

    if rolPermisoAccion.errors.empty? && (!is_save || (is_save && rolPermisoAccion.save!))
      res.set_data(rolPermisoAccion)
    else
      res.add_msgs(rolPermisoAccion.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_actualizar(item, padre, !item[:id].nil?)

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
