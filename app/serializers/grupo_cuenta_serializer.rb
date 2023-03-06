class GrupoCuentaSerializer < ActiveModel::Serializer
	attribute :id,                           if: Proc.new { self.get_param('id') || self.get_param('all') }
	attribute :descripcion,                  if: Proc.new { self.get_param('descripcion') || self.get_param('all') }
	attribute :grupo,                        if: Proc.new { self.get_param('grupo') || self.get_param('all') }
	attribute :origen,                       if: Proc.new { self.get_param('origen') || self.get_param('all') }
	attribute :tipo,                         if: Proc.new { self.get_param('tipo') || self.get_param('all') }
	attribute :cuentas_contables,            if: Proc.new { self.get_param('cuentas_contables') || self.get_param('all') }

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
