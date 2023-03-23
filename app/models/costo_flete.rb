class CostoFlete < ApplicationRecord
  belongs_to :municipio

  validates :municipio, presence: { :message => "Debe seleccionar una provincia." }, uniqueness: { case_sensitive: false, :message => "Esta ciudad ya esta registrada." }
  validates :costo, presence: { :message => "Debe de especificar un costo." }, numericality: { greater_than: 0, :message => "El costo del flete debe de ser mayor a 0." }

  def self.crear_actualizar_costo(params, current_user, is_save=false)
    res                         = Response.new
    CostoFlete.transaction do
      historial                 = nil

      costo_flete               = CostoFlete.where(:id => params["id"]).first_or_create

      costo_flete.municipio_id  = params["municipio_id"]
      costo_flete.costo         = params["costo"]
      costo_flete.estado        = true

      costo_flete.valid?

      if costo_flete.errors.empty? && (!is_save || (is_save && costo_flete.save!))

        historial               = costo_flete.attributes.clone if historial.nil?

        if CostoFlete.set_historial(historial, current_user)
          res.set_data(costo_flete)
        else
          res.add_msg("Error guardando el historial")
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(costo_flete.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !costo_flete.errors.empty? || !res.status_valid
    end

    return res
  end

  def self.set_historial(data, current_user)
    historial = data.clone
    historial["costo_flete_id"] = historial["id"]
    historial["id"] = nil
    historial["user_id"] = current_user["id"]

    historial_parsed = CostoFleteHistorial.new(historial)

    return  historial_parsed.save!
  end

end
