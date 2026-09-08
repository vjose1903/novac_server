module ArticuloFiltering
  extend ActiveSupport::Concern

  FULL_ARTICULO_INCLUDES = [
    :tipo_articulo,
    :contenido_articulos,
    { formulas_productos_terminados: { articulo_combo_articulo: [:tipo_articulo, :contenido_articulos] } }
  ]

  LIST_ARTICULO_SERIALIZER_OPTIONS = {
    id: true,
    codigo: true,
    nombre: true,
    medida: true,
    cantidades: true,
    precio_principal: true,
    costo_principal: true,
    tipo_articulo_id: true,
    estado: true
  }

  USABLE_ARTICULO_SERIALIZER_OPTIONS = LIST_ARTICULO_SERIALIZER_OPTIONS.merge(
    existencia: true,
    aviso_existencia: true,
    medida_alerta: true,
    tipo_articulo: true,
    contenido: true,
    contenido_articulos: true,
    is_detallable: true,
    vendido_en: true,
    calcular_saco: true,
    calcular_itbis: true,
    descripcion: true
  )

  FORMULA_ARTICULO_SERIALIZER_OPTIONS = {
    id: true,
    codigo: true,
    nombre: true,
    medida: true,
    contenido: true,
    existencia: true,
    costos: true,
    precio_principal: true,
    costo_principal: true,
    formulas_productos_terminados: true,
    contenido_articulos: true
  }

  ARTICULO_RESPONSE_MODES = {
    "select" => {
      includes: [],
      serializer_options: { id: true, codigo: true, nombre: true },
      historicos: false,
      precargar_combos: false
    },
    "list" => {
      includes: [:tipo_articulo, :contenido_articulos],
      serializer_options: LIST_ARTICULO_SERIALIZER_OPTIONS,
      historicos: true,
      precargar_combos: false
    },
    "usable" => {
      includes: [:tipo_articulo, :contenido_articulos],
      serializer_options: USABLE_ARTICULO_SERIALIZER_OPTIONS,
      historicos: true,
      precargar_combos: false
    },
    "formula" => {
      includes: FULL_ARTICULO_INCLUDES,
      serializer_options: FORMULA_ARTICULO_SERIALIZER_OPTIONS,
      historicos: true,
      precargar_combos: true
    },
    "full" => {
      includes: FULL_ARTICULO_INCLUDES,
      serializer_options: { all: true },
      historicos: true,
      precargar_combos: true
    }
  }

  class_methods do
    def models_includes
      return articulo_mode_config("full")[:includes]
    end

    def models_includes_by_mode(mode)
      return articulo_mode_config(mode)[:includes]
    end

    def filtrarArticulo(params)
      res = Response.new
      Thread.current[:articulos_cache] = {}

      mode_config = articulo_mode_config(params["mode"])
      paginacion = paginacion_articulos(params)
      relation = filtrar_articulo_relation(params)
      relation, total_registros = paginar_articulo_relation(relation, paginacion)
      articulos = cargar_articulos_filtrados(relation, mode_config[:includes])

      return articulos_filtrados_empty_page_response(res, mode_config, total_registros, paginacion) if pagina_articulos_vacia?(articulos, paginacion, total_registros)
      return articulos_filtrados_empty_response(res) if articulos.empty?

      articulos_finales, historicos_map = preparar_articulos_response(articulos, params, mode_config)

      res.set_data(articulos_finales, mode_config[:serializer_options].merge(historicos_map: historicos_map), mode_config[:includes])
      res.set_pagination_metadata(total_registros, paginas_articulos(total_registros, paginacion[:per_page])) if paginacion[:paginado]

      return res
    end

    def filtrar_articulo_relation(params)
      tipo = params["tipo"].presence || "todos"
      is_compra = params["is_compra"].to_s.to_boolean

      relation = Articulo
        .joins(:tipo_articulo)
        .where(articulos: { estado: true })

      relation = aplicar_busqueda_articulo(relation, params)

      return relation.where.not(tipo_articulos: { codigo: TipoArticulos.producto_terminado }).where.not(tipo_articulos: { tipo: TipoArticuloType.servicio }).order("articulos.id ASC") if is_compra
      return relation.order("articulos.id ASC") if tipo == "todos"
      return relation.where("(tipo_articulos.codigo = ? OR articulos.is_materia_prima = ?)", tipo, true).order("articulos.id ASC") if tipo == TipoArticulos.materia_prima

      relation.where(tipo_articulos: { codigo: tipo }).order("articulos.id ASC")
    end

    def aplicar_busqueda_articulo(relation, params)
      return relation.where(articulos: { codigo: params["arg"].to_s.strip }) if params["match"] == "exact"

      arg = ActiveRecord::Base.sanitize_sql_like(params["arg"].to_s.strip)
      relation.where(
        "lower(coalesce(tipo_articulos.descripcion, '') || ' ' || coalesce(articulos.nombre, '') || ' ' || coalesce(articulos.codigo, '')) LIKE lower(?)",
        "%#{arg}%"
      )
    end

    def articulos_filtrados_empty_response(res)
      cantidad_registros = Articulo.where({ estado: true }).count
      res.add_msg(cantidad_registros == 0 ? "No existen articulos registrados." : "No existen articulos con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
      res
    end

    def articulos_filtrados_empty_page_response(res, mode_config, total_registros, paginacion)
      res.set_data([], mode_config[:serializer_options].merge(historicos_map: {}))
      res.set_pagination_metadata(total_registros, paginas_articulos(total_registros, paginacion[:per_page]))
      res
    end

    def paginar_articulo_relation(relation, paginacion)
      return [relation.limit(paginacion[:per_page]), nil] if paginacion[:limitado] && !paginacion[:paginado]
      return [relation, nil] unless paginacion[:paginado]

      total_registros = relation.unscope(:order).distinct.count("articulos.id")
      relation = relation.offset(paginacion[:offset]).limit(paginacion[:per_page])

      [relation, total_registros]
    end

    def cargar_articulos_filtrados(relation, includes)
      return relation.to_a if includes.empty?

      relation.preload(includes).to_a
    end

    def pagina_articulos_vacia?(articulos, paginacion, total_registros)
      articulos.empty? && paginacion[:paginado] && total_registros.to_i > 0
    end

    def preparar_articulos_response(articulos, params, mode_config)
      return [articulos, {}] unless mode_config[:historicos]

      articulos_finales, historicos_map = aplicar_historicos_filtrados(articulos, fecha_filtro_articulo(params))
      precargar_articulos_combo(historicos_map.values) if mode_config[:precargar_combos]

      [articulos_finales, historicos_map]
    end

    def aplicar_historicos_filtrados(articulos, fecha)
      articulos_data = articulos.map do |articulo|
        fecha_ultima_edicion = calculateDateUTC(articulo.updated_at).slice(0, 17) + "00"
        {
          articulo: articulo,
          id: articulo.id,
          necesita_historico: fecha < fecha_ultima_edicion
        }
      end

      articulos_por_id = articulos_data.index_by { |data| data[:id] }
      ids_para_historicos = articulos_data.select { |data| data[:necesita_historico] }.map { |data| data[:id] }
      historicos = historicos_filtrados_por_id(fecha, ids_para_historicos, articulos_por_id)

      articulos_finales = []
      historicos_map = {}

      articulos_data.each do |data|
        historico = historicos[data[:id]]
        articulo_final = historico ? Articulo.new(historico) : data[:articulo]

        articulos_finales << articulo_final
        historicos_map[data[:id]] = historico || data[:articulo]
      end

      [articulos_finales, historicos_map]
    end

    def historicos_filtrados_por_id(fecha, articulo_ids, articulos_por_id)
      return {} if articulo_ids.empty?

      MantenimientoArticulo.get_multiple_historicos_by_date(fecha, articulo_ids).each_with_object({}) do |hist, historicos|
        articulo_original = articulos_por_id[hist.articulo_id]&.dig(:articulo)
        next unless articulo_original

        historicos[hist.articulo_id] = MantenimientoArticulo.crearArticuloHistorico(hist, articulo_original)
      end
    end

    def fecha_filtro_articulo(params)
      fecha = params["fecha"].presence || Time.current.strftime("%Y-%m-%d %H:%M")
      "#{fecha}:00"
    end

    def paginacion_articulos(params)
      paginado = params["paginado"].to_s.to_boolean
      page = params["page"].to_i
      per_page = params["limit"].presence || params["per_page"]
      per_page = per_page.to_i

      page = 1 if page <= 0
      per_page = 1 if per_page <= 0

      {
        paginado: paginado,
        limitado: params["limit"].present?,
        page: page,
        per_page: per_page,
        offset: (page - 1) * per_page
      }
    end

    def paginas_articulos(total_registros, per_page)
      (total_registros.to_f / per_page.to_f).ceil
    end

    def articulo_mode_config(mode)
      ArticuloFiltering::ARTICULO_RESPONSE_MODES[mode.to_s].presence || ArticuloFiltering::ARTICULO_RESPONSE_MODES["full"]
    end

    def precargar_articulos_combo(articulos)
      combo_ids = articulos.flat_map do |articulo|
        formulas_articulo(articulo).map { |formula| formula.respond_to?(:articulo_combo) ? formula.articulo_combo : formula["articulo_combo"] || formula[:articulo_combo] }
      end.compact.uniq

      return if combo_ids.empty?

      Thread.current[:articulos_cache] ||= {}
      Articulo.where(id: combo_ids).preload(:tipo_articulo, :contenido_articulos).each do |articulo|
        Thread.current[:articulos_cache][articulo.id] = articulo
      end
    end

    def formulas_articulo(articulo)
      return articulo.formulas_productos_terminados if articulo.respond_to?(:formulas_productos_terminados)

      articulo["formulas_productos_terminados"] || articulo[:formulas_productos_terminados] || []
    end

    private(
      :filtrar_articulo_relation,
      :aplicar_busqueda_articulo,
      :articulos_filtrados_empty_response,
      :articulos_filtrados_empty_page_response,
      :paginar_articulo_relation,
      :cargar_articulos_filtrados,
      :pagina_articulos_vacia?,
      :preparar_articulos_response,
      :aplicar_historicos_filtrados,
      :historicos_filtrados_por_id,
      :fecha_filtro_articulo,
      :paginacion_articulos,
      :paginas_articulos,
      :articulo_mode_config,
      :precargar_articulos_combo,
      :formulas_articulo
    )
  end
end
