class CuentaBancariaSerializer < ActiveModel::Serializer
  attribute :id,                            if: Proc.new { self.get_param('id')                || self.get_param('all') }
  attribute :numero_cuenta,                 if: Proc.new { self.get_param('numero_cuenta')     || self.get_param('all') }
  attribute :comentario,                    if: Proc.new { self.get_param('comentario')        || self.get_param('all') }
  attribute :descripcion,                   if: Proc.new { self.get_param('descripcion')       || self.get_param('all') }
  attribute :fecha_apertura,                if: Proc.new { self.get_param('fecha_apertura')    || self.get_param('all') }
  attribute :estado,                        if: Proc.new { self.get_param('estado')            || self.get_param('all') }


	def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
