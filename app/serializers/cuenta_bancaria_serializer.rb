class CuentaBancariaSerializer < ActiveModel::Serializer
  attribute :id,                            if: Proc.new { self.get_param('id')                      || self.get_param('all') }
  attribute :numero_cuenta,                 if: Proc.new { self.get_param('numero_cuenta')           || self.get_param('all') }
  attribute :comentario,                    if: Proc.new { self.get_param('comentario')              || self.get_param('all') }
  attribute :descripcion,                   if: Proc.new { self.get_param('descripcion')             || self.get_param('all') }
  attribute :fecha_apertura,                if: Proc.new { self.get_param('fecha_apertura')          || self.get_param('all') }
  attribute :estado,                        if: Proc.new { self.get_param('estado')                  || self.get_param('all') }

  attribute :cuenta_contable,               if: Proc.new {  self.get_param('cuenta_contable')         || self.get_param('all') }
  attribute :cuenta_contable_prima,         if: Proc.new { (self.get_param('cuenta_contable_prima')   || self.get_param('all')) && !object.cuenta_contable_prima.nil? }

	def cuenta_contable
		serialize_parser(object.cuenta_contable, {id: true, descripcion: true, codigo: true})
	end

	def cuenta_contable_prima
		serialize_parser(object.cuenta_contable_prima, {id: true, descripcion: true, codigo: true})
	end


	def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
