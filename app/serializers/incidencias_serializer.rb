class IncidenciasSerializer < ActiveModel::Serializer
  attribute :id,                            if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :referencia,                    if: Proc.new { self.get_param('referencia') || self.get_param('all') }
  attribute :descripcion,                   if: Proc.new { self.get_param('descripcion') || self.get_param('all') }


  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
