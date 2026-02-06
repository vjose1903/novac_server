class ConfigArticulo < ApplicationRecord

  # ===================================================================================================================================================

  def self.update_configuracion(params, is_save=false)
    res = Response.new

    ConfigArticulo.transaction do

      configuracion_articulo                       = ConfigArticulo.where(:id => params[:id]).first_or_initialize
      configuracion_articulo.porciento_ganancia    = params[:porciento_ganancia]


      configuracion_articulo.valid?

      if configuracion_articulo.errors.empty? && (!is_save || (is_save && configuracion_articulo.save!))

        res_valid                         = ConfigArticulo.procesos_articulos(params)

        if res_valid.status_valid
          res.set_data(configuracion_articulo, { all: true })
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

    if params[:update_articulos].present? && params[:update_articulos].to_boolean
      # Procesar ambos tipos de artículos de forma eficiente
      ['materia_prima', 'producto_terminado'].each do |tipo|
        ConfigArticulo.recalcular_precio_articulos(tipo, params)
      end
    end

    res
  end


  # ===================================================================================================================================================

  def self.recalcular_precio_articulos(tipo, params)
    res = Response.new

    # Validar parámetros requeridos
    unless params[:porciento_ganancia].present? && params[:porciento_ganancia].to_f > 0
      res.add_msg("El porcentaje de ganancia es requerido y debe ser mayor a 0")
      res.set_status(HTTP_STATUS_CODE[:bad_request])
      return res
    end

    # Optimizar consulta base según el tipo
    lista_articulo = if tipo == 'producto_terminado'
      Articulo.joins(:formulas_productos_terminados)
              .includes([{contenido_articulos: :articulo}, {formulas_productos_terminados: :articulo}])
              .distinct
    else
      Articulo.left_outer_joins(:formulas_productos_terminados)
              .where(formulas_productos_terminados: { id: nil })
              .includes([{contenido_articulos: :articulo}, {formulas_productos_terminados: :articulo}])
    end

    # Precargar todos los artículos combo y contenidos de referencia para evitar consultas N+1
    precargar_datos_relacionados(lista_articulo)

    # Procesar artículos en lotes para mejor rendimiento
    lista_articulo.find_each(batch_size: 100) do |articulo|
      begin
        procesar_articulo(articulo, params)
      rescue => e
        res.add_msg("Error procesando artículo #{articulo.id}: #{e.message}")
        res.set_status(HTTP_STATUS_CODE[:internal_server_error])
      end
    end

    res
  end

  private

  def self.precargar_datos_relacionados(lista_articulo)
    # Obtener todos los IDs de artículos combo únicos
    articulos_combo_ids = []
    contenidos_referencia_ids = []
    
    lista_articulo.each do |articulo|
      articulo.formulas_productos_terminados.each do |formula|
        articulos_combo_ids << formula.articulo_combo if formula.articulo_combo
      end
      
      articulo.contenido_articulos.each do |contenido|
        contenidos_referencia_ids << contenido.referencia if contenido.referencia
      end
    end

    # Precargar artículos combo con sus contenidos
    @articulos_combo_cache = {}
    if articulos_combo_ids.any?
      Articulo.includes(:contenido_articulos)
              .where(id: articulos_combo_ids.uniq)
              .each do |articulo|
        @articulos_combo_cache[articulo.id] = articulo
      end
    end

    # Precargar contenidos de referencia
    @contenidos_referencia_cache = {}
    if contenidos_referencia_ids.any?
      ContenidoArticulo.where(id: contenidos_referencia_ids.uniq)
                      .each do |contenido|
        @contenidos_referencia_cache[contenido.id] = contenido
      end
    end
  end

  def self.procesar_articulo(articulo, params)
    # Procesar combos si es necesario
    if articulo.is_combo && articulo.formulas_productos_terminados.any?
      procesar_articulo_combo(articulo)
    end

    # Calcular nuevo precio
    calcular_nuevo_precio(articulo, params)

    # Actualizar contenidos del artículo
    actualizar_contenidos_articulo(articulo)
  end

  def self.procesar_articulo_combo(articulo)
    costo_en_turno = 0
    unidades_minimas = ['Unidad', 'Libra', 'Onza']

    articulo.formulas_productos_terminados.each do |formula|
      articulo_combo = @articulos_combo_cache[formula.articulo_combo]
      
      unless articulo_combo
        raise "No se encontró el artículo combo con ID: #{formula.articulo_combo}"
      end

      contenido_minimo = articulo_combo.contenido_articulos.find { |contenido| unidades_minimas.my_includes_str(contenido.medida) }
      
      unless contenido_minimo
        raise "No se encontró contenido mínimo para el artículo combo #{articulo_combo.nombre} con medidas: #{unidades_minimas.join(', ')}"
      end

      formula.costo = contenido_minimo.costo
      formula.precio = contenido_minimo.precio
      formula.save!

      costo_en_turno += (formula.cantidad * formula.costo)
    end

    costo_en_turno += (articulo.otros_costos || 0)
    articulo.costo_principal = costo_en_turno.to_d.truncate(2).to_f
  end

  def self.calcular_nuevo_precio(articulo, params)
    # Validar que el artículo tenga costo principal
    unless articulo.costo_principal.present? && articulo.costo_principal > 0
      raise "El artículo #{articulo.nombre} no tiene un costo principal válido"
    end

    factor_ganancia = (100 - params[:porciento_ganancia]).to_f / 100
    new_precio = articulo.costo_principal / factor_ganancia
    articulo.precio_principal = round_to_nearest_multiple_of_5(new_precio)
    articulo.save!
  end

  def self.actualizar_contenidos_articulo(articulo)
    articulo.contenido_articulos.each do |contenido|
      precio_referencial = articulo.precio_principal
      costo_referencial = articulo.costo_principal

      if contenido.referencia.present?
        contenido_referencia = @contenidos_referencia_cache[contenido.referencia]
        
        if contenido_referencia
          precio_referencial = contenido_referencia.precio
          costo_referencial = contenido_referencia.costo
        else
          # Si no encuentra la referencia, usar los valores del artículo principal
          Rails.logger.warn("No se encontró contenido de referencia con ID: #{contenido.referencia}")
        end
      end

      # Validar que la cantidad sea mayor a 0
      unless contenido.cantidad.present? && contenido.cantidad > 0
        raise "El contenido del artículo #{articulo.nombre} no tiene una cantidad válida"
      end

      contenido.costo = costo_referencial / contenido.cantidad
      contenido.precio = precio_referencial / contenido.cantidad
      contenido.save!
    end
  end

end
