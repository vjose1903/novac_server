class CostoFlete < ApplicationRecord
  belongs_to :municipio

  validates :municipio, presence: { :message => "Debe seleccionar una provincia." }, uniqueness: { case_sensitive: false, :message => "Esta ciudad ya esta registrada." }
  validates :costo, presence: { :message => "Debe de especificar un costo." }, numericality: { greater_than: 0, :message => "El costo del flete debe de ser mayor a 0." }

  def self.crear_actualizar_costo(params, is_save=false)
    res = Response.new

    unless params["id"]
      costo_flete = CostoFlete.new
    else
      costo_flete = CostoFlete.find_by_id(params["id"])
    end

    costo_flete.municipio_id = params["municipio_id"]
    costo_flete.costo = params["costo"]

    costo_flete.valid?

    if costo_flete.errors.to_a.empty? && (!is_save || (is_save && costo_flete.save!))
      res.set_data(costo_flete)
    else
      res.add_msgs(costo_flete.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
