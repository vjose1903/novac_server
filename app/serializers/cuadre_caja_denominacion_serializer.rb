class CuadreCajaDenominacionSerializer < ActiveModel::Serializer
  attribute :id, if: Proc.new { get_param('id') || get_param('all') }
  attribute :denomination_type, if: Proc.new { get_param('denomination_type') || get_param('all') }
  attribute :divisa_id, if: Proc.new { get_param('divisa_id') || get_param('all') }
  attribute :divisa, if: Proc.new { get_param('divisa') || get_param('all') }
  attribute :tasa_cambio_id, if: Proc.new { get_param('tasa_cambio_id') || get_param('all') }
  attribute :currency_code, if: Proc.new { get_param('currency_code') || get_param('all') }
  attribute :denomination_value, if: Proc.new { get_param('denomination_value') || get_param('all') }
  attribute :quantity, if: Proc.new { get_param('quantity') || get_param('all') }
  attribute :exchange_rate, if: Proc.new { get_param('exchange_rate') || get_param('all') }
  attribute :foreign_amount, if: Proc.new { get_param('foreign_amount') || get_param('all') }
  attribute :local_currency_total, if: Proc.new { get_param('local_currency_total') || get_param('all') }
  attribute :position, if: Proc.new { get_param('position') || get_param('all') }

  def denomination_value
    decimal_string(object.denomination_value)
  end

  def divisa
    serialize_parser(object.divisa, { id: true, nombre: true, simbolo: true, code: true, is_principal: true }) if object.divisa
  end

  def quantity
    decimal_string(object.quantity)
  end

  def exchange_rate
    decimal_string(object.exchange_rate, 6)
  end

  def foreign_amount
    decimal_string(object.foreign_amount)
  end

  def local_currency_total
    decimal_string(object.local_currency_total)
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

  private

  def decimal_string(value, scale=2)
    format("%.#{scale}f", BigDecimal(value.to_s.presence || '0'))
  end
end
