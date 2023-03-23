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
    result_tasa                   = Response.new()
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
          result_tasa             = TasaCambio.create_year_tasa_cambio(divisa) if params[:id].nil?

          res.set_data(serialize_parser(divisa, {all: true}))

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
  def delete_divisa

    imagenes  = self.imagenes.map { | imagen | { file_hash: imagen.file_hash }.with_indifferent_access }

    resultado = borrar_entidad(self)

    if resultado.status_valid && self.imagenes.empty?
      imagenes.each do | imagen |
        Imagen.removeFileInThisServer(imagen)
      end
    end

    return resultado

  end
  # =========================================================================================================================================================

end
1