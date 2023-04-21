class TipoArticulo < ApplicationRecord
  has_many   :sub_tipo_articulo
  has_many   :entidad_cuentas_contables,       :as => :origen_categoria, class_name: 'EntidadCuentaContable'
  has_many   :tipo_articulo_cuentas_contables, :as => :origen_tipo,      class_name: 'TipoArticuloCuentaContable'

  validates :descripcion,                presence: { :message => "Descripción de la categoria no puede estar vacia." },         uniqueness: { case_sensitive: false, :message => "Categoria ya está registrada." }

  # =========================================================================================================================================================

  def self.models_includes
    includes = [
      { tipo_articulo_cuentas_contables: [ :cuenta_contable_control, :cuenta_contable_auxiliar, :configuracion_entidad_cuenta ] },
    ]
    return includes
  end

  # =========================================================================================================================================================

  def self.create_update_tipo_articulo(params, is_save=false)

    res                                = Response.new

    TipoArticulo.transaction do

      tipo_articulo                    = TipoArticulo.where(:id => params[:id]).first_or_create

      tipo_articulo.descripcion        = params[:descripcion]
      tipo_articulo.tipo               = params[:tipo]
      tipo_articulo.codigo             = tipo_articulo.descripcion.downcase.gsub(" ", "_").strip if params[:id].nil? || !params[:id].present?
      result_procesos                  = tipo_articulo.procesos_parsear_cuentas(params)

      tipo_articulo.valid?

      if tipo_articulo.errors.empty? && result_procesos.status_valid

        dependencias = [ { modelo: TipoArticuloCuentaContable,  key_object: 'tipo_articulo_cuentas_contables',   padre: tipo_articulo } ]

        res = crear_actualizar_dependencias(dependencias, params, true) { | key_object, dependencia_data |
          tipo_articulo.tipo_articulo_cuentas_contables  = dependencia_data if key_object == 'tipo_articulo_cuentas_contables'
        }

        if res.status_valid && tipo_articulo.errors.empty? && (!is_save || (is_save && tipo_articulo.save!))
          res.set_data(tipo_articulo)
        end

      end

      if !tipo_articulo.errors.empty? || !result_procesos.status_valid
        res.add_msgs(result_procesos.get_msgs.to_a)
        res.add_msgs(tipo_articulo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !tipo_articulo.errors.empty? || !res.status_valid
    end

    return res

  end

  # ============================================================================================================================================

  def procesos_parsear_cuentas(params)
    res = Response.new

    if params[:id].nil? || !params[:id].present? || self.tipo_articulo_cuentas_contables.empty?

      cuentas                     = []
      configs_articulo            = ConfiguracionEntidadCuenta.where({ entidad: ConfigEntidadCuentaCont.articulo })

      configs_articulo.each do | config_articulo |

        config_muck               = G_CONFIG_ENTIDAD_CUENTA.find { | config | config[:key] == config_articulo.key && config[:entidad] == config_articulo.entidad }.with_indifferent_access

        descripcion_cuenta        = "#{ConfigEntidadCuentaCont::Keys.label[:"#{config_articulo.key}"]}: #{self.descripcion}"
        descripcion_cuenta_comun  = "#{ConfigEntidadCuentaCont::Keys.label[:"#{config_articulo.key}"]} común: #{self.descripcion}"

        cuentas.push({
          key:                               config_articulo.key,
          entidad:                           config_articulo.entidad,
          descripcion_cuenta:                descripcion_cuenta,
          descripcion_cuenta_comun:          descripcion_cuenta_comun,
          cuenta_contable:                   config_articulo.cuenta_contable,
          configuracion_entidad_cuenta_id:   config_articulo.id,
          is_control:                        config_muck[:is_control],
          has_comun:                         config_articulo.has_comun
        }.with_indifferent_access)
      end

      params[:tipo_articulo_cuentas_contables] = cuentas
    else

      cuentas = []

      self.tipo_articulo_cuentas_contables.each do | cuenta |
        config_muck               = G_CONFIG_ENTIDAD_CUENTA.find { | config | config[:key] == cuenta.configuracion_entidad_cuenta.key && config[:entidad] == cuenta.configuracion_entidad_cuenta.entidad }.with_indifferent_access

        cuentas.push({
          id:                       cuenta.id,
          descripcion_cuenta:       "#{ConfigEntidadCuentaCont::Keys.label[:"#{cuenta.key}"]}: #{self.descripcion}",
          descripcion_cuenta_comun: "#{ConfigEntidadCuentaCont::Keys.label[:"#{cuenta.key}"]} común: #{self.descripcion}",
          has_comun:                cuenta.configuracion_entidad_cuenta.has_comun,
          is_control:               config_muck[:is_control]
        })
      end

      params[:tipo_articulo_cuentas_contables] = cuentas

    end

    return res
  end

  # ============================================================================================================================================

end
