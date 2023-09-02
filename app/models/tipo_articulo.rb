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

  # ============================================================================================================================================

  def self.filtrar( params, parametros_opcionales={} )

    res                   = Response.new
    filter_target         = params[:filter_target]

    tiposArticulos = TipoArticulo
    .where("lower(tipo_articulos.descripcion) like lower('%#{filter_target}%')")
    .order('tipo_articulos.id ASC').to_a

    if tiposArticulos.length > 0
      res.set_data(tiposArticulos, parametros_opcionales)
    else
      res.set_data([])
      cantidad_registros = TipoArticulo.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen categorias registrados.' : 'No existe categoria de articulo con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =========================================================================================================================================================

  def self.create_update_tipo_articulo(params, is_save=false)

    res                                = Response.new

    TipoArticulo.transaction do

      tipo_articulo                    = TipoArticulo.where(:id => params[:id]).first_or_create

      tipo_articulo.descripcion        = params[:descripcion]
      tipo_articulo.tipo               = params[:tipo]
      tipo_articulo.codigo             = tipo_articulo.descripcion.downcase.gsub(" ", "_").strip if params[:id].nil? || !params.has_key?(:id)
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
    res                         = Response.new
    cuentas                     = []

    configs_articulo            = ConfiguracionEntidadCuenta.where({ entidad: ConfigEntidadCuentaCont.articulo })

    configs_articulo.each do | config_articulo |
      config_muck               = G_CONFIG_ENTIDAD_CUENTA.find { | config | config[:key] == config_articulo.key && config[:entidad] == config_articulo.entidad }.with_indifferent_access

      cuenta_contable_per_config_key = self.tipo_articulo_cuentas_contables.find { | cuenta | cuenta[:key] == config_articulo.key }

      descripcion_cuenta             = "#{ConfigEntidadCuentaCont::Keys.label[:"#{config_articulo.key}"]}: #{self.descripcion}"
      descripcion_cuenta_comun       = "#{ConfigEntidadCuentaCont::Keys.label[:"#{config_articulo.key}"]} común: #{self.descripcion}"

      if params[:id].nil? || !params.has_key?(:id) || cuenta_contable_per_config_key.nil?

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

      else

        cuentas.push({
          id:                       cuenta_contable_per_config_key.id,
          descripcion_cuenta:       descripcion_cuenta,
          descripcion_cuenta_comun: descripcion_cuenta_comun,
          has_comun:                cuenta_contable_per_config_key.configuracion_entidad_cuenta.has_comun,
          is_control:               config_muck[:is_control]
        })

      end
    end

    params[:tipo_articulo_cuentas_contables] = cuentas

    return res
  end

  # ============================================================================================================================================

end
