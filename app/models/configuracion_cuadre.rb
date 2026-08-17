class ConfiguracionCuadre < ApplicationRecord

  # ===================================================================================================================================================

  def self.update_configuracion(params, is_save=false)
    res = Response.new

    ConfiguracionCuadre.transaction do

      configuracion                          = ConfiguracionCuadre.where(:id => params[:id]).first_or_initialize
      configuracion.config                   = params[:config] if params.obj_has?(:config)

      configuracion.valid?

      if configuracion.errors.empty? && (!is_save || (is_save && configuracion.save!))
        res.set_data(configuracion, { all: true })
        res.add_msg("Configuración de cuadres actualizada correctamente.")
      end

      unless configuracion.errors.empty?
        res.add_msgs(configuracion.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback if !configuracion.errors.empty? || !res.status_valid

    end

    return res
  end

  # ===================================================================================================================================================

end
