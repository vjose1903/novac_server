class ConfiguracionEntidadCuenta < ApplicationRecord
  belongs_to :cuenta_contable

  validates :key,              presence: true
  validates :entidad,          presence: true

  def otras_validaciones(params)
    if self.cuenta_contable_id.nil?
      self.errors.add(:base, "Debe de especificar cual sera la cuenta contable correspondiente para #{self.descripcion}.")
    end
  end

  # =========================================================================================================================================================

  def self.create_update_configuracion_entidad_cuenta(params, configuracion_entidad_cuenta, is_save=false)

    res = Response.new
    ConfiguracionEntidadCuenta.transaction do

      configuracion_entidad_cuenta                        = ConfiguracionEntidadCuenta.where(:id => params[:cuenta_contable_id]).first_or_create if configuracion_entidad_cuenta.nil?

      configuracion_entidad_cuenta.descripcion            = params[:descripcion]
      configuracion_entidad_cuenta.entidad                = params[:entidad]
      configuracion_entidad_cuenta.cuenta_contable_id     = params[:cuenta_contable_id]
      configuracion_entidad_cuenta.key                    = params[:key]
      configuracion_entidad_cuenta.is_nacional            = params[:is_nacional]
      configuracion_entidad_cuenta.has_comun              = params[:has_comun]
      configuracion_entidad_cuenta.valid?

      configuracion_entidad_cuenta.otras_validaciones(params)

      if configuracion_entidad_cuenta.errors.empty? && configuracion_entidad_cuenta.save!

        res.set_data(configuracion_entidad_cuenta)
        res.add_msg("Configuración entidad cuenta actualizada correctamente.")
      end

      unless configuracion_entidad_cuenta.errors.empty?
        res.add_msgs(configuracion_entidad_cuenta.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

        transaction_rollback if !configuracion_entidad_cuenta.errors.empty? || !res.status_valid
    end

    return res
  end

  # =========================================================================================================================================================

  def self.molde_cuenta(cuenta_control, descripcion, is_control=false)
    return {
      grupo_cuenta_id: cuenta_control.grupo_cuenta_id,
      descripcion: descripcion,
      cuenta_control: cuenta_control.id,
      is_control: is_control,
      origen: cuenta_control.origen,
      tipo: cuenta_control.tipo
    }.with_indifferent_access
  end

  # =========================================================================================================================================================

end
