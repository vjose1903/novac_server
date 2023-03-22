class DivisaSerializer < ActiveModel::Serializer
  attribute :id,                               if: Proc.new { self.get_param('id')             || self.get_param('all') }
  attribute :nombre,                           if: Proc.new { self.get_param('nombre')         || self.get_param('all') }
  attribute :simbolo,                          if: Proc.new { self.get_param('simbolo')        || self.get_param('all') }
  attribute :is_principal,                     if: Proc.new { self.get_param('is_principal')   || self.get_param('all') }
  attribute :estado,                           if: Proc.new { self.get_param('estado')         || self.get_param('all') }
	attribute :imagenes,                         if: Proc.new { self.get_param('imagenes')       || self.get_param('all') }

	def imagenes
    serialize_parser(object.imagenes, { id: true, file_name: true })
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
