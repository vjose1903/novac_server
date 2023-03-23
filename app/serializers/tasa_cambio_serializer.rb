class TasaCambioSerializer < ActiveModel::Serializer
  attribute :id,                       if: Proc.new { self.get_param('id')                   || self.get_param('all') }
  attribute :divisa_id,                if: Proc.new { self.get_param('divisa_id')            || self.get_param('all') }
  attribute :valor,                    if: Proc.new { self.get_param('valor')                || self.get_param('all') }
  attribute :fecha_equivalente,        if: Proc.new { self.get_param('fecha_equivalente')    || self.get_param('all') }


	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
