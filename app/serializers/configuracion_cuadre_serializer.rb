class ConfiguracionCuadreSerializer < ActiveModel::Serializer
  attribute :id,             if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }
  attribute :config,         if: Proc.new { self.get_param('all') || has_to_show(self.get_param('config')) }
  attribute :created_at,     if: Proc.new { self.get_param('all') || has_to_show(self.get_param('created_at')) }
  attribute :updated_at,     if: Proc.new { self.get_param('all') || has_to_show(self.get_param('updated_at')) }

  def config
    value = object.config
    if value.is_a?(String)
      JSON.parse(value) rescue {}
    else
      value
    end
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
