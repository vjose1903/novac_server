class ConfiguracionEntidadCuenta < ApplicationRecord
  belongs_to :cuenta_contable

  validates :key,              presence: true
  validates :entidad,          presence: true

  def otras_validaciones(params)
    if self.cuenta_contable_id.nil?
      self.errors.add(:base, "Debe de especificar cual sera la cuenta contable correspondiente para #{self.descripcion}.")
    end
  end

  # ============================================================================================================================================

  def self.models_includes
    includes = [ :cuenta_contable ]
    return includes
  end

  # ============================================================================================================================================

  def self.filtrar( params, parametros_opcionales={} )

    res                   = Response.new
    filter_target         = params[:filter_target]

    configs_filtered      = ConfiguracionEntidadCuenta.all.where({ entidad: filter_target }).order('id ASC').includes(ConfiguracionEntidadCuenta.models_includes)

    if !configs_filtered.empty? && configs_filtered.length > 0
      res.set_data(serialize_parser(configs_filtered, parametros_opcionales))
    else
      res.set_data([])
      res.add_msg('No existen configuraciones para entidades contables con las especificaciones introducidas.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =========================================================================================================================================================

  def self.create_update_configuracion_entidad_cuenta(params, configuracion_entidad_cuenta, is_save=false)

    res = Response.new
    ConfiguracionEntidadCuenta.transaction do

      configuracion_entidad_cuenta                        = ConfiguracionEntidadCuenta.where(:id => params[:cuenta_contable_id]).first_or_create if configuracion_entidad_cuenta.nil?

      configuracion_entidad_cuenta.descripcion            = params[:descripcion]          if params[:descripcion].present?
      configuracion_entidad_cuenta.entidad                = params[:entidad]              if params[:entidad].present?
      configuracion_entidad_cuenta.cuenta_contable_id     = params[:cuenta_contable_id]   if params[:cuenta_contable_id].present?
      configuracion_entidad_cuenta.key                    = params[:key]                  if params[:key].present?
      configuracion_entidad_cuenta.is_nacional            = params[:is_nacional]          if params[:is_nacional].present?
      configuracion_entidad_cuenta.has_comun              = params[:has_comun]            if params[:has_comun].present?
      configuracion_entidad_cuenta.has_individual         = params[:has_individual]       if params[:has_individual].present?
      configuracion_entidad_cuenta.has_categoria          = params[:has_categoria]        if params[:has_categoria].present?
      configuracion_entidad_cuenta.has_sub_categoria      = params[:has_sub_categoria]    if params[:has_sub_categoria].present?
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
      cuenta_control_id: cuenta_control.id,
      is_control: is_control,
      origen: cuenta_control.origen,
      tipo: cuenta_control.tipo,
      action: 'create'
    }.with_indifferent_access
  end

  # =========================================================================================================================================================

end
