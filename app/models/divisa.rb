class Divisa < ApplicationRecord
  has_many :imagenes, :as => :origen_img, dependent: :destroy, class_name: 'Imagen'
  has_many :tasas_de_cambio

  validates :nombre, presence: { :message => 'Debe de especificar el nombre de la divisa.' }, uniqueness: { scope: [:estado], case_sensitive: false, :message => 'Divisa ya está registrada' }, :if => :estado

  # =========================================================================================================================================================

  def self.models_includes
    includes = [:imagenes]
    return includes
  end

  # =========================================================================================================================================================

  def self.create_update_divisa(params, is_save=false )
    res                           = Response.new
    result_tasa                   = Response.new()
    Divisa.transaction do

      divisa                      = Divisa.where(:id => params[:id]).first_or_create

      divisa.nombre               = params[:nombre]
      divisa.simbolo              = params[:simbolo]
      divisa.is_principal         = params[:is_principal]   if params.has_key?(:is_principal)
      divisa.current_tasa         = params[:current_tasa]   if params.has_key?(:current_tasa)
      divisa.predeterminado       = params[:predeterminado] if params.has_key?(:predeterminado)

      divisa.valid?

      if divisa.errors.empty?
        dependencias              = [{ modelo: Imagen, key_object: 'imagenes', padre: divisa }]

        res = crear_actualizar_dependencias(dependencias, params) { | key_object, dependencia_data |
          divisa.imagenes         = dependencia_data if key_object == 'imagenes'
        }

        if res.status_valid && divisa.errors.empty? && (!is_save || (is_save && divisa.save!))
          result_tasa             = TasaCambio.create_year_tasa_cambio(divisa, params[:current_tasa]) if params[:id].nil?

          res.set_data(serialize_parser(divisa, { all: true }))

          action = params[:id] ? 'actualizada' : 'creada'
          res.add_msg("Divisa #{action} correctamente.")
        end
      end

      if !divisa.errors.empty? || !res.status_valid
        res.add_msgs(res.get_msgs.to_a)
        res.add_msgs(divisa.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !divisa.errors.empty? || !res.status_valid

    end

    return res
  end

  # =========================================================================================================================================================
  def deactivate_or_reactivate(params)
		res         = Response.new

    unless self.predeterminado

      self.estado = params[:status].to_boolean
      if self.save!
        action = params[:status].to_boolean ? 'reactivada' : 'desactivada'

        res.add_msg("Divisa: #{self.nombre}, #{action} correctamente.")
      else
        res.add_msg("Error desactivando la divisa: #{self.nombre}.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    else
      res.add_msg("No se puede desactivar la divisa: #{self.nombre}, por que es predeterminada.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end


    return res

  end

  # =========================================================================================================================================================

  def getMontoTasa(fecha)
    current_tasa        = self.tasas_de_cambio.find_by({ fecha_equivalente: formatearFecha(fecha.to_s, TipoFecha.sin_hora) })
    return current_tasa
  end

end
1