class SubTipoArticulo < ApplicationRecord
  belongs_to :tipo_articulo
  has_many   :entidad_cuentas_contables,       :as => :origen_categoria, class_name: 'EntidadCuentaContable'
  has_many   :tipo_articulo_cuentas_contables, :as => :origen_tipo,      class_name: 'TipoArticuloCuentaContable'

  validates :descripcion,                presence: { :message => 'Descripción de la sub categoria no puede estar vacia.' },         uniqueness: { scope: [ :tipo_articulo_id ], case_sensitive: false, :message => "Sub categoria ya está registrada." }

  # ============================================================================================================================================

  def self.filtrar( params, parametros_opcionales={} )

    res                   = Response.new
    filter_target         = has_filter_target(params) ? params[:filter_target] : nil
    tipo_articulo_id      = params.has_key?(:tipo_articulo_id) ? params[:tipo_articulo_id] : nil

    where_                = ""
    where_               += "lower(sub_tipo_articulos.descripcion) like lower('%#{filter_target}%')" unless filter_target.nil?
    where_               += "#{filter_target.nil? ? "" : " AND " }tipo_articulo_id = #{tipo_articulo_id}" unless tipo_articulo_id.nil?

    subTiposArticulos = SubTipoArticulo.where(where_).order('sub_tipo_articulos.id ASC').to_a

    if subTiposArticulos.length > 0
      res.set_data(subTiposArticulos, parametros_opcionales)
    else
      res.set_data([])
      cantidad_registros = tipo_articulo_id.nil? ? SubTipoArticulo.all.count : SubTipoArticulo.where({ tipo_articulo_id: tipo_articulo_id }).count
      res.add_msg(cantidad_registros == 0 ? 'No existen sub categorias registradas.' : 'No existe sub categoria de articulo con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================


  def self.create_update_sub_tipo_articulo( params, tipo_articulo)
    res            = Response.new
    tipo_articulo  = TipoArticulo.find_by_id(params[:tipo_articulo_id])

    unless tipo_articulo.nil?
      SubTipoArticulo.transaction do

        sub_tipo_articulo                    = SubTipoArticulo.where(:id => params[:id]).first_or_create

        sub_tipo_articulo.descripcion        = params[:descripcion]
        sub_tipo_articulo.tipo_articulo_id   = params[:tipo_articulo_id]

        result_procesos                      = sub_tipo_articulo.procesos_parsear_cuentas(params, tipo_articulo)

        sub_tipo_articulo.valid?

        if sub_tipo_articulo.errors.empty? && result_procesos.status_valid

          dependencias = [ { modelo: TipoArticuloCuentaContable,  key_object: 'tipo_articulo_cuentas_contables',   padre: sub_tipo_articulo } ]

          res = crear_actualizar_dependencias(dependencias, params, true) { | key_object, dependencia_data |
            sub_tipo_articulo.tipo_articulo_cuentas_contables  = dependencia_data if key_object == 'tipo_articulo_cuentas_contables'
          }

          if res.status_valid && sub_tipo_articulo.errors.empty? && sub_tipo_articulo.save!
            res.set_data(sub_tipo_articulo)

            action = params[:id] ? 'actualizado' : 'creado'
            res.add_msg("Sub tipo articulo #{action} correctamente.")
          end

        end

        if !sub_tipo_articulo.errors.empty? || !result_procesos.status_valid
          res.add_msgs(result_procesos.get_msgs.to_a)
          res.add_msgs(sub_tipo_articulo.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        transaction_rollback if !sub_tipo_articulo.errors.empty? || !res.status_valid

      end
    else
      res.add_msg('Tipo de articulo, no existe.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end


    return res

  end

  # ============================================================================================================================================

  def procesos_parsear_cuentas(params, tipo_articulo)
    res                           = Response.new
    cuentas                       = []

    configs_articulo              = ConfiguracionEntidadCuenta.where({ entidad: ConfigEntidadCuentaCont.articulo })

    configs_articulo.each do | config_articulo |
      config_muck                 = G_CONFIG_ENTIDAD_CUENTA.find { | config | config[:key] == config_articulo.key && config[:entidad] == config_articulo.entidad }.with_indifferent_access

      if config_muck[:has_comun]
        cuenta_contable_per_config_key = self.tipo_articulo_cuentas_contables.find { | cuenta | cuenta[:key] == config_articulo.key }

        descripcion_cuenta        = "#{ConfigEntidadCuentaCont::Keys.label[:"#{config_articulo.key}"]}: #{self.descripcion}"
        descripcion_cuenta_comun  = "#{ConfigEntidadCuentaCont::Keys.label[:"#{config_articulo.key}"]} común: #{self.descripcion}"

        if params[:id].nil? || !params.has_key?(:id) || cuenta_contable_per_config_key.nil?

            cuenta_contable = tipo_articulo.tipo_articulo_cuentas_contables.find_by_key(config_articulo.key).cuenta_contable_control

            cuentas.push({
              key:                              config_articulo.key,
              entidad:                          config_articulo.entidad,
              descripcion_cuenta:               descripcion_cuenta,
              descripcion_cuenta_comun:         descripcion_cuenta_comun,
              cuenta_contable:                  cuenta_contable,
              configuracion_entidad_cuenta_id:  config_articulo.id,
              is_control:                       config_muck[:is_control],
              has_comun:                        config_muck[:has_comun]
            }.with_indifferent_access)

        else

          cuentas.push({
            id:                       cuenta_contable_per_config_key.id,
            descripcion_cuenta:       descripcion_cuenta,
            descripcion_cuenta_comun: descripcion_cuenta_comun,
            has_comun:                config_muck[:has_comun],
            is_control:               config_muck[:is_control]
          })

        end
      end
    end

    params[:tipo_articulo_cuentas_contables] = cuentas

    return res
  end

# ============================================================================================================================================
end
