class CuadreCajaSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id, if: Proc.new { get_param('id') || get_param('all') }
  attribute :closing_date, if: Proc.new { get_param('closing_date') || get_param('all') }
  attribute :fecha_equivalente, if: Proc.new { get_param('fecha_equivalente') || get_param('all') }
  attribute :status, if: Proc.new { get_param('status') || get_param('all') }
  attribute :closing_version, if: Proc.new { get_param('closing_version') || get_param('all') }
  attribute :flow_type, if: Proc.new { get_param('flow_type') || get_param('all') }
  attribute :is_new_flow, if: Proc.new { get_param('is_new_flow') || get_param('all') }
  attribute :source_type, if: Proc.new { get_param('source_type') || get_param('all') }
  attribute :numero_reporte, if: Proc.new { get_param('numero_reporte') || get_param('all') }
  attribute :currency_code, if: Proc.new { get_param('currency_code') || get_param('all') }
  attribute :totals, if: Proc.new { get_param('totals') || get_param('all') }
  attribute :denominations, if: Proc.new { get_param('denominations') || get_param('all') }
  attribute :movements, if: Proc.new { get_param('movements') || get_param('all') }
  attribute :prepared_by, if: Proc.new { get_param('prepared_by') || get_param('all') }
  attribute :submitted_by, if: Proc.new { get_param('submitted_by') || get_param('all') }
  attribute :approved_by, if: Proc.new { get_param('approved_by') || get_param('all') }
  attribute :rejected_by, if: Proc.new { get_param('rejected_by') || get_param('all') }
  attribute :reopened_by, if: Proc.new { get_param('reopened_by') || get_param('all') }
  attribute :audit_dates, if: Proc.new { get_param('audit_dates') || get_param('all') }
  attribute :notes, if: Proc.new { get_param('notes') || get_param('all') }
  attribute :rejection_reason, if: Proc.new { get_param('rejection_reason') || get_param('all') }
  attribute :reopen_reason, if: Proc.new { get_param('reopen_reason') || get_param('all') }
  attribute :system_income, if: Proc.new { get_param('system_income') || get_param('all') }
  attribute :system_income_details, if: Proc.new { get_param('system_income_details') || get_param('all') }
  attribute :eventos, if: Proc.new { get_param('eventos') || get_param('all') }

  ALL_OR_FIELD_FIELDS = [
    :id, :closing_date, :fecha_equivalente, :status, :closing_version, :flow_type,
    :is_new_flow, :source_type, :numero_reporte, :currency_code, :totals,
    :denominations, :movements, :prepared_by, :submitted_by, :approved_by,
    :rejected_by, :reopened_by, :audit_dates, :notes, :rejection_reason,
    :reopen_reason, :system_income, :system_income_details, :eventos
  ].freeze

  def totals
    object.totals_payload
  end

  def flow_type
    object.detailed? ? 'new' : 'legacy'
  end

  def is_new_flow
    object.detailed?
  end

  def denominations
    {
      bills: serialize_parser(object.denominaciones.select { |item| item.denomination_type == 'bill' }, { all: true }),
      coins: serialize_parser(object.denominaciones.select { |item| item.denomination_type == 'coin' }, { all: true }),
      foreign_currency: serialize_parser(object.denominaciones.select { |item| item.denomination_type == 'foreign_currency' || item.currency_code != CuadreCaja::LOCAL_CURRENCY_CODE }, { all: true })
    }
  end

  def movements
    {
      other_payment_methods: serialize_parser(object.movimientos.select { |item| item.movement_group == 'other_payment_methods' }, { all: true }),
      additional_transfers: serialize_parser(object.movimientos.select { |item| item.movement_group == 'additional_transfers' }, { all: true })
    }
  end

  def prepared_by
    serialize_user(object.prepared_by)
  end

  def submitted_by
    serialize_user(object.submitted_by)
  end

  def approved_by
    serialize_user(object.approved_by)
  end

  def rejected_by
    serialize_user(object.rejected_by)
  end

  def reopened_by
    serialize_user(object.reopened_by)
  end

  def audit_dates
    {
      submitted_at: object.submitted_at,
      approved_at: object.approved_at,
      rejected_at: object.rejected_at,
      reopened_at: object.reopened_at
    }
  end

  def system_income
    object.system_income_payload
  end

  def eventos
    serialize_parser(object.eventos.order('created_at ASC'), { all: true })
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

  private

  def serialize_user(user)
    return nil unless user
    UserSerializer.to_hash(user, { id: true, nombre: true, apellido: true, nombre_completo: true })
  end

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    ALL_OR_FIELD_FIELDS
  end

  def self.show_field?(field, params)
    params[:all] || params[field]
  end

  def self.readers
    {
      flow_type: ->(record) { record.detailed? ? 'new' : 'legacy' },
      is_new_flow: ->(record) { record.detailed? },
      totals: ->(record) { record.totals_payload },
      denominations: ->(record) { denominations_hash(record) },
      movements: ->(record) { movements_hash(record) },
      prepared_by: ->(record) { serialize_user_hash(record.prepared_by) },
      submitted_by: ->(record) { serialize_user_hash(record.submitted_by) },
      approved_by: ->(record) { serialize_user_hash(record.approved_by) },
      rejected_by: ->(record) { serialize_user_hash(record.rejected_by) },
      reopened_by: ->(record) { serialize_user_hash(record.reopened_by) },
      audit_dates: ->(record) { audit_dates_hash(record) },
      system_income: ->(record) { record.system_income_payload },
      eventos: ->(record) { CuadreCajaEventoSerializer.collection_to_hash(record.eventos.order('created_at ASC'), { all: true }) }
    }
  end

  def self.denominations_hash(record)
    {
      bills: CuadreCajaDenominacionSerializer.collection_to_hash(record.denominaciones.select { |item| item.denomination_type == 'bill' }, { all: true }),
      coins: CuadreCajaDenominacionSerializer.collection_to_hash(record.denominaciones.select { |item| item.denomination_type == 'coin' }, { all: true }),
      foreign_currency: CuadreCajaDenominacionSerializer.collection_to_hash(record.denominaciones.select { |item| item.denomination_type == 'foreign_currency' || item.currency_code != CuadreCaja::LOCAL_CURRENCY_CODE }, { all: true })
    }
  end

  def self.movements_hash(record)
    {
      other_payment_methods: CuadreCajaMovimientoSerializer.collection_to_hash(record.movimientos.select { |item| item.movement_group == 'other_payment_methods' }, { all: true }),
      additional_transfers: CuadreCajaMovimientoSerializer.collection_to_hash(record.movimientos.select { |item| item.movement_group == 'additional_transfers' }, { all: true })
    }
  end

  def self.serialize_user_hash(user)
    return nil unless user
    UserSerializer.to_hash(user, { id: true, nombre: true, apellido: true, nombre_completo: true })
  end

  def self.audit_dates_hash(record)
    {
      submitted_at: record.submitted_at&.as_json,
      approved_at: record.approved_at&.as_json,
      rejected_at: record.rejected_at&.as_json,
      reopened_at: record.reopened_at&.as_json
    }
  end
  private_class_method :denominations_hash, :movements_hash, :serialize_user_hash, :audit_dates_hash
end
