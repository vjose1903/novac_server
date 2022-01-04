class Produccion < ApplicationRecord
  belongs_to :user

  attribute :user

  has_many :detalles_produccion, dependent: :destroy

  # =========================================================================================================

  def self.create_update_produccion(params, is_save=false)
    Produccion.transaction do
      res = Response.new
      usuario_actual                      = get_current_user
      unless params["id"]
        produccion                        = Produccion.new()
      else
        produccion                        = Produccion.find_by_id(params["id"])
      end

      produccion.user_id                  = usuario_actual.id
      produccion.numero                   = SecuenciaFactura.find_secuencia(16)
      produccion.fecha_equivalente        = params["fecha_equivalente"] ? params["fecha_equivalente"] : DateTime.now

      dependencias = [ {modelo: DetalleProduccion, key_object: "detalles_produccion", padre: produccion} ]

      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data| 
        produccion.detalles_produccion    = dependencia_data if key_object == "detalles_produccion"
      }

      if res.status_valid && produccion.errors.empty? && (!is_save || (is_save && produccion.save!))

        res                               = updateSecuencias(16)
        
        if res.status_valid
          res.set_data(serialize_parser(produccion, {all: true}))  
          res.add_msg("Produccion creada correctamente.")

        else
          res.add_msgs(res.get_msgs)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(produccion.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
      
      return res
      raise ActiveRecord::Rollback unless conduce.errors.empty? 
    end
  end
  
  # =========================================================================================================================================================

  def self.filtrarProduccion(arg, params)
    res = Response.new(params)

    producciones = Produccion.all.order("id ASC").to_a

    if producciones.length > 0  
      res.set_data(producciones, {all: true})
    else
      res.set_data([])
      res.add_msg("No existen producciones con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
  
end
