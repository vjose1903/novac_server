class SuplidorSerializer < ActiveModel::Serializer
  
  attribute :id,                            if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :nombre,                        if: Proc.new { self.get_param('nombre') || self.get_param('all') }
  attribute :telefono,                      if: Proc.new { self.get_param('telefono') || self.get_param('all') }
  attribute :direccion,                     if: Proc.new { self.get_param('direccion') || self.get_param('all') }
  attribute :email,                         if: Proc.new { self.get_param('email') || self.get_param('all') }
  attribute :estado,                        if: Proc.new { self.get_param('estado') || self.get_param('all') }
  attribute :documentos_de_identidad,       if: Proc.new { self.get_param('documentos_de_identidad') || self.get_param('all') }
  attribute :nombre_completo

  def documentos_de_identidad
    documentos = []
    object.documentos_de_identidad.each do |documento|
      documentos.push(serialize_parser(documento, {}))
    end
    documentos
  end
  
  def nombre_completo
		vendedor = object.nombre_completo
	end

  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
