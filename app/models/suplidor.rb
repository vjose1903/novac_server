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

  def self.models_includes
    [:documentos_de_identidad]
  end

  def self.models_includes_for(params)
    return [:documentos_de_identidad] if params[:all] || params[:documentos_de_identidad]

    []
  end

  def self.serialized_response(suplidores, params, serializer_params, msg=nil)
    paginate_class = Paginator.new(params)
    includes = models_includes_for(serializer_params)
    paginate_class.paginate_data(suplidores, includes.empty? ? nil : includes)

    res = {status: HTTP_STATUS_CODE[:ok], data: SuplidorSerializer.collection_to_hash(paginate_class.get_data, serializer_params), msg: msg}
    if paginate_class.is_paginated
      res[:total_registros] = paginate_class.get_total_registros
      res[:total_paginas] = paginate_class.get_total_paginas
    end
    res
  end

  def self.filter_order_columns
    {
      "id" => "suplidores.id",
      "nombre" => "suplidores.nombre",
      "telefono" => "suplidores.telefono",
      "direccion" => "suplidores.direccion",
      "email" => "suplidores.email",
      "created_at" => "suplidores.created_at",
      "updated_at" => "suplidores.updated_at"
    }
  end

  def self.parse_filter_order(order_by)
    ORDER_MANAGER.parse_safe(order_by, filter_order_columns, "suplidores.id ASC")
  end

  def self.create_update_suplidor(params , is_save=false)
    res                          = Response.new
    Suplidor.transaction do

      suplidor                   = Suplidor.where(:id => params["id"]).first_or_initialize

      suplidor.nombre            = params["nombre"]
      suplidor.telefono          = params["telefono"]
      suplidor.direccion         = params["direccion"]
      suplidor.email             = params["email"]
      suplidor.estado            = true
      suplidor.valid?

      if suplidor.errors.empty?
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
      end

      raise ActiveRecord::Rollback if !suplidor.errors.empty? || !res.status_valid

    end

    return res
  end

  # ============================================================================================================================================

  def self.filtrarSuplidores(arg, params)
    serializer_params = {all: true}
    suplidores = Suplidor
      .where(estado: true)
      .joins("LEFT JOIN documentos_de_identidad ON suplidores.id = documentos_de_identidad.origen_id
        AND documentos_de_identidad.origen_type = 'Suplidor'
        AND documentos_de_identidad.principal = true")
      .distinct

    arg.to_s.downcase.split.each do |palabra|
      palabra = "%#{ActiveRecord::Base.sanitize_sql_like(palabra)}%"
      suplidores = suplidores.where(
        "immutable_unaccent(suplidores.nombre) ILIKE immutable_unaccent(:palabra)
          OR immutable_unaccent(suplidores.direccion) ILIKE immutable_unaccent(:palabra)
          OR immutable_unaccent(suplidores.email) ILIKE immutable_unaccent(:palabra)
          OR immutable_unaccent(documentos_de_identidad.documento) ILIKE immutable_unaccent(:palabra)",
        palabra: palabra
      )
    end

    suplidores = suplidores.order(Arel.sql(parse_filter_order(params["order_by"])))

    return Response.new(params, HTTP_STATUS_CODE[:ok], suplidores, [], serializer_params, Suplidor.models_includes_for(serializer_params)) if suplidores.exists?

    res = Response.new(params)
    res.set_data([])
    cantidad_registros = Suplidor.where(estado: true).count
    res.add_msg(cantidad_registros == 0 ? "No existen suplidores registrados." : "No existe suplidor con las especificaciones introducidas")
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end

end
