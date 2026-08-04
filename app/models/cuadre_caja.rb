class CuadreCaja < ApplicationRecord
  LOCAL_CURRENCY_CODE = 'DOP'.freeze
  STATUSES = %w[draft submitted reviewed approved rejected reopened cancelled].freeze

  belongs_to :user
  belongs_to :prepared_by, class_name: 'User', optional: true
  belongs_to :reviewed_by, class_name: 'User', optional: true
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :submitted_by, class_name: 'User', optional: true
  belongs_to :rejected_by, class_name: 'User', optional: true
  belongs_to :reopened_by, class_name: 'User', optional: true

  has_many :denominaciones, class_name: 'CuadreCajaDenominacion', dependent: :destroy
  has_many :movimientos, class_name: 'CuadreCajaMovimiento', dependent: :destroy
  has_many :eventos, class_name: 'CuadreCajaEvento', dependent: :destroy

  validates :closing_date, presence: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: true
  validate :approved_closing_cannot_change, on: :update

  def self.makecuadre(params)
    return create_detailed_closing(params) if detailed_params?(params)
    prepare_closing(params)
  end

  def self.listado(params)
    relation = CuadreCaja.all
    search = params[:search].to_s.strip

    relation = apply_list_search(relation, search) if search.present?

    relation = relation.order(closing_date: :desc, id: :desc)
    mapped = relation.map { |cuadre| cuadre.listado_item }
    res = Response.new(params)
    res.set_data(mapped)
    res
  end

  def self.system_income_preview(params)
    prepare_closing(params)
  end

  def self.apply_list_search(relation, search)
    table = CuadreCaja.arel_table
    conditions = [table[:status].matches("%#{sanitize_sql_like(search)}%")]

    conditions << table[:id].eq(search.to_i) if search.match?(/\A\d+\z/)

    parsed_date = Date.parse(search) rescue nil
    if parsed_date
      conditions << table[:closing_date].eq(parsed_date)
      conditions << table[:fecha_equivalente].gteq(parsed_date.beginning_of_day)
        .and(table[:fecha_equivalente].lteq(parsed_date.end_of_day))
    end

    relation.where(conditions.reduce { |query, condition| query.or(condition) })
  end

  def self.prepare_closing(params)
    res = Response.new
    closing_date = params[:closing_date] || params[:fecha]

    unless closing_date.present?
      res.set_status(HTTP_STATUS_CODE[:conflict])
      res.add_msg('La fecha del cuadre es obligatoria')
      return res
    end

    closing_date = Date.parse(closing_date.to_s)
    existing_closing = CuadreCaja
      .where("closing_date = ? OR fecha_equivalente::date = ?", closing_date, closing_date)
      .where.not(status: 'cancelled')
      .includes(:user, :denominaciones, :movimientos, :eventos)
      .first

    if existing_closing
      res.set_data({
        exists_cuadre: true,
        source: 'stored',
        closing_date: closing_date,
        is_new_flow: existing_closing.detailed?,
        flow_type: existing_closing.detailed? ? 'new' : 'legacy',
        closing_version: existing_closing.closing_version.presence || 'legacy',
        cuadre: existing_closing.prepare_payload
      })
      return res
    end

    system_income = CuadreCajas::SystemIncomeCalculator.call(closing_date)
    res.set_data({
      exists_cuadre: false,
      source: 'calculated',
      closing_date: closing_date,
      system_income: system_income,
      divisa_principal: principal_currency_payload,
      divisas: available_foreign_currencies_payload(closing_date),
      denominations: empty_denominations_payload,
      movements: empty_movements_payload(system_income),
      totals: initial_totals_payload(system_income)
    })
    res
  end

  def self.create_detailed_closing(params)
    attrs = normalized_params(params)
    res = Response.new
    current_user = get_current_user
    closing_date = attrs[:closing_date] || attrs[:fecha]

    unless closing_date.present?
      res.set_status(HTTP_STATUS_CODE[:conflict])
      res.add_msg('La fecha del cuadre es obligatoria')
      return res
    end

    if CuadreCaja.where(closing_date: Date.parse(closing_date.to_s)).where.not(status: 'cancelled').exists?
      res.set_status(HTTP_STATUS_CODE[:conflict])
      res.add_msg('Ya existe un cuadre para esta fecha')
      return res
    end

    save_detailed_closing(CuadreCaja.new, attrs, current_user, res, 'created')
  rescue ActiveRecord::RecordNotUnique
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res.add_msg('Ya existe un cuadre para esta fecha')
    res
  end

  def self.update_detailed_closing(cuadre_caja, params)
    res = Response.new
    current_user = get_current_user

    if cuadre_caja.approved?
      res.set_status(HTTP_STATUS_CODE[:conflict])
      res.add_msg('No se puede editar un cuadre aprobado')
      return res
    end

    save_detailed_closing(cuadre_caja, normalized_params(params), current_user, res, 'updated')
  end

  def transition_to!(target_status, user, reason=nil)
    res = Response.new
    from_status = status

    invalid_message = transition_error(target_status)
    if invalid_message
      res.set_status(HTTP_STATUS_CODE[:conflict])
      res.add_msg(invalid_message)
      return res
    end

    transaction do
      assign_transition_attributes(target_status, user, reason)
      save!
      eventos.create!(user: user, event_type: target_status, from_status: from_status, to_status: status, reason: reason)
    end

    res.set_data(serialize_parser(self, { all: true }))
    res.add_msg('Estado del cuadre actualizado correctamente')
    res
  end

  def approved?
    status == 'approved'
  end

  def detailed?
    closing_version == 'detailed'
  end

  def listado_item
    closing_day = closing_date || fecha_equivalente&.to_date
    current_status = status.presence || 'approved'
    system_total = amount_string(read_attribute(:system_income_total) || decimal_value(total_venta_contado) + decimal_value(total_recibo_ingreso))
    operational = amount_string(read_attribute(:operational_total) || total_general)
    diff = amount_string(read_attribute(:difference_amount) || BigDecimal(operational) - BigDecimal(system_total))

    {
      id: id,
      closing_date: closing_day,
      fecha: closing_day,
      status: current_status,
      estado: current_status,
      closing_version: closing_version.presence || 'legacy',
      flow_type: detailed? ? 'new' : 'legacy',
      is_new_flow: detailed?,
      system_income_total: system_total,
      operational_total: operational,
      difference: diff,
      total: operational,
      totals: {
        system_income_total: system_total,
        operational_total: operational,
        difference: diff
      }
    }
  end

  def prepare_payload
    return serialize_parser(self, { all: true }) if detailed?

    {
      id: id,
      user_id: user_id,
      usuario: user&.nombre_completo,
      fecha_equivalente: fecha_equivalente,
      closing_date: closing_date || fecha_equivalente&.to_date,
      numero_reporte: numero_reporte,
      reimprimir: true,
      closing_version: closing_version.presence || 'legacy',
      flow_type: 'legacy',
      is_new_flow: false,
      contenido_reporte: [
        { descripcion: 'facturas_contado', titulo: 'Total facturado a contado', valor: amount_string(total_venta_contado) },
        { descripcion: 'recibos_ingresos', titulo: 'Total recibo de ingreso', valor: amount_string(total_recibo_ingreso) },
        { descripcion: 'total_anterior', titulo: 'Total anterior', valor: amount_string(total_anterior) },
        { descripcion: 'total_general', titulo: 'Total en caja', valor: amount_string(total_general) },
        { descripcion: 'facturas_credito', titulo: 'Total facturado a crédito', valor: amount_string(total_venta_credito) },
      ]
    }
  end

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def self.find_numero_reporte
    ultimo_numero = CuadreCaja.last
    siguiente_numero = 1

    if ultimo_numero
      siguiente_numero = ultimo_numero.numero_reporte + 1
    end
    return siguiente_numero
  end

  def find_total_anterior
    ultimo_numero = CuadreCaja.last(:order => "id asc", :limit => 1).numero_reporte
    siguiente_numero = 0

    if ultimo_numero
      siguiente_numero = ultimo_numero + 1
    end
    return siguiente_numero
  end

  def self.detailed_params?(params)
    attrs = normalized_params(params)
    attrs[:denominaciones].present? || attrs[:denominations].present? || attrs[:movimientos].present? || attrs[:movements].present?
  end

  def self.save_detailed_closing(cuadre_caja, attrs, current_user, res, event_type)
    closing_date = Date.parse((attrs[:closing_date] || attrs[:fecha]).to_s)
    tolerance = attrs[:reconciliation_tolerance] || attrs[:tolerancia] || 0
    denominaciones = build_denominaciones(attrs, closing_date)
    movimientos = build_movimientos(attrs)
    system_income = CuadreCajas::SystemIncomeCalculator.call(closing_date)
    totals = CuadreCajas::CalculateTotals.call(
      denominaciones: denominaciones,
      movimientos: movimientos,
      system_income: system_income,
      tolerance: tolerance
    )

    transaction do
      cuadre_caja.lock! if cuadre_caja.persisted?
      cuadre_caja.denominaciones.destroy_all if cuadre_caja.persisted?
      cuadre_caja.movimientos.destroy_all if cuadre_caja.persisted?

      cuadre_caja.assign_attributes({
        user_id: cuadre_caja.user_id || current_user&.id || attrs[:user_id],
        prepared_by_id: cuadre_caja.prepared_by_id || current_user&.id || attrs[:prepared_by_id] || attrs[:user_id],
        closing_date: closing_date,
        fecha_equivalente: closing_date.to_time,
        numero_reporte: cuadre_caja.numero_reporte || find_numero_reporte,
        closing_version: 'detailed',
        source_type: attrs[:source_type] || 'manual',
        currency_code: LOCAL_CURRENCY_CODE,
        notes: attrs[:notes] || attrs[:observaciones],
        status: closing_status(cuadre_caja, attrs)
      }.merge(totals))

      if cuadre_caja.status == 'submitted' && cuadre_caja.submitted_at.nil?
        cuadre_caja.submitted_by = current_user
        cuadre_caja.submitted_at = Time.zone.now
      end

      denominaciones.each { |item| cuadre_caja.denominaciones << item }
      movimientos.each { |item| cuadre_caja.movimientos << item }
      cuadre_caja.total_venta_contado = totals[:final_consumer_invoices_total]
      cuadre_caja.total_recibo_ingreso = totals[:income_receipts_total]
      cuadre_caja.total_general = totals[:operational_total]
      cuadre_caja.total_venta_credito ||= 0
      cuadre_caja.total_anterior ||= 0
      cuadre_caja.save!
      cuadre_caja.eventos.create!(user: current_user, event_type: event_type, to_status: cuadre_caja.status)
    end

    res.set_data(serialize_parser(cuadre_caja.reload, { all: true }))
    res.add_msg('Cuadre guardado correctamente')
    res
  rescue ActiveRecord::RecordInvalid => e
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res.add_msg(e.record.errors.full_messages.join(', '))
    res
  end

  def self.build_denominaciones(attrs, closing_date=nil)
    items = []
    raw_denominations(attrs).each_with_index do |data, index|
      item = CuadreCajaDenominacion.new(
        denomination_type: data[:denomination_type] || data[:tipo] || data[:type],
        divisa_id: data[:divisa_id],
        currency_code: data[:currency_code] || data[:moneda] || data[:currency] || LOCAL_CURRENCY_CODE,
        denomination_value: data[:denomination_value] || data[:denominacion] || data[:valor],
        quantity: data[:quantity] || data[:cantidad] || 0,
        exchange_rate: data[:exchange_rate] || data[:tasa] || data[:tasa_cambio] || 1,
        position: data[:position] || index
      )
      item.closing_date = closing_date
      item.valid?
      items << item
    end
    items
  end

  def self.raw_denominations(attrs)
    data = attrs[:denominaciones] || attrs[:denominations] || []
    return data.map { |item| item.to_h.deep_symbolize_keys } if data.is_a?(Array)

    data.to_h.deep_symbolize_keys.flat_map do |key, values|
      Array(values).map do |item|
        item.to_h.deep_symbolize_keys.merge(denomination_type: denomination_type_from_group(key))
      end
    end
  end

  def self.denomination_type_from_group(key)
    case key.to_s
    when 'bills', 'billetes' then 'bill'
    when 'coins', 'monedas' then 'coin'
    else 'foreign_currency'
    end
  end

  def self.build_movimientos(attrs)
    raw_movements(attrs).each_with_index.map do |data, index|
      CuadreCajaMovimiento.new(
        movement_group: data[:movement_group] || data[:grupo] || data[:group],
        payment_method: data[:payment_method] || data[:metodo_pago] || data[:tipo] || 'other',
        description: data[:description] || data[:descripcion],
        reference: data[:reference] || data[:referencia],
        counterparty_name: data[:counterparty_name] || data[:persona] || data[:entidad],
        bank_name: data[:bank_name] || data[:banco],
        amount: data[:amount] || data[:monto] || 0,
        position: data[:position] || index,
        notes: data[:notes] || data[:observaciones]
      )
    end
  end

  def self.raw_movements(attrs)
    data = attrs[:movimientos] || attrs[:movements] || []
    return data.map { |item| item.to_h.deep_symbolize_keys } if data.is_a?(Array)

    data.to_h.deep_symbolize_keys.flat_map do |key, values|
      Array(values).map do |item|
        item.to_h.deep_symbolize_keys.merge(movement_group: key.to_s)
      end
    end
  end

  def self.normalized_params(params)
    attrs = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
    attrs = attrs.deep_symbolize_keys
    attrs[:cuadre_caja] || attrs[:cash_closing] || attrs
  end

  def self.closing_status(cuadre_caja, attrs)
    return attrs[:status] if attrs[:status].present?
    return 'draft' if attrs[:submit].to_s == 'false'
    return cuadre_caja.status if cuadre_caja.persisted? && cuadre_caja.status.present?
    'submitted'
  end

  def self.empty_denominations_payload
    principal_divisa = principal_currency

    {
      bills: [50, 100, 200, 500, 1000, 2000].map { |value| empty_denomination('bill', value, principal_divisa) },
      coins: [5, 10, 25].map { |value| empty_denomination('coin', value, principal_divisa) },
      foreign_currency: []
    }
  end

  def self.principal_currency
    Divisa.find_by(is_principal: true, estado: true) || Divisa.find_by(predeterminado: true, estado: true)
  end

  def self.principal_currency_payload
    divisa = principal_currency
    return nil unless divisa

    {
      id: divisa.id,
      nombre: divisa.nombre,
      simbolo: divisa.simbolo,
      code: divisa.code,
      current_tasa: format('%.6f', BigDecimal((divisa.current_tasa || 1).to_s))
    }
  end

  def self.available_foreign_currencies_payload(closing_date)
    Divisa.where(estado: true, is_principal: [false, nil]).order(:nombre).map do |divisa|
      tasa = divisa.getMontoTasa(closing_date)
      {
        id: divisa.id,
        nombre: divisa.nombre,
        simbolo: divisa.simbolo,
        code: divisa.code,
        current_tasa: format('%.6f', BigDecimal((tasa&.valor || divisa.current_tasa || 0).to_s)),
        tasa_cambio_id: tasa&.id,
        fecha_equivalente: closing_date
      }
    end
  end

  def self.empty_denomination(type, value, divisa=nil)
    {
      denomination_type: type,
      divisa_id: divisa&.id,
      currency_code: LOCAL_CURRENCY_CODE,
      denomination_value: format('%.2f', BigDecimal(value.to_s)),
      quantity: '0.00',
      exchange_rate: '1.000000',
      local_currency_total: '0.00'
    }
  end

  def self.empty_movements_payload(system_income)
    {
      other_payment_methods: [],
      additional_transfers: [],
      suggested_from_system: suggested_system_movements(system_income)
    }
  end

  def self.suggested_system_movements(system_income)
    payment_methods = system_income[:payment_methods] || {}
    [
      suggested_system_movement('card', 'Tarjetas segun sistema', payment_methods[:card]),
      suggested_system_movement('check', 'Cheques segun sistema', payment_methods[:check]),
      suggested_system_movement('bank_transfer', 'Transferencias segun sistema', payment_methods[:bank_transfer])
    ].select { |item| BigDecimal(item[:amount]) > 0 }
  end

  def self.suggested_system_movement(payment_method, description, amount)
    {
      movement_group: 'other_payment_methods',
      payment_method: payment_method,
      description: description,
      amount: format('%.2f', BigDecimal(amount.to_s.presence || '0')),
      source: 'system_suggestion'
    }
  end

  def self.initial_totals_payload(system_income)
    {
      physical_cash_total: '0.00',
      other_payment_methods_total: '0.00',
      additional_transfers_total: '0.00',
      operational_total: '0.00',
      final_consumer_invoices_total: format('%.2f', BigDecimal(system_income[:final_consumer_invoices_total].to_s)),
      income_receipts_total: format('%.2f', BigDecimal(system_income[:income_receipts_total].to_s)),
      system_income_total: format('%.2f', BigDecimal(system_income[:system_income_total].to_s)),
      difference_amount: format('%.2f', -BigDecimal(system_income[:system_income_total].to_s)),
      balanced: false
    }
  end

  private

  def approved_closing_cannot_change
    return unless status_was == 'approved'
    return if status == 'reopened'
    errors.add(:base, 'No se puede editar un cuadre aprobado')
  end

  def transition_error(target_status)
    return 'No se puede aprobar un cuadre ya aprobado' if approved? && target_status == 'approved'
    return 'No se puede editar un cuadre aprobado' if approved? && target_status != 'reopened'
    return 'Debe enviar el cuadre antes de revisarlo' if target_status == 'reviewed' && status != 'submitted'
    return 'Debe revisar el cuadre antes de aprobarlo' if target_status == 'approved' && status != 'reviewed'
    nil
  end

  def assign_transition_attributes(target_status, user, reason)
    self.status = target_status

    case target_status
    when 'submitted'
      self.submitted_by = user
      self.submitted_at = Time.zone.now
    when 'reviewed'
      self.reviewed_by = user
      self.reviewed_at = Time.zone.now
    when 'approved'
      self.approved_by = user
      self.approved_at = Time.zone.now
    when 'rejected'
      self.rejected_by = user
      self.rejected_at = Time.zone.now
      self.rejection_reason = reason
    when 'reopened'
      self.reopened_by = user
      self.reopened_at = Time.zone.now
      self.reopen_reason = reason
    end
  end

  def amount_string(value)
    format('%.2f', decimal_value(value))
  end

  def decimal_value(value)
    BigDecimal(value.to_s.presence || '0')
  end
end
