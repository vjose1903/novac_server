class ConfigArticuloSerializer < ActiveModel::Serializer
  attribute :id,                              if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :porciento_ganancia,              if: Proc.new { self.get_param('porciento_ganancia') || self.get_param('all') }

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
