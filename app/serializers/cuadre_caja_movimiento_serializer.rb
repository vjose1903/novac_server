class CuadreCajaMovimientoSerializer < ActiveModel::Serializer
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

  def amount
    format('%.2f', BigDecimal(object.amount.to_s.presence || '0'))
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end
end
