class ConfigArticulo < ApplicationRecord

  # ===================================================================================================================================================

  def self.update_configuracion(params, is_save=false)
    res = Response.new

    ConfigArticulo.transaction do

      configuracion_articulo                       = ConfigArticulo.where(:id => params[:id]).first_or_create
      configuracion_articulo.porciento_ganancia    = params[:porciento_ganancia]

      configuracion_articulo.valid?

      if configuracion_articulo.errors.empty? && (!is_save || (is_save && configuracion_articulo.save!))

        res_valid                         = ConfigArticulo.procesos_articulos(params)

        if res_valid.status_valid
          res.set_data(configuracion_articulo, {all: true})
          res.add_msg("Configuración de articulos editada correctamente.")

        else
          res.add_msgs(res_valid.get_msgs.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
      end

      raise ActiveRecord::Rollback if !configuracion_articulo.errors.empty? || !res.status_valid

    end

    return res
  end

  # ===================================================================================================================================================

  def self.procesos_articulos(params)
    res = Response.new

    if params[:update_articulos]

      Articulo.all.each do | articulo |

        new_precio                 = articulo.costo_principal / ( (100 - params[:porciento_ganancia]).to_f / 100 )
        new_precio_rounded         = round_to_nearest_multiple_of_5(new_precio)

        articulo.precio_principal  = new_precio_rounded

        articulo.save!
      end
    end

    return res
  end
end
