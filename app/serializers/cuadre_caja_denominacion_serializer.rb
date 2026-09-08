class CuadreCajaDenominacionSerializer < ActiveModel::Serializer
  extend FastSerializer


  ALL_OR_FIELD_FIELDS = [:id, :denomination_type, :divisa_id, :divisa, :tasa_cambio_id, :currency_code, :denomination_value, :quantity, :exchange_rate, :foreign_amount, :local_currency_total, :position].freeze








  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :denomination_type, :divisa_id, :divisa, :tasa_cambio_id, :currency_code, :denomination_value, :quantity, :exchange_rate, :foreign_amount, :local_currency_total, :position]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers
    {
      denomination_value: ->(record) { decimal_string(record.denomination_value) },
      divisa: ->(record) { record.divisa ? serialize_divisa(record.divisa) : nil },
      quantity: ->(record) { BigDecimal(record.quantity.to_s.presence || '0').to_i.to_s },
      exchange_rate: ->(record) { decimal_string(record.exchange_rate, 6) },
      foreign_amount: ->(record) { decimal_string(record.foreign_amount) },
      local_currency_total: ->(record) { decimal_string(record.local_currency_total) }
    }
  end

  def self.decimal_string(value, scale=2)
    format("%.#{scale}f", BigDecimal(value.to_s.presence || '0'))
  end

  def self.serialize_divisa(divisa)
    DivisaSerializer.to_hash(divisa, { id: true, nombre: true, simbolo: true, code: true, is_principal: true })
  end
  private_class_method :decimal_string, :serialize_divisa
end
