class SubTipoArticulo < ApplicationRecord
  belongs_to :tipo_articulo
  has_many   :entidad_cuentas_contables,       :as => :origen_categoria, class_name: 'EntidadCuentaContable'
  has_many   :tipo_articulo_cuentas_contables, :as => :origen_tipo,      class_name: 'TipoArticuloCuentaContable'

  validates :descripcion,                presence: { :message => "Descripción de la sub categoria no puede estar vacia." },         uniqueness: { scope: [ :tipo_articulo_id ], case_sensitive: false, :message => "Sub categoria ya está registrada." }

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
      res.add_msg("Tipo de articulo, no existe.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end


    return res

  end

  # ============================================================================================================================================

  def procesos_parsear_cuentas(params, tipo_articulo)
    res = Response.new

		inicio_descripcion          = { inventario: 'Inventario', ventas: 'Ventas', descuento_ventas: 'Descuento sobre ventas', compras: 'Compras', descuento_compras: 'Descuento sobre compras' }.with_indifferent_access

		if params[:id].nil? || !params[:id].present? || self.tipo_articulo_cuentas_contables.empty?
			cuentas                     = []
			configs_articulo            = ConfiguracionEntidadCuenta.where({ entidad: ConfigEntidadCuentaCont.articulo })

			configs_articulo.each do | config_articulo |

				if G_SUB_TIPO_CONFIG_VALID.my_includes_str( config_articulo.key )
					config_muck               = G_CONFIG_ENTIDAD_CUENTA.find { | config | config[:key] == config_articulo.key && config[:entidad] == config_articulo.entidad }.with_indifferent_access

					descripcion_cuenta        = "#{inicio_descripcion[:"#{config_articulo.key}"]}: #{self.descripcion}"
					descripcion_cuenta_comun  = "#{inicio_descripcion[:"#{config_articulo.key}"]} común: #{self.descripcion}"

					cuenta_contable = tipo_articulo.tipo_articulo_cuentas_contables.find_by_key(config_articulo.key).cuenta_contable_control

					cuentas.push({
						key:                              config_articulo.key,
						entidad:                          config_articulo.entidad,
						descripcion_cuenta:               descripcion_cuenta,
						descripcion_cuenta_comun:         descripcion_cuenta_comun,
						cuenta_contable:                  cuenta_contable,
						configuracion_entidad_cuenta_id:  nil,
						is_control:                       config_muck[:is_control],
						has_comun:                        config_muck[:has_comun]
					}.with_indifferent_access)
				end
			end


			params[:tipo_articulo_cuentas_contables] = cuentas
		else

			cuentas = []

      self.tipo_articulo_cuentas_contables.each do | cuenta |

        config_muck               = G_CONFIG_ENTIDAD_CUENTA.find { | config | config[:key] == cuenta.key && config[:entidad] == cuenta.entidad }.with_indifferent_access

        cuentas.push({
          id:                       cuenta.id,
          descripcion_cuenta:       "#{inicio_descripcion[:"#{cuenta.key}"]}: #{self.descripcion}",
          descripcion_cuenta_comun: "#{inicio_descripcion[:"#{cuenta.key}"]} común: #{self.descripcion}",
          has_comun:                config_muck[:has_comun],
          is_control:               config_muck[:is_control]
        })
      end

			params[:tipo_articulo_cuentas_contables] = cuentas
		end


    return res
  end

# ============================================================================================================================================
end
