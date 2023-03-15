class ConfiguracionEntidadCuenta < ApplicationRecord
  belongs_to :cuenta_contable



  def otras_validaciones(params)
    if self.cuenta_contable_id.nil?
      self.errors.add(:base, "Debe de especificar cual sera la cuenta contable correspondiente para #{self.descripcion}.")
    end
  end

  # =========================================================================================================================================================

  def self.update_configuracion_entidad_cuenta(params, configuracion_entidad_cuenta, is_save=false)
    res = Response.new
    ConfiguracionEntidadCuenta.transaction do

      configuracion_entidad_cuenta.cuenta_contable_id     = params[:cuenta_contable_id]
      configuracion_entidad_cuenta.valid?

      configuracion_entidad_cuenta.otras_validaciones(params)

      if configuracion_entidad_cuenta.errors.empty? && configuracion_entidad_cuenta.save!
        res.set_data(serialize_parser(configuracion_entidad_cuenta, {all: true}))
        res.add_msg("Configuración entidad cuenta actualizada correctamente.")
      end

      unless configuracion_entidad_cuenta.errors.empty?
        res.add_msgs(configuracion_entidad_cuenta.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback if !configuracion_entidad_cuenta.errors.empty? || !res.status_valid
    end

    return res
  end


  # =========================================================================================================================================================

end
