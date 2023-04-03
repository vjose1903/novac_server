class Suplidor < ApplicationRecord
  belongs_to  :divisa

  has_many    :documentos_de_identidad,    :as => :origen,         dependent: :destroy, class_name: "DocumentoDeIdentidad"
  has_many    :entidad_cuentas_contables,  :as => :origen_entidad, dependent: :destroy, class_name: 'EntidadCuentaContable'

  validates :nombre,     presence: { :message => 'Nombre del suplidor no puede estar vacio.' },      uniqueness: { scope: :estado, case_sensitive: false, :message => 'Suplidor ya está registrado.' }, :if => :estado
  validates :direccion,  presence: { :message => 'Dirección del suplidor no puede estar vacio.' }

  def otras_validaciones(params)
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

      res = suplidor.procesos_crear_cuenta(params) if suplidor.errors.empty?

      if res.status_valid && suplidor.errors.empty?
        dependencias = [
          {modelo: DocumentoDeIdentidad,  key_object: 'documentos_de_identidad',   padre: suplidor },
          {modelo: EntidadCuentaContable, key_object: 'cuentas_contables', padre: suplidor }
        ]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data|
          suplidor.documentos_de_identidad    = dependencia_data if key_object == 'documentos_de_identidad'
          suplidor.entidad_cuentas_contables  = dependencia_data if key_object == 'cuentas_contables'
        }

        if res.status_valid && suplidor.save!
          res.set_data(serialize_parser(suplidor,{all:true}))

          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Suplidor #{action} correctamente.")
        end
      end

      if !suplidor.errors.empty? || !res.status_valid
        res.add_msgs(res.get_msgs.to_a)
        res.add_msgs(suplidor.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !suplidor.errors.empty? || !res.status_valid

    end

    return res
  end

  # ============================================================================================================================================

  def procesos_crear_cuenta(params)
    res                    = Response.new

    usa_moneda_nacional    = self.divisa.is_principal
    cuentas                = []


    # tipo_categoria
    # tipo_categoria_id
    # tipo_agrupacion_contable
    # is_comun
    # configuracion_entidad_cuenta_id

    configuraciones_cuentas_contables = ConfiguracionEntidadCuenta.where({ entidad: ConfigEntidadCuentaCont.suplidor })

    configuraciones_cuentas_contables.each do | config |

			next_cuenta = { tipo_categoria: CatContable.categoria_entidad_contable }.with_indifferent_access

      is_prima               = !usa_moneda_nacional && !config.is_prima

      descripcion_cuenta     = "Banco: #{banco.nombre} - CTA: #{self.numero_cuenta}"
      descripcion_cuenta    += " PRIMA" if is_prima

      cuenta_contable        = ConfiguracionEntidadCuenta.molde_cuenta(config.cuenta_contable, descripcion_cuenta)

      if (is_cuenta_nacional && !config.is_prima) || (!is_cuenta_nacional)

        temp_cuenta_contable              = CuentaContable.create_update_cuenta_contable(cuenta_contable, nil, true)
        if temp_cuenta_contable.status_valid
          cuenta_contable                 = temp_cuenta_contable.get_data.as_json.with_indifferent_access
          self.cuenta_contable_id         = cuenta_contable[:id] if !is_prima
          self.cuenta_contable_prima_id   = cuenta_contable[:id] if is_prima

        else
          res.add_msgs(temp_cuenta_contable.get_msgs)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      end
    end

    self.is_nacional = is_cuenta_nacional

    params[:cuentas_contables] = cuentas

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
