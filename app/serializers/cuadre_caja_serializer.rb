class CuadreCajaSerializer < ActiveModel::Serializer
  extend FastSerializer


  ALL_OR_FIELD_FIELDS = [
    :id, :closing_date, :fecha_equivalente, :status, :closing_version, :flow_type,
    :is_new_flow, :source_type, :numero_reporte, :currency_code, :totals,
    :denominations, :movements, :prepared_by, :submitted_by, :approved_by,
    :rejected_by, :reopened_by, :audit_dates, :notes, :rejection_reason,
    :reopen_reason, :system_income, :system_income_details, :eventos
  ].freeze















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
