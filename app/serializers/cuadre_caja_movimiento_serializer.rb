class CuadreCajaMovimientoSerializer < ActiveModel::Serializer
  extend FastSerializer


  ALL_OR_FIELD_FIELDS = [:id, :movement_group, :payment_method, :description, :reference, :counterparty_name, :bank_name, :amount, :position, :notes].freeze



  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :movement_group, :payment_method, :description, :reference, :counterparty_name, :bank_name, :amount, :position, :notes]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers
    {
      amount: ->(record) { format('%.2f', BigDecimal(record.amount.to_s.presence || '0')) }
    }
  end
end
