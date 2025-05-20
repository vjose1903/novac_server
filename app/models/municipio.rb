class Municipio < ApplicationRecord
  belongs_to :provincia

  validates :nombre, presence: { :message => 'Debe de especificar un nombre para el municipio.' }

  def self.crear_actualizar_municipio(params, is_save=false)
    res = Response.new

    municipio               = Municipio.where(:id => params[:id]).first_or_create

    municipio.nombre        = params[:nombre]       if params.obj_has?(:nombre)
    municipio.codigo        = params[:codigo]       if params.obj_has?(:codigo)
    municipio.provincia_id  = params[:provincia_id] if params.obj_has?(:provincia_id)

    municipio.valid?
    municipio.errors.delete(:provincia) unless is_save
    
    if municipio.errors.empty? && (!is_save || (is_save && municipio.save!))
      res.set_data(municipio)
    else
      res.add_msgs(municipio.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
