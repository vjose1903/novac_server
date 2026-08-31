class CuadreCajaMovimientoSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id, if: Proc.new { get_param('id') || get_param('all') }
  attribute :movement_group, if: Proc.new { get_param('movement_group') || get_param('all') }
  attribute :payment_method, if: Proc.new { get_param('payment_method') || get_param('all') }
  attribute :description, if: Proc.new { get_param('description') || get_param('all') }
  attribute :reference, if: Proc.new { get_param('reference') || get_param('all') }
  attribute :counterparty_name, if: Proc.new { get_param('counterparty_name') || get_param('all') }
  attribute :bank_name, if: Proc.new { get_param('bank_name') || get_param('all') }
  attribute :amount, if: Proc.new { get_param('amount') || get_param('all') }
  attribute :position, if: Proc.new { get_param('position') || get_param('all') }
  attribute :notes, if: Proc.new { get_param('notes') || get_param('all') }

  ALL_OR_FIELD_FIELDS = [:id, :movement_group, :payment_method, :description, :reference, :counterparty_name, :bank_name, :amount, :position, :notes].freeze

  def amount
    format('%.2f', BigDecimal(object.amount.to_s.presence || '0'))
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

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
