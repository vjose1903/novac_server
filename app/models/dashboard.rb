class Dashboard
  CURRENCY = 'DOP'.freeze
  CHART_COLORS = ['#16a34a', '#2563eb', '#0d9488', '#f59e0b', '#dc2626', '#7c3aed', '#0891b2'].freeze
  SALES_TOTALS = Struct.new(:total_factura, :bruto, :itbis, :descuento, :invoice_count, :average_ticket)

  HERO_BLOCKS = %w[
    executive_summary
  ].freeze

  KPI_SECTION_BLOCKS = %w[
    sales_kpis receivables_kpis cash_kpis inventory_kpis ecf_kpis sequence_kpis
  ].freeze

  CHART_BLOCKS = %w[
    sales_by_period cash_vs_credit_sales invoiced_vs_collected ar_aging monthly_pending_balance
    top_customers top_products sales_by_seller sales_by_category returns_by_product
    credit_vs_debit_notes inventory_in_vs_out ecf_status purchases_by_supplier
    product_cost_evolution top_vehicles_by_trips
  ].freeze

  ALL_BLOCKS = (HERO_BLOCKS + KPI_SECTION_BLOCKS + CHART_BLOCKS).freeze

  def self.build(params)
    new(params).build
  end

  def initialize(params)
    @params = params
  end

  def build
    return date_range_required unless params[:startDate].present? && params[:endDate].present?

    @start_date = Date.parse(params[:startDate]).beginning_of_day
    @end_date = Date.parse(params[:endDate]).end_of_day
    return invalid_date_range if @start_date > @end_date

    requested_blocks = parse_blocks
    invalid_blocks = requested_blocks - ALL_BLOCKS
    return invalid_blocks_response(invalid_blocks) if invalid_blocks.any?

    {
      status: :ok,
      data: {
        startDate: @start_date.to_date.to_s,
        endDate: @end_date.to_date.to_s,
        blocks: params[:blocks].present? ? requested_blocks : 'all',
        requestedBlocks: params[:blocks].present? ? requested_blocks : 'all',
        hero: build_hero(requested_blocks),
        kpiSections: build_kpi_sections(requested_blocks),
        charts: build_charts(requested_blocks)
      }
    }
  rescue ArgumentError
    invalid_date_range
  end

  private

  attr_reader :params, :start_date, :end_date

  def parse_blocks
    blocks = params[:blocks].to_s.split(',').map(&:strip).reject(&:blank?)
    blocks.any? ? blocks : ALL_BLOCKS
  end

  def build_hero(requested_blocks)
    return nil unless requested_blocks.include?('executive_summary')

    executive_summary
  end

  def build_kpi_sections(requested_blocks)
    (requested_blocks & KPI_SECTION_BLOCKS).map { |block| send(block) }
  end

  def build_charts(requested_blocks)
    (requested_blocks & CHART_BLOCKS).map { |block| send(block) }
  end

  def date_range_required
    {
      status: :bad_request,
      error: {
        error: 'DATE_RANGE_REQUIRED',
        message: 'startDate and endDate are required.'
      }
    }
  end

  def invalid_date_range
    {
      status: :bad_request,
      error: {
        error: 'INVALID_DATE_RANGE',
        message: 'startDate must be less than or equal to endDate.'
      }
    }
  end

  def invalid_blocks_response(invalid_blocks)
    {
      status: :bad_request,
      error: {
        error: 'INVALID_DASHBOARD_BLOCK',
        message: 'One or more requested dashboard blocks are not supported.',
        invalidBlocks: invalid_blocks
      }
    }
  end

  def sales_scope
    CabeceraFactura.where(
      fecha_equivalente: start_date..end_date,
      tipo: 'venta',
      estado: true,
      is_nota: false
    )
  end

  def credit_sales_scope
    sales_scope.where(condicion: 'Crédito')
  end

  def receipts_scope
    RecibosIngreso.where(fecha_equivalente: start_date..end_date, estado: true)
  end

  def notes_scope
    Nota.where(fecha_equivalente: start_date..end_date, estado: true)
  end

  def active_articles_scope
    Articulo.where(estado: true)
  end

  def sales_details_scope
    DetalleFactura.joins(:cabecera_factura)
                  .where(cabecera_facturas: {
                    fecha_equivalente: start_date..end_date,
                    tipo: 'venta',
                    estado: true,
                    is_nota: false
                  })
  end

  def sales_records
    @sales_records ||= sales_scope.includes(:cliente).to_a
  end

  def credit_sales_records
    @credit_sales_records ||= sales_records.select { |factura| factura.condicion == 'Crédito' }
  end

  def sales_detail_records
    @sales_detail_records ||= sales_details_scope.includes(articulo: :tipo_articulo).to_a
  end

  def receipt_rows
    @receipt_rows ||= receipts_scope.pluck(:fecha_equivalente, :total)
  end

  def note_rows
    @note_rows ||= notes_scope.pluck(:fecha_equivalente, :tipo_factura_id, :total)
  end

  def active_article_rows
    @active_article_rows ||= active_articles_scope.pluck(:existencia, :costo_principal, :aviso_existencia)
  end

  def period_format
    days = (end_date.to_date - start_date.to_date).to_i
    days <= 45 ? 'YYYY-MM-DD' : 'YYYY-MM'
  end

  def period_key(value)
    date = value.to_date
    period_format == 'YYYY-MM-DD' ? date.to_s : date.strftime('%Y-%m')
  end

  def sum_by_period(rows)
    rows.each_with_object(Hash.new(0)) do |(fecha, value), memo|
      memo[period_key(fecha)] += value.to_f
    end.sort.to_h
  end

  def ranking_rows(grouped_values)
    grouped_values.sort_by { |_, value| -value.to_f }
                  .first(10)
                  .map { |label, value| { label: label, value: value } }
                  .reverse
  end

  def customer_label(factura)
    return factura.cliente.nombre_completo if factura.cliente.present?
    return factura.NoCliente_nombre if factura.NoCliente_nombre.present?

    'Cliente contado'
  end

  def vehicle_label(vehiculo)
    return 'Vehículo' if vehiculo.blank?

    label = [vehiculo.marca, vehiculo.modelo, vehiculo.anio].compact.join(' ').strip
    return label if label.present?

    [vehiculo.nombre_no_empleado, vehiculo.apellido_no_empleado].compact.join(' ').strip.presence || 'Vehículo'
  end

  def round(value)
    value.to_f.round(2)
  end

  def applied_filter
    {
      preset: params[:preset].presence || 'custom_range',
      label: "#{start_date.strftime('%d/%m/%Y')} - #{end_date.strftime('%d/%m/%Y')}",
      startDate: start_date.to_date.to_s,
      endDate: end_date.to_date.to_s
    }
  end

  def card(id, title, value, format, subtitle = 'Rango seleccionado')
    response = { id: id, title: title, value: value, format: format, subtitle: subtitle }
    response[:currency] = CURRENCY if format == 'currency'
    response
  end

  def kpi_section(id, eyebrow, title, description, cards)
    {
      id: id,
      eyebrow: eyebrow,
      title: title,
      description: description,
      appliedFilter: applied_filter,
      cards: cards
    }
  end

  def line_chart(id, title, subtitle, legend, labels, data)
    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: 'line',
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'axis' },
        legend: { data: [legend] },
        xAxis: { type: 'category', data: labels },
        yAxis: { type: 'value' },
        series: [{ name: legend, type: 'line', smooth: true, emphasis: { focus: 'series' }, data: data }]
      }
    }
  end

  def area_line_chart(id, title, subtitle, legend, labels, data)
    chart = line_chart(id, title, subtitle, legend, labels, data)
    chart[:type] = 'area-line'
    chart[:option][:series].each { |series| series[:areaStyle] = {} }
    chart
  end

  def multi_line_chart(id, title, subtitle, legends, labels, series_data, metadata_type = 'line')
    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: metadata_type,
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'axis' },
        legend: { data: legends },
        xAxis: { type: 'category', data: labels },
        yAxis: { type: 'value' },
        series: legends.map do |legend|
          series = { name: legend, type: 'line', smooth: true, emphasis: { focus: 'series' }, data: series_data[legend] || [] }
          series[:areaStyle] = {} if metadata_type == 'area-line'
          series
        end
      }
    }
  end

  def stacked_bar_chart(id, title, subtitle, legends, labels, series_data)
    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: 'stacked-bar',
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'axis' },
        legend: { data: legends },
        xAxis: { type: 'category', data: labels },
        yAxis: { type: 'value' },
        series: legends.map do |legend|
          { name: legend, type: 'bar', stack: 'notas', emphasis: { focus: 'series' }, data: series_data[legend] || [] }
        end
      }
    }
  end

  def ranking_chart(id, title, subtitle, legend, rows)
    labels = rows.map { |row| row[:label] }
    data = rows.map { |row| round(row[:value]) }

    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: 'ranking-bar',
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'value' },
        yAxis: { type: 'category', data: labels },
        series: [{ name: legend, type: 'bar', emphasis: { focus: 'series' }, data: data }]
      }
    }
  end

  def bar_chart(id, title, subtitle, legend, labels, data)
    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: 'bar',
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: labels },
        yAxis: { type: 'value' },
        series: [{ name: legend, type: 'bar', emphasis: { focus: 'series' }, data: data }]
      }
    }
  end

  def pie_chart(id, title, subtitle, legend, rows, metadata_type = 'pie', rose_type = nil)
    data = rows.reject { |row| row[:value].to_f.zero? }
               .map { |row| { name: row[:label], value: round(row[:value]) } }
    radius = metadata_type == 'doughnut' ? ['48%', '72%'] : '68%'
    series = {
      name: legend,
      type: 'pie',
      radius: radius,
      avoidLabelOverlap: true,
      emphasis: { scale: true, scaleSize: 8 },
      data: data
    }
    series[:roseType] = rose_type if rose_type.present?

    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: metadata_type,
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
        legend: { bottom: 0 },
        series: [series]
      }
    }
  end

  def doughnut_chart(id, title, subtitle, legend, rows)
    pie_chart(id, title, subtitle, legend, rows, 'doughnut')
  end

  def treemap_chart(id, title, subtitle, legend, rows)
    data = rows.reject { |row| row[:value].to_f.zero? }
               .map { |row| { name: row[:label], value: round(row[:value]) } }

    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: 'treemap',
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'item' },
        series: [
          {
            name: legend,
            type: 'treemap',
            roam: false,
            breadcrumb: { show: false },
            emphasis: { focus: 'self' },
            data: data
          }
        ]
      }
    }
  end

  def funnel_chart(id, title, subtitle, legend, rows)
    data = rows.reject { |row| row[:value].to_f.zero? }
               .sort_by { |row| -row[:value].to_f }
               .map { |row| { name: row[:label], value: round(row[:value]) } }

    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: 'funnel',
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'item' },
        legend: { bottom: 0 },
        series: [
          {
            name: legend,
            type: 'funnel',
            sort: 'descending',
            emphasis: { focus: 'self' },
            data: data
          }
        ]
      }
    }
  end

  def radar_chart(id, title, subtitle, legend, rows)
    max_value = rows.map { |row| row[:value].to_f }.max.to_f
    max_value = 1 if max_value <= 0

    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: 'radar',
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'item' },
        legend: { data: [legend], bottom: 0 },
        radar: {
          indicator: rows.map { |row| { name: row[:label], max: round(max_value) } }
        },
        series: [
          {
            name: legend,
            type: 'radar',
            areaStyle: {},
            emphasis: { focus: 'series' },
            data: [{ value: rows.map { |row| round(row[:value]) }, name: legend }]
          }
        ]
      }
    }
  end

  def gauge_chart(id, title, subtitle, legend, value, tooltip_detail = nil)
    data = value.nil? ? [] : [{ value: round(value), name: legend }]

    {
      id: id,
      title: title,
      subtitle: subtitle,
      type: 'gauge',
      appliedFilter: applied_filter,
      option: {
        color: CHART_COLORS,
        animation: true,
        tooltip: { trigger: 'item', formatter: tooltip_detail || '{a}: {c}%' },
        series: [
          {
            name: legend,
            type: 'gauge',
            progress: { show: true },
            emphasis: { focus: 'self' },
            detail: { formatter: '{value}%' },
            data: data
          }
        ]
      }
    }
  end

  def sales_totals
    @sales_totals ||= begin
      total_factura = sales_records.sum { |factura| factura.total_factura.to_f }
      invoice_count = sales_records.length

      SALES_TOTALS.new(
        total_factura,
        sales_records.sum { |factura| factura.Bruto.to_f },
        sales_records.sum { |factura| factura.itbis.to_f },
        sales_records.sum { |factura| factura.descuento.to_f },
        invoice_count,
        invoice_count.zero? ? 0 : total_factura / invoice_count
      )
    end
  end

  def returns_amount
    @returns_amount ||= FacturaAplicada.joins(:nota)
                                      .where(notas: { fecha_equivalente: start_date..end_date, estado: true })
                                      .where(tipo_factura_id: credit_note_type_ids)
                                      .sum(:total)
  end

  def credit_note_type_ids
    [TiposNotasId.credito, TiposNotasId.credito_electronica].compact
  end

  def debit_note_type_ids
    [TiposNotasId.debito, TiposNotasId.debito_electronica].compact
  end

  def executive_summary
    {
      id: 'executive_summary',
      title: 'Vista general del negocio',
      subtitle: 'Resumen de facturación, cobranza, inventario y operación.',
      appliedFilter: applied_filter,
      primaryKpis: [
        total_invoiced,
        accounts_receivable_total,
        daily_cash_total,
        inventory_cost_value
      ],
      focusItems: [
        overdue_invoice_count,
        low_stock_products_count,
        ecf_errors_count
      ]
    }
  end

  def sales_kpis
    kpi_section(
      'sales_kpis',
      'Facturación',
      'Indicadores rápidos de ventas',
      'Resumen de facturación, impuestos, descuentos y volumen de facturas.',
      [
        total_invoiced,
        gross_total,
        itbis_total,
        discount_total,
        returns_total,
        estimated_margin,
        average_ticket,
        invoice_count
      ]
    )
  end

  def receivables_kpis
    kpi_section(
      'receivables_kpis',
      'Cobranza',
      'Indicadores de cuentas por cobrar',
      'Balance pendiente y facturas vencidas dentro del rango seleccionado.',
      [
        accounts_receivable_total,
        overdue_invoice_count
      ]
    )
  end

  def cash_kpis
    kpi_section(
      'cash_kpis',
      'Caja',
      'Indicadores de caja',
      'Totales registrados en cuadre de caja para el rango seleccionado.',
      [
        daily_cash_total
      ]
    )
  end

  def inventory_kpis
    kpi_section(
      'inventory_kpis',
      'Inventario',
      'Indicadores de inventario',
      'Valor actual de inventario y productos bajo alerta de existencia.',
      [
        inventory_cost_value,
        low_stock_products_count
      ]
    )
  end

  def ecf_kpis
    kpi_section(
      'ecf_kpis',
      'DGII',
      'Indicadores de facturación electrónica',
      'Facturas electrónicas rechazadas o pendientes de aceptación.',
      [
        ecf_errors_count
      ]
    )
  end

  def sequence_kpis
    kpi_section(
      'sequence_kpis',
      'Comprobantes',
      'Indicadores de secuencias',
      'Disponibilidad actual de secuencias y comprobantes.',
      [
        available_sequences_count
      ]
    )
  end

  def total_invoiced
    card('total_invoiced', 'Total facturado', round(sales_totals.total_factura), 'currency')
  end

  def gross_total
    card('gross_total', 'Total bruto', round(sales_totals.bruto), 'currency')
  end

  def itbis_total
    card('itbis_total', 'Total ITBIS', round(sales_totals.itbis), 'currency')
  end

  def discount_total
    card('discount_total', 'Total descuentos', round(sales_totals.descuento), 'currency')
  end

  def returns_total
    card('returns_total', 'Total devoluciones', round(returns_amount), 'currency')
  end

  def estimated_margin
    margin = sales_detail_records.sum do |detalle|
      detalle.total.to_f - (detalle.costo.to_f * (detalle.cantidad_en_unidades || detalle.cantidad).to_f)
    end

    card('estimated_margin', 'Margen estimado', round(margin), 'currency', 'Ventas menos costo')
  end

  def average_ticket
    card('average_ticket', 'Ticket promedio', round(sales_totals.average_ticket), 'currency')
  end

  def invoice_count
    card('invoice_count', 'Facturas emitidas', sales_totals.invoice_count.to_i, 'number')
  end

  def accounts_receivable_total
    total = credit_sales_records.sum { |factura| factura.pagada == false ? factura.balance.to_f : 0 }
    card('accounts_receivable_total', 'Cuentas por cobrar', round(total), 'currency')
  end

  def overdue_invoice_count
    count = credit_sales_records.count do |factura|
      factura.pagada == false && factura.fecha_vencimiento.present? && factura.fecha_vencimiento < Date.current.beginning_of_day
    end
    card('overdue_invoice_count', 'Facturas vencidas', count, 'number')
  end

  def daily_cash_total
    total = CuadreCaja.where(fecha_equivalente: start_date..end_date).sum(:total_general)
    card('daily_cash_total', 'Caja diaria', round(total), 'currency')
  end

  def inventory_cost_value
    total = active_article_rows.sum { |existencia, costo, _| existencia.to_f * costo.to_f }
    card('inventory_cost_value', 'Inventario a costo', round(total), 'currency', 'Inventario actual')
  end

  def low_stock_products_count
    count = active_article_rows.count { |existencia, _, aviso| existencia.to_f <= aviso.to_f }
    card('low_stock_products_count', 'Productos bajo alerta', count, 'number', 'Inventario actual')
  end

  def ecf_errors_count
    count = sales_records.count do |factura|
      factura.serie == SerieFactura.electronica && (factura.is_aceptada.blank? || factura.is_aceptada.downcase == 'rechazado')
    end
    card('ecf_errors_count', 'Errores e-CF', count, 'number')
  end

  def available_sequences_count
    count = SecuenciaComprobante.where(estado: true)
                                .where(usado: [false, nil])
                                .pluck(:hasta, :secuencia, :desde)
                                .sum { |hasta, secuencia, desde| [hasta.to_i - (secuencia || desde).to_i, 0].max }
    card('available_sequences_count', 'Secuencias disponibles', count.to_i, 'number', 'Estado actual')
  end

  def sales_by_period
    rows = sum_by_period(sales_records.map { |factura| [factura.fecha_equivalente, factura.total_factura] })
    area_line_chart('sales_by_period', 'Ventas por período', 'Evolución de ventas dentro del rango seleccionado.', 'Ventas', rows.keys, rows.values.map { |value| round(value) })
  end

  def cash_vs_credit_sales
    rows = sales_records.each_with_object(Hash.new(0)) do |factura, memo|
      memo[[period_key(factura.fecha_equivalente), factura.condicion]] += factura.total_factura.to_f
    end
    chart_rows = ['Contado', 'Crédito'].map do |condicion|
      { label: condicion, value: rows.sum { |(_, current_condicion), total| current_condicion == condicion ? total : 0 } }
    end

    doughnut_chart('cash_vs_credit_sales', 'Contado vs crédito', 'Composición de ventas por condición de pago.', 'Ventas', chart_rows)
  end

  def invoiced_vs_collected
    invoiced_total = sales_totals.total_factura.to_f
    collected_total = receipt_rows.sum { |_, total| total.to_f }
    percentage = invoiced_total.zero? ? nil : (collected_total / invoiced_total) * 100
    tooltip = "Cobrado: {c}%<br/>Facturado: RD$ #{round(invoiced_total)}<br/>Cobrado: RD$ #{round(collected_total)}"

    gauge_chart('invoiced_vs_collected', 'Cobrado vs facturado', 'Porcentaje cobrado del monto facturado en el período.', 'Cobrado', percentage, tooltip)
  end

  def ar_aging
    labels = ['0-30', '31-60', '61-90', '90+']
    data = [
      ar_aging_sum(0, 30),
      ar_aging_sum(31, 60),
      ar_aging_sum(61, 90),
      ar_aging_sum(91, nil)
    ].map { |value| round(value) }

    labels = [] if data.all?(&:zero?)
    data = [] if data.all?(&:zero?)

    bar_chart('ar_aging', 'CxC por antigüedad', 'Distribución del balance pendiente por días transcurridos.', 'Balance', labels, data)
  end

  def ar_aging_sum(min_days, max_days)
    credit_sales_records.sum do |factura|
      balance = factura.balance.to_f
      next 0 if factura.pagada != false || balance < 1

      days = (Date.current - factura.fecha_equivalente.to_date).to_i
      next 0 if days < min_days
      next 0 if max_days && days > max_days

      balance
    end
  end

  def monthly_pending_balance
    rows = sum_by_period(credit_sales_records.select { |factura| factura.pagada == false }.map { |factura| [factura.fecha_equivalente, factura.balance] })
    line_chart('monthly_pending_balance', 'Balance pendiente mensual', 'Evolución mensual de cuentas por cobrar.', 'Balance', rows.keys, rows.values.map { |value| round(value) })
  end

  def top_customers
    grouped = sales_records.each_with_object(Hash.new(0)) do |factura, memo|
      memo[customer_label(factura)] += factura.total_factura.to_f
    end
    rows = ranking_rows(grouped)

    treemap_chart('top_customers', 'Top 10 clientes', 'Clientes con mayor volumen de ventas en el período.', 'Ventas', rows)
  end

  def top_products
    grouped = sales_detail_records.each_with_object(Hash.new(0)) do |detalle, memo|
      memo[detalle.articulo&.nombre || 'Producto'] += detalle.total.to_f
    end
    rows = ranking_rows(grouped)

    pie_chart('top_products', 'Top 10 productos', 'Productos con mayor volumen de ventas en el período.', 'Ventas', rows, 'pie', 'radius')
  end

  def sales_by_seller
    seller_ids = sales_records.map(&:vendedor_id).compact.uniq
    seller_names = User.where(id: seller_ids)
                       .index_by(&:id)
    grouped = sales_records.each_with_object(Hash.new(0)) do |factura, memo|
      seller = seller_names[factura.vendedor_id]
      memo[seller ? seller.nombre_completo : 'Sin vendedor'] += factura.total_factura.to_f
    end
    rows = ranking_rows(grouped)

    ranking_chart('sales_by_seller', 'Ventas por vendedor', 'Vendedores con mayor volumen de ventas en el período.', 'Ventas', rows)
  end

  def sales_by_category
    rows = sales_detail_records.each_with_object(Hash.new(0)) do |detalle, memo|
      memo[detalle.articulo&.tipo_articulo&.descripcion || 'Sin categoría'] += detalle.total.to_f
    end
    chart_rows = rows.map { |label, value| { label: label, value: value } }

    doughnut_chart('sales_by_category', 'Ventas por categoría', 'Distribución de ventas por tipo de artículo.', 'Ventas', chart_rows)
  end

  def returns_by_product
    grouped = DetalleFacturaNota.includes(:articulo).joins(factura_aplicada: :nota)
                                .where(tipo_factura_id: credit_note_type_ids)
                                .where(notas: { fecha_equivalente: start_date..end_date, estado: true })
                                .each_with_object(Hash.new(0)) do |detalle, memo|
                                  memo[detalle.articulo&.nombre || 'Producto'] += detalle.total.to_f.abs
                                end
    rows = ranking_rows(grouped)

    funnel_chart('returns_by_product', 'Productos con devolución', 'Productos con mayor monto devuelto por notas de crédito.', 'Devoluciones', rows.reverse)
  end

  def credit_vs_debit_notes
    rows = note_rows.each_with_object(Hash.new(0)) do |(fecha, tipo_factura_id, total), memo|
      memo[[period_key(fecha), tipo_factura_id]] += total.to_f
    end
    labels = rows.keys.map(&:first).uniq.sort
    data = {
      'Crédito' => labels.map { |label| round(credit_note_type_ids.sum { |id| rows[[label, id]] || 0 }.abs) },
      'Débito' => labels.map { |label| round(debit_note_type_ids.sum { |id| rows[[label, id]] || 0 }.abs) }
    }

    stacked_bar_chart('credit_vs_debit_notes', 'Notas crédito vs débito', 'Comparación de notas por tipo en el período.', ['Crédito', 'Débito'], labels, data)
  end

  def inventory_in_vs_out
    rows = MovimientosInventario.where(created_at: start_date..end_date)
                                .pluck(:created_at, :accion, :cantidad_en_unidades)
                                .each_with_object(Hash.new(0)) do |(fecha, accion, cantidad), memo|
                                  memo[[period_key(fecha), accion]] += cantidad.to_f
                                end
    labels = rows.keys.map(&:first).uniq.sort
    legends = ['Entrada', 'Salida']
    data = {
      'Entrada' => labels.map { |label| round(rows[[label, 'entrada']] || rows[[label, 'Entrada']] || 0) },
      'Salida' => labels.map { |label| round(rows[[label, 'salida']] || rows[[label, 'Salida']] || 0) }
    }

    multi_line_chart('inventory_in_vs_out', 'Inventario entradas vs salidas', 'Movimientos de inventario por período.', legends, labels, data, 'area-line')
  end

  def ecf_status
    rows = sales_records.select { |factura| factura.serie == SerieFactura.electronica }
                        .each_with_object(Hash.new(0)) do |factura, memo|
                          memo[[period_key(factura.fecha_equivalente), factura.is_aceptada]] += 1
                        end
    labels = rows.keys.map(&:first).uniq.sort
    data = {
      'Enviados' => labels.map { |label| rows.select { |(period, _), _| period == label }.values.sum },
      'Aceptados' => labels.map { |label| rows[[label, 'Aceptado']] || 0 },
      'Rechazados' => labels.map { |label| rows[[label, 'Rechazado']] || 0 },
      'Error' => labels.map { |label| rows[[label, nil]] || 0 }
    }
    chart_rows = data.map { |label, values| { label: label, value: values.sum } }.reject { |row| row[:value].zero? }

    pie_chart('ecf_status', 'Estado e-CF', 'Facturas electrónicas enviadas, aceptadas y rechazadas.', 'e-CF', chart_rows)
  end

  def purchases_by_supplier
    grouped = CabeceraFactura.includes(:suplidor)
                             .where(fecha_equivalente: start_date..end_date, tipo: 'compra', estado: true)
                             .each_with_object(Hash.new(0)) do |factura, memo|
                               memo[factura.suplidor&.nombre_completo || 'Sin suplidor'] += factura.total_factura.to_f
                             end
    rows = ranking_rows(grouped)

    treemap_chart('purchases_by_supplier', 'Compras por suplidor', 'Suplidores con mayor monto comprado en el período.', 'Compras', rows)
  end

  def product_cost_evolution
    rows = MantenimientoArticulo.includes(:articulo)
                                 .where(created_at: start_date..end_date)
                                 .each_with_object(Hash.new { |memo, key| memo[key] = [] }) do |hist, memo|
                                   memo[hist.articulo&.nombre || 'Producto'] << [period_key(hist.created_at), hist.ant_costoP.to_f]
                                 end
    top_products = rows.map { |name, values| [name, values.length] }.sort_by { |_, count| -count }.first(5).map(&:first)
    labels = top_products.flat_map { |name| rows[name].map(&:first) }.uniq.sort
    series_data = top_products.each_with_object({}) do |name, memo|
      grouped_values = rows[name].group_by(&:first)
      memo[name] = labels.map do |label|
        values = grouped_values[label]&.map(&:last) || []
        values.empty? ? 0 : round(values.sum / values.length)
      end
    end

    multi_line_chart('product_cost_evolution', 'Costo por producto', 'Costo promedio registrado en mantenimientos de artículos.', top_products, labels, series_data)
  end

  def top_vehicles_by_trips
    grouped = MovimientoViaje.includes(:vehiculo)
                             .joins(:cabecera_factura)
                             .where(cabecera_facturas: { fecha_equivalente: start_date..end_date, tipo: 'venta', estado: true, is_nota: false })
                             .each_with_object(Hash.new(0)) do |movimiento, memo|
                               memo[vehicle_label(movimiento.vehiculo)] += 1
                             end
    rows = ranking_rows(grouped)

    ranking_chart('top_vehicles_by_trips', 'Vehículos con más viajes', 'Vehículos con mayor cantidad de viajes facturados.', 'Viajes', rows)
  end
end
