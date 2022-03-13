class Suplidor < ApplicationRecord

  validates :nombre, presence: { :message => "El nombre del suplidor no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "Este suplidor ya esta registrado" }

  has_many :documentos_de_identidad, :as => :origen, dependent: :destroy, class_name: "DocumentoDeIdentidad"

  accepts_nested_attributes_for :documentos_de_identidad, :allow_destroy => true

  validates :nombre,              presence: { :message => "Nombre del suplidor no puede estar vacio." },      uniqueness: { scope: :estado, case_sensitive: false, :message => "Suplidor ya esta registrado" }, :if => :estado
  validates :direccion,           presence: { :message => "Dirección del suplidor no puede estar vacio." }

  def nombre_completo
    nombre    = self.nombre.capitalize
    nombre    = nombre.gsub("  ", " ").strip
    nombre
  end

  def self.create_update_suplidor(params , is_save=false)
		res                          = Response.new
    Suplidor.transaction do

      unless params["id"]
        suplidor                 = Suplidor.new
      else
        suplidor                 = Suplidor.find_by_id(params["id"])
      end

      suplidor.nombre            = params["nombre"]
      suplidor.telefono          = params["telefono"]
      suplidor.direccion         = params["direccion"]
      suplidor.email             = params["email"]
      suplidor.estado            = true


      if suplidor.errors.empty? && suplidor.valid?
        dependencias = [{modelo: DocumentoDeIdentidad, key_object: "documentos_de_identidad", padre: suplidor }]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data|
          suplidor.documentos_de_identidad = dependencia_data if key_object == 'documentos_de_identidad'
        }

        if res.status_valid && suplidor.save!
          res.set_data(serialize_parser(suplidor,{all:true}))

          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Suplidor #{action} correctamente.")
        end
      end

      unless suplidor.errors.empty?

        res.add_msgs(suplidor.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
        return res
        raise ActiveRecord::Rollback

      end

      return res
    end

  end

  # ============================================================================================================================================

  def self.filtrarSuplidores(arg, params)
    res = Response.new(params)

    suplidores = Suplidor
    .joins("left join documentos_de_identidad on suplidores.id = documentos_de_identidad.origen_id AND documentos_de_identidad.origen_type = 'Suplidor' AND documentos_de_identidad.principal = true")
    .where("lower(suplidores.nombre || ' ' || suplidores.direccion || ' ' || coalesce(suplidores.email, '') || ' ' || coalesce(documentos_de_identidad.documento, '')) like lower('%#{arg}%')  AND suplidores.estado = true")
    .order("suplidores.id ASC").to_a

    if suplidores.length > 0
      res.set_data(suplidores, {all: true})
    else
      res.set_data([])
			cantidad_registros = Suplidor.all.count
      res.add_msg("No existe suplidor con las especificaciones introducidas") if cantidad_registros > 0
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
