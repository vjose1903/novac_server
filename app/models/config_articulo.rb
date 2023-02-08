class ConfigArticulo < ApplicationRecord

  # ===================================================================================================================================================

  def self.update_configuracion(params, is_save=false)
    res = Response.new

    ConfigArticulo.transaction do

      configuracion_articulo                       = ConfigArticulo.where(:id => params[:id]).first_or_create
      configuracion_articulo.porciento_ganancia    = params[:porciento_ganancia]

      configuracion_articulo.valid?

      if configuracion_articulo.errors.empty? && (!is_save || (is_save && configuracion_articulo.save!))

        res_valid                         = ConfigArticulo.procesos_articulos(params)

        if res_valid.status_valid
          res.set_data(configuracion_articulo, {all: true})
          res.add_msg("Configuración de articulos editada correctamente.")

        else
          res.add_msgs(res_valid.get_msgs.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
      end

      raise ActiveRecord::Rollback if !configuracion_articulo.errors.empty? || !res.status_valid

    end

    return res
  end

  # ===================================================================================================================================================


  def self.procesos_articulos(params)
    res = Response.new

    if params[:update_articulos]
      resultado = ConfigArticulo.recalcular_precio_articulos('materia_prima', params)

      resultado = ConfigArticulo.recalcular_precio_articulos('producto_terminado', params)
    end

    return res
  end


  # ===================================================================================================================================================

  def self.recalcular_precio_articulos(tipo, params)


    res                     = Response.new

    lista_articulo          = []

    if tipo == 'producto_terminado'
      lista_articulo                 = Articulo.joins(:formulas_productos_terminados).includes([{contenido_articulos: :articulo}, {formulas_productos_terminados: :articulo}]).distinct
    else
      lista_articulo                 = Articulo.left_outer_joins(:formulas_productos_terminados).where(formulas_productos_terminados: { id: nil }).includes([{contenido_articulos: :articulo}, {formulas_productos_terminados: :articulo}])
    end

    lista_articulo.each do | articulo |

      my_print_log( " ")
      my_print_log( "articulo -> ".red + " #{articulo}")
      if articulo.is_combo && articulo.formulas_productos_terminados.length > 0
        costo_en_turno      = 0

        articulo.formulas_productos_terminados.each do | formula |
          unidades_minimas        = [ 'Unidad', 'Libra', 'Onza' ];

          articulo_combo          = Articulo.find_by_id(formula.articulo_combo)
          contenido_minimo        = articulo_combo.contenido_articulos.find { | contenido | unidades_minimas.my_includes_str(contenido.medida) }

          formula.costo           = contenido_minimo.costo
          formula.precio          = contenido_minimo.precio

          formula.save!

          costo_en_turno         += (formula.cantidad * formula.costo)

        end


        costo_en_turno           += articulo.otros_costos
        costo_en_turno            = costo_en_turno.to_d.truncate(2).to_f

        articulo.costo_principal  = costo_en_turno
      end


      new_precio                 = articulo.costo_principal / ( (100 - params[:porciento_ganancia]).to_f / 100 )
			my_print_log( " ")
			my_print_log( "new_precio -> ".green + " #{new_precio}")
      new_precio_rounded         = round_to_nearest_multiple_of_5(new_precio)

      articulo.precio_principal  = new_precio_rounded
      articulo.save!


      articulo.contenido_articulos.each do | contenido |
        precio_referencial       = articulo.precio_principal
        costo_referencial        = articulo.costo_principal

        unless contenido.referencia.nil?
          cotenido_referencia    = ContenidoArticulo.find_by_id(contenido.referencia)

          precio_referencial     = cotenido_referencia.precio_principal
          costo_referencial      = cotenido_referencia.costo_principal
        end

        contenido.costo          = costo_referencial / contenido.cantidad
        contenido.precio         = precio_referencial / contenido.cantidad

        contenido.save!
      end

    end

    return res

  end

end
