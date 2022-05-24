class Municipio < ApplicationRecord
  belongs_to :provincia

  validates :nombre, presence: { :message => "Debe de especificar un nombre para la provincia." }

  def self.crear_actualizar_municipio(params, is_save=false)
    res = Response.new

    municipio               = Municipio.where(:id => params["id"]).first_or_create

    municipio.nombre        = params["nombre"]
    municipio.provincia_id  = params["provincia_id"]

    municipio.valid?

    if municipio.errors.empty? && (!is_save || (is_save && municipio.save!))
      res.set_data(municipio)
    else
      res.add_msgs(municipio.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
