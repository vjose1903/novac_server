class Suplidor < ApplicationRecord
  belongs_to  :divisa

  has_many    :documentos_de_identidad,    :as => :origen,         dependent: :destroy, class_name: "DocumentoDeIdentidad"
  has_many    :entidad_cuentas_contables,  :as => :origen_entidad, dependent: :destroy, class_name: 'EntidadCuentaContable'

  validates :nombre,     presence: { :message => 'Nombre del suplidor no puede estar vacio.' },      uniqueness: { scope: :estado, case_sensitive: false, :message => 'Suplidor ya está registrado.' }, :if => :estado
  validates :direccion,  presence: { :message => 'Dirección del suplidor no puede estar vacio.' }

  def otras_validaciones(params)
    self.errors.add(:base, "No se puede registrar un suplidor sin especificar sus atributos contables.") if !params[:cuentas_contables].present? || params[:cuentas_contables].nil?
  end

  # =========================================================================================================================================================
  def nombre_completo
    nombre    = self.nombre.capitalize
    nombre    = nombre.gsub("  ", " ").strip
    nombre
  end

  # ============================================================================================================================================

  def self.models_includes
    includes = [ :documentos_de_identidad, :entidad_cuentas_contables ]
    return includes
  end

  # ============================================================================================================================================

  def self.create_update_suplidor(params, is_save=false)
    res         = Response.new
    Suplidor.transaction do

      suplidor  = Suplidor.where(:id => params[:id]).first_or_create

      suplidor.divisa_id                       = params[:divisa_id]
      suplidor.nombre                          = params[:nombre]
      suplidor.telefono                        = params[:telefono]
      suplidor.direccion                       = params[:direccion]
      suplidor.email                           = params[:email]
      suplidor.estado                          = true
      suplidor.valid?

      suplidor.otras_validaciones(params)

      cuentas_config = { view_prima: true, usa_moneda_nacional: suplidor.divisa.is_principal, tipo_categoria: CatContable.categoria_entidad_contable, descripcion_cuenta: suplidor.nombre_completo }.with_indifferent_access
      EntCuentaContable.procesos_crear_cuenta(params, cuentas_config ) if suplidor.errors.empty?

      if suplidor.errors.empty?
        dependencias = [
          {modelo: DocumentoDeIdentidad,  key_object: 'documentos_de_identidad',   padre: suplidor },
          {modelo: EntidadCuentaContable, key_object: 'entidad_cuentas_contables', padre: suplidor }
        ]

        res = crear_actualizar_dependencias(dependencias, params, true) { | key_object, dependencia_data |
          suplidor.entidad_cuentas_contables  = dependencia_data if key_object == 'entidad_cuentas_contables'
          suplidor.documentos_de_identidad    = dependencia_data if key_object == 'documentos_de_identidad'
        }


        if res.status_valid && suplidor.save!
          res.set_data( serialize_parser( suplidor, { all: true } ))

          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Suplidor #{action} correctamente.")
        end
      end

      if !suplidor.errors.empty? || !res.status_valid
        res.add_msgs(suplidor.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !suplidor.errors.empty? || !res.status_valid

    end

    return res
  end

  # ============================================================================================================================================

  def self.filtrarSuplidores(arg, params)
    res = Response.new(params)

    suplidores = Suplidor
    .joins("left join documentos_de_identidad on suplidores.id = documentos_de_identidad.origen_id AND documentos_de_identidad.origen_type = 'Suplidor' AND documentos_de_identidad.principal = true")
    .where("lower(suplidores.nombre || ' ' || suplidores.direccion || ' ' || coalesce(suplidores.email, '') || ' ' || coalesce(documentos_de_identidad.documento, '')) like lower('%#{arg}%')  AND suplidores.estado = true")
    .order('suplidores.id ASC').to_a

    if suplidores.length > 0
      res.set_data(suplidores, {all: true})
    else
      res.set_data([])
      cantidad_registros = Suplidor.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen suplidores registrados.' : 'No existe suplidor con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
