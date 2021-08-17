class CostoFlete < ApplicationRecord
  belongs_to :municipio

  validates :municipio, presence: { :message => "Debe seleccionar una provincia." }, uniqueness: { case_sensitive: false, :message => "Esta ciudad ya esta registrada." }
  validates :costo, presence: { :message => "Debe de especificar un costo." }, numericality: { greater_than: 0, :message => "El costo del flete debe de ser mayor a 0." }

  def self.crear_actualizar_costo(params, current_user, is_save=false)
    CostoFlete.transaction do
      res = Response.new
      historial = nil

      unless params["id"]
        costo_flete = CostoFlete.new
      else
        costo_flete = CostoFlete.find_by_id(params["id"])
        puts "BUSCANDO HISTORIAL --> ".yellow + "#{costo_flete.to_json}"
        historial = costo_flete.attributes.clone
      end
      
      
      costo_flete.municipio_id = params["municipio_id"]
      costo_flete.costo = params["costo"]
      costo_flete.estado = true
      
      puts "costo_flete --> ".red + "#{costo_flete.to_json}"
      costo_flete.valid?
      
      if costo_flete.errors.to_a.empty? && (!is_save || (is_save && costo_flete.save!))
        puts "historial =====> ".cyan + "(#{historial.to_json})"
        puts "#{historial.nil? ? "CREANDO NUEVO HISTORIAL" : "AÑADIENDO HISTORIAL"}".green

        
        historial = costo_flete.attributes.clone if historial.nil?
        puts "historial =====> ".red + "(#{historial.to_json})"

        if CostoFlete.set_historial(historial, current_user)
          res.set_data(costo_flete)
        else
          res.add_msg("Error guardando el historial")
          res.set_status(HTTP_STATUS_CODE[:conflict])
          raise ActiveRecord::Rollback
        end

      else
        res.add_msgs(costo_flete.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res
    end
  end

  def self.set_historial(data, current_user)

    puts "=========== CREANDO HISTORIAL ===========".red
    historial = data.clone
    historial["costo_flete_id"] = historial["id"]
    historial["id"] = nil
    historial["user_id"] = current_user["id"]

    puts "historial =====> ".yellow + "#{historial}"
    historial_parsed = CostoFleteHistorial.new(historial)
    
    return  historial_parsed.save!
  end

end
