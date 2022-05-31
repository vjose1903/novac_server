class Provincia < ApplicationRecord
  validates :nombre, presence: { :message => "Debe de especificar un nombre para la provincia." }, uniqueness: { case_sensitive: false, :message => "Esta provincia ya esta creada"}

	has_many :municipios, dependent: :destroy
  accepts_nested_attributes_for :municipios, :allow_destroy => true

  def self.crear_actualizar_provincia(params, is_save=false)
    res = Response.new

		provincia         = Provincia.where(:id => params["id"]).first_or_create

    provincia.nombre  = params["nombre"]

    provincia.valid?

    if provincia.errors.empty? && (!is_save || (is_save && provincia.save!))
      res.set_data(provincia)
    else
      res.add_msgs(provincia.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
