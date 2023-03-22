class Divisa < ApplicationRecord
  has_many :imagenes, :as => :origen, dependent: :destroy, class_name: "Imagen"

  validates :nombre, presence: { :message => "Debe de especificar el nombre de la divisa." },         uniqueness: { scope: [:estado], case_sensitive: false, :message => "Divisa ya esta registrada" }, :if => :estado

  # =========================================================================================================================================================

  def self.models_includes
    includes = [:imagenes]
    return includes
  end

  # =========================================================================================================================================================

  def self.create_update_divisa(params, is_save=false )
    res                           = Response.new
    Divisa.transaction do

      divisa                      = Divisa.where(:id => params[:id]).first_or_create

      divisa.nombre               = params[:nombre]
      divisa.simbolo              = params[:simbolo]
      divisa.is_principal         = params[:is_principal]

      divisa.valid?

      if divisa.errors.empty?
        dependencias              = [{ modelo: Imagen, key_object: "imagenes", padre: divisa }]

        res = crear_actualizar_dependencias(dependencias, params, true) { | key_object, dependencia_data |
          divisa.imagenes         = dependencia_data if key_object == 'imagenes'
        }


        if res.status_valid && divisa.errors.empty? && (!is_save || (is_save && divisa.save!))
          res.set_data(serialize_parser(divisa, {all: true}))

          action = params[:id] ? 'actualizada' : 'creada'
          res.add_msg("Divisa #{action} correctamente.")
        end
      end

      unless divisa.errors.empty?
        res.add_msgs(divisa.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback if !divisa.errors.empty? || !res.status_valid
    end

    return res
  end


  # =========================================================================================================================================================

end
1