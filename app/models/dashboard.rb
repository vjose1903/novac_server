class Dashboard
  CURRENCY = 'DOP'.freeze
  SALES_TOTALS = Struct.new(:total_factura, :bruto, :itbis, :descuento, :invoice_count)

  HERO_BLOCKS = %w[
    executive_summary
  ].freeze

  KPI_SECTION_BLOCKS = %w[
    sales_kpis receivables_kpis
  ].freeze

  CHART_BLOCKS = %w[
    sales_by_period cash_vs_credit_sales invoiced_vs_collected ar_aging monthly_pending_balance
    top_customers top_products sales_by_category returns_by_product
    credit_vs_debit_notes inventory_in_vs_out purchases_by_supplier
    top_vehicles_by_trips
  ].freeze

  ALL_BLOCKS = (HERO_BLOCKS + KPI_SECTION_BLOCKS + CHART_BLOCKS).freeze

  CHART_META = {
    'sales_by_period' => {
      title: 'Ventas por período',
      subtitle: 'Evolución de ventas en el rango seleccionado.',
      empty: 'No hay ventas para este período.',
      error: 'No se pudo calcular las ventas por período.'
    },
    'cash_vs_credit_sales' => {
      title: 'Contado vs crédito',
      subtitle: 'Composición de ventas por condición de pago.',
      empty: 'No hay ventas por condición de pago para este período.',
      error: 'No se pudo calcular las ventas por condición de pago.'
    },
    'invoiced_vs_collected' => {
      title: 'Cobrado vs facturado',
      subtitle: 'Porcentaje cobrado del monto facturado en el período.',
      empty: 'No hay facturas ni cobros para este período.',
      error: 'No se pudo calcular el facturado vs cobrado.'
    },
    'ar_aging' => {
      title: 'CxC por antigüedad',
      subtitle: 'Distribución del balance pendiente por días transcurridos.',
      empty: 'No hay cuentas por cobrar para este período.',
      error: 'No se pudo calcular la antigüedad de cuentas por cobrar.'
    },
    'monthly_pending_balance' => {
      title: 'Balance pendiente mensual',
      subtitle: 'Evolución mensual de cuentas por cobrar.',
      empty: 'No hay balance pendiente para este período.',
      error: 'No se pudo calcular el balance pendiente mensual.'
    },
    'top_customers' => {
      title: 'Top 10 clientes',
      subtitle: 'Clientes con mayor volumen de ventas en el período.',
      empty: 'No hay clientes con ventas en este período.',
      error: 'No se pudo calcular el top de clientes.'
    },
    'top_products' => {
      title: 'Top 10 productos',
      subtitle: 'Productos con mayor volumen de ventas en el período.',
      empty: 'No hay productos vendidos en este período.',
      error: 'No se pudo calcular el top de productos.'
    },
    'sales_by_category' => {
      title: 'Ventas por categoría',
      subtitle: 'Distribución de ventas por tipo de artículo.',
      empty: 'No hay ventas por categoría en este período.',
      error: 'No se pudo calcular las ventas por categoría.'
    },
    'returns_by_product' => {
      title: 'Productos con devolución',
      subtitle: 'Productos con mayor monto devuelto por notas de crédito.',
      empty: 'No hay devoluciones por producto en este período.',
      error: 'No se pudo calcular las devoluciones por producto.'
    },
    'credit_vs_debit_notes' => {
      title: 'Notas crédito vs débito',
      subtitle: 'Comparación de notas por tipo en el período.',
      empty: 'No hay notas de crédito o débito en este período.',
      error: 'No se pudo calcular las notas crédito vs débito.'
    },
    'inventory_in_vs_out' => {
      title: 'Inventario entradas vs salidas',
      subtitle: 'Movimientos de inventario por período.',
      empty: 'No hay movimientos de inventario en este período.',
      error: 'No se pudo calcular entradas y salidas de inventario.'
    },
    'purchases_by_supplier' => {
      title: 'Compras por suplidor',
      subtitle: 'Suplidores con mayor monto comprado en el período.',
      empty: 'No hay compras por suplidor en este período.',
      error: 'No se pudo calcular las compras por suplidor.'
    },
    'top_vehicles_by_trips' => {
      title: 'Vehículos con más viajes',
      subtitle: 'Vehículos con mayor cantidad de viajes facturados.',
      empty: 'No hay viajes facturados en este período.',
      error: 'No se pudo calcular los vehículos con más viajes.'
    }
  }.freeze

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
    (requested_blocks & CHART_BLOCKS).map do |block|
      send(block)
    rescue StandardError => e
      error_chart_block(block, e)
    end
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

  def period_format
    days = (end_date.to_date - start_date.to_date).to_i
    days <= 45 ? 'YYYY-MM-DD' : 'YYYY-MM'
  end

  def period_key(value)
    date = value.to_date
    period_format == 'YYYY-MM-DD' ? date.to_s : date.strftime('%Y-%m')
  end

  def period_label(value)
    value.to_s.length == 7 ? Date.parse("#{value}-01").strftime('%b %Y') : Date.parse(value.to_s).strftime('%d/%m')
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

  def column(key, label, type, format, role, currency = nil)
    response = {
      key: key,
      label: label,
      type: type,
      format: format,
      role: role
    }
    response[:currency] = currency if currency.present?
    response
  end

  def currency_column(key, label, role = 'metric')
    column(key, label, 'number', 'currency', role, CURRENCY)
  end

  def number_column(key, label, role = 'metric')
    column(key, label, 'number', 'number', role)
  end

  def date_column(key, label, role = 'dimension')
    column(key, label, 'date', 'date', role)
  end

  def text_column(key, label, role)
    column(key, label, 'string', 'text', role)
  end

  def percent_column(key, label, role = 'metric')
    column(key, label, 'number', 'percent', role)
  end

  def chart_block(id, columns, rows, summary = nil)
    meta = CHART_META.fetch(id)
    status = rows.present? ? 'success' : 'no-data'

    {
      id: id,
      title: meta[:title],
      subtitle: meta[:subtitle],
      status: status,
      appliedFilter: applied_filter,
      data: {
        columns: status == 'success' ? columns : [],
        rows: status == 'success' ? rows : [],
        summary: status == 'success' ? (summary || summarize_rows(rows, columns)) : {}
      },
      emptyMessage: meta[:empty],
      errorMessage: nil
    }
  end

  def error_chart_block(id, error)
    meta = CHART_META.fetch(id)

    {
      id: id,
      title: meta[:title],
      subtitle: meta[:subtitle],
      status: 'error',
      appliedFilter: applied_filter,
      data: {
        columns: [],
        rows: [],
        summary: {}
      },
      emptyMessage: meta[:empty],
      errorMessage: meta[:error]
    }
  end

  def summarize_rows(rows, columns)
    columns.select { |column| column[:role] == 'metric' && column[:type] == 'number' }
           .each_with_object({}) do |column, memo|
             values = rows.map { |row| row[column[:key].to_sym] }.compact.map(&:to_f)
             next if values.empty?

             memo[column[:key]] = {
               total: round(values.sum),
               count: values.length,
               average: round(values.sum / values.length),
               min: round(values.min),
               max: round(values.max)
             }
           end
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
        invoice_count
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
        accounts_receivable_total
      ],
      focusItems: [
        overdue_invoice_count
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

  def sales_by_period
    grouped = sales_records.each_with_object(Hash.new { |memo, key| memo[key] = { sales_amount: 0, invoice_count: 0 } }) do |factura, memo|
      key = period_key(factura.fecha_equivalente)
      memo[key][:sales_amount] += factura.total_factura.to_f
      memo[key][:invoice_count] += 1
    end
    rows = grouped.sort.map do |period, values|
      {
        period: period,
        periodLabel: period_label(period),
        sales_amount: round(values[:sales_amount]),
        invoice_count: values[:invoice_count]
      }
    end

    chart_block(
      'sales_by_period',
      [
        date_column('period', 'Período'),
        currency_column('sales_amount', 'Ventas'),
        number_column('invoice_count', 'Facturas')
      ],
      rows
    )
  end

  def cash_vs_credit_sales
    grouped = sales_records.each_with_object(Hash.new { |memo, key| memo[key] = { sales_amount: 0, invoice_count: 0 } }) do |factura, memo|
      key = factura.condicion == 'Crédito' ? 'credit' : 'cash'
      memo[key][:sales_amount] += factura.total_factura.to_f
      memo[key][:invoice_count] += 1
    end
    rows = [['cash', 'Contado'], ['credit', 'Crédito']].map do |key, label|
      values = grouped[key]
      next if values[:sales_amount].zero? && values[:invoice_count].zero?

      {
        payment_type: key,
        payment_typeLabel: label,
        sales_amount: round(values[:sales_amount]),
        invoice_count: values[:invoice_count]
      }
    end.compact

    chart_block(
      'cash_vs_credit_sales',
      [
        text_column('payment_type', 'Tipo de pago', 'category'),
        currency_column('sales_amount', 'Ventas'),
        number_column('invoice_count', 'Facturas')
      ],
      rows
    )
  end

  def invoiced_vs_collected
    invoiced_total = sales_totals.total_factura.to_f
    collected_total = receipt_rows.sum { |_, total| total.to_f }
    percentage = invoiced_total.zero? ? 0 : (collected_total / invoiced_total) * 100
    rows = []
    if invoiced_total.positive? || collected_total.positive?
      rows = [
        {
          metric: 'invoiced',
          metricLabel: 'Facturado',
          amount: round(invoiced_total),
          percentage: 100
        },
        {
          metric: 'collected',
          metricLabel: 'Cobrado',
          amount: round(collected_total),
          percentage: round(percentage)
        }
      ]
    end

    chart_block(
      'invoiced_vs_collected',
      [
        text_column('metric', 'Métrica', 'category'),
        currency_column('amount', 'Monto'),
        percent_column('percentage', 'Porcentaje')
      ],
      rows,
      {
        collection_ratio: {
          percentage: round(percentage),
          target: 100
        },
        amount: {
          total: round(invoiced_total + collected_total)
        }
      }
    )
  end

  def ar_aging
    buckets = [
      ['0_30', '0-30', 0, 30],
      ['31_60', '31-60', 31, 60],
      ['61_90', '61-90', 61, 90],
      ['90_plus', '90+', 91, nil]
    ]
    rows = buckets.map do |key, label, min_days, max_days|
      invoices = ar_aging_records(min_days, max_days)
      {
        aging_bucket: key,
        aging_bucketLabel: label,
        pending_amount: round(invoices.sum { |factura| factura.balance.to_f }),
        invoice_count: invoices.length
      }
    end

    chart_block(
      'ar_aging',
      [
        text_column('aging_bucket', 'Antigüedad', 'category'),
        currency_column('pending_amount', 'Balance pendiente'),
        number_column('invoice_count', 'Facturas')
      ],
      rows
    )
  end

  def ar_aging_records(min_days, max_days)
    credit_sales_records.select do |factura|
      balance = factura.balance.to_f
      next false if factura.pagada != false || balance < 1

      days = (Date.current - factura.fecha_equivalente.to_date).to_i
      next false if days < min_days
      next false if max_days && days > max_days

      true
    end
  end

  def monthly_pending_balance
    grouped = credit_sales_records.select { |factura| factura.pagada == false }
                                  .each_with_object(Hash.new(0)) do |factura, memo|
                                    memo[factura.fecha_equivalente.to_date.strftime('%Y-%m')] += factura.balance.to_f
                                  end
    rows = grouped.sort.map do |month, pending_amount|
      {
        month: month,
        monthLabel: period_label(month),
        pending_amount: round(pending_amount)
      }
    end

    chart_block(
      'monthly_pending_balance',
      [
        date_column('month', 'Mes'),
        currency_column('pending_amount', 'Balance pendiente')
      ],
      rows
    )
  end

  def top_customers
    grouped = sales_records.each_with_object({}) do |factura, memo|
      key = factura.cliente_id || "casual_#{factura.NoCliente_nombre.presence || 'cliente_contado'}"
      memo[key] ||= {
        customer_id: factura.cliente_id || 'casual',
        customer_name: customer_label(factura),
        sales_amount: 0,
        invoice_count: 0
      }
      memo[key][:sales_amount] += factura.total_factura.to_f
      memo[key][:invoice_count] += 1
    end
    rows = grouped.values.sort_by { |row| -row[:sales_amount] }.first(10).map do |row|
      row.merge(sales_amount: round(row[:sales_amount]))
    end

    chart_block(
      'top_customers',
      [
        column('customer_id', 'ID cliente', 'string', 'text', 'dimension'),
        text_column('customer_name', 'Cliente', 'category'),
        currency_column('sales_amount', 'Ventas'),
        number_column('invoice_count', 'Facturas')
      ],
      rows
    )
  end

  def top_products
    grouped = sales_detail_records.each_with_object({}) do |detalle, memo|
      product_id = detalle.articulo_id || detalle.articulo&.id || 'unknown'
      memo[product_id] ||= {
        product_id: product_id,
        product_name: detalle.articulo&.nombre || 'Producto',
        sales_amount: 0,
        quantity: 0
      }
      memo[product_id][:sales_amount] += detalle.total.to_f
      memo[product_id][:quantity] += (detalle.cantidad_en_unidades || detalle.cantidad).to_f
    end
    rows = grouped.values.sort_by { |row| -row[:sales_amount] }.first(10).map do |row|
      row.merge(sales_amount: round(row[:sales_amount]), quantity: round(row[:quantity]))
    end

    chart_block(
      'top_products',
      [
        column('product_id', 'ID producto', 'string', 'text', 'dimension'),
        text_column('product_name', 'Producto', 'category'),
        currency_column('sales_amount', 'Ventas'),
        number_column('quantity', 'Cantidad')
      ],
      rows
    )
  end

  def sales_by_category
    grouped = sales_detail_records.each_with_object({}) do |detalle, memo|
      category = detalle.articulo&.tipo_articulo
      category_id = category&.id || 'unknown'
      memo[category_id] ||= {
        category_id: category_id,
        category_name: category&.descripcion || 'Sin categoría',
        sales_amount: 0,
        quantity: 0
      }
      memo[category_id][:sales_amount] += detalle.total.to_f
      memo[category_id][:quantity] += (detalle.cantidad_en_unidades || detalle.cantidad).to_f
    end
    rows = grouped.values.sort_by { |row| -row[:sales_amount] }.map do |row|
      row.merge(sales_amount: round(row[:sales_amount]), quantity: round(row[:quantity]))
    end

    chart_block(
      'sales_by_category',
      [
        column('category_id', 'ID categoría', 'string', 'text', 'dimension'),
        text_column('category_name', 'Categoría', 'category'),
        currency_column('sales_amount', 'Ventas'),
        number_column('quantity', 'Cantidad')
      ],
      rows
    )
  end

  def returns_by_product
    rows = DetalleFacturaNota.joins(:articulo).joins(factura_aplicada: :nota)
                             .where(notas: { fecha_equivalente: start_date..end_date, estado: true, tipo_factura_id: credit_note_type_ids })
                             .group('detalles_facturas_notas.articulo_id', 'articulos.nombre')
                             .order(Arel.sql('coalesce(SUM(ABS(detalles_facturas_notas.total)), 0) DESC'))
                             .limit(10)
                             .pluck(
                               'detalles_facturas_notas.articulo_id',
                               'articulos.nombre',
                               Arel.sql('coalesce(SUM(ABS(detalles_facturas_notas.total)), 0)'),
                               Arel.sql('coalesce(SUM(ABS(coalesce(detalles_facturas_notas.cantidad_en_unidades, detalles_facturas_notas.cantidad, 0))), 0)')
                             )
                             .map do |product_id, product_name, returned_amount, returned_quantity|
      {
        product_id: product_id,
        product_name: product_name.presence || 'Producto',
        returned_amount: round(returned_amount),
        returned_quantity: round(returned_quantity)
      }
    end

    chart_block(
      'returns_by_product',
      [
        column('product_id', 'ID producto', 'string', 'text', 'dimension'),
        text_column('product_name', 'Producto', 'category'),
        currency_column('returned_amount', 'Monto devuelto'),
        number_column('returned_quantity', 'Cantidad devuelta')
      ],
      rows
    )
  end

  def credit_vs_debit_notes
    grouped = note_rows.each_with_object(Hash.new { |memo, key| memo[key] = { credit_note_amount: 0, debit_note_amount: 0, credit_note_count: 0, debit_note_count: 0 } }) do |(fecha, tipo_factura_id, total), memo|
      key = period_key(fecha)
      if credit_note_type_ids.include?(tipo_factura_id)
        memo[key][:credit_note_amount] += total.to_f.abs
        memo[key][:credit_note_count] += 1
      elsif debit_note_type_ids.include?(tipo_factura_id)
        memo[key][:debit_note_amount] += total.to_f.abs
        memo[key][:debit_note_count] += 1
      end
    end
    rows = grouped.sort.map do |period, values|
      {
        period: period,
        periodLabel: period_label(period),
        credit_note_amount: round(values[:credit_note_amount]),
        debit_note_amount: round(values[:debit_note_amount]),
        credit_note_count: values[:credit_note_count],
        debit_note_count: values[:debit_note_count]
      }
    end

    chart_block(
      'credit_vs_debit_notes',
      [
        date_column('period', 'Período'),
        currency_column('credit_note_amount', 'Notas crédito'),
        currency_column('debit_note_amount', 'Notas débito'),
        number_column('credit_note_count', 'Cantidad notas crédito'),
        number_column('debit_note_count', 'Cantidad notas débito')
      ],
      rows
    )
  end

  def inventory_in_vs_out
    grouped = MovimientosInventario.where(created_at: start_date..end_date)
                                   .pluck(:created_at, :accion, :cantidad_en_unidades)
                                   .each_with_object(Hash.new { |memo, key| memo[key] = { inventory_in: 0, inventory_out: 0 } }) do |(fecha, accion, cantidad), memo|
                                     key = period_key(fecha)
                                     if accion.to_s.downcase == 'entrada'
                                       memo[key][:inventory_in] += cantidad.to_f
                                     elsif accion.to_s.downcase == 'salida'
                                       memo[key][:inventory_out] += cantidad.to_f
                                     end
                                   end
    rows = grouped.sort.map do |period, values|
      {
        period: period,
        periodLabel: period_label(period),
        inventory_in: round(values[:inventory_in]),
        inventory_out: round(values[:inventory_out])
      }
    end

    chart_block(
      'inventory_in_vs_out',
      [
        date_column('period', 'Período'),
        number_column('inventory_in', 'Entradas'),
        number_column('inventory_out', 'Salidas')
      ],
      rows
    )
  end

  def purchases_by_supplier
    grouped = CabeceraFactura.includes(:suplidor)
                             .where(fecha_equivalente: start_date..end_date, tipo: 'compra', estado: true)
                             .each_with_object({}) do |factura, memo|
                               supplier_id = factura.suplidor_id || 'unknown'
                               memo[supplier_id] ||= {
                                 supplier_id: supplier_id,
                                 supplier_name: factura.suplidor&.nombre_completo || 'Sin suplidor',
                                 purchase_amount: 0,
                                 purchase_count: 0
                               }
                               memo[supplier_id][:purchase_amount] += factura.total_factura.to_f
                               memo[supplier_id][:purchase_count] += 1
                             end
    rows = grouped.values.sort_by { |row| -row[:purchase_amount] }.first(10).map do |row|
      row.merge(purchase_amount: round(row[:purchase_amount]))
    end

    chart_block(
      'purchases_by_supplier',
      [
        column('supplier_id', 'ID suplidor', 'string', 'text', 'dimension'),
        text_column('supplier_name', 'Suplidor', 'category'),
        currency_column('purchase_amount', 'Compras'),
        number_column('purchase_count', 'Cantidad compras')
      ],
      rows
    )
  end

  def top_vehicles_by_trips
    grouped = MovimientoViaje.includes(:vehiculo)
                             .joins(:cabecera_factura)
                             .where(cabecera_facturas: { fecha_equivalente: start_date..end_date, tipo: 'venta', estado: true, is_nota: false })
                             .each_with_object({}) do |movimiento, memo|
                               vehicle_id = movimiento.vehiculo_id || movimiento.vehiculo&.id || 'unknown'
                               memo[vehicle_id] ||= {
                                 vehicle_id: vehicle_id,
                                 vehicle_name: vehicle_label(movimiento.vehiculo),
                                 trip_count: 0
                               }
                               memo[vehicle_id][:trip_count] += 1
                             end
    rows = grouped.values.sort_by { |row| -row[:trip_count] }.first(10)

    chart_block(
      'top_vehicles_by_trips',
      [
        column('vehicle_id', 'ID vehículo', 'string', 'text', 'dimension'),
        text_column('vehicle_name', 'Vehículo', 'category'),
        number_column('trip_count', 'Viajes')
      ],
      rows
    )
  end
end
