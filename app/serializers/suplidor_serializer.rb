class SuplidorSerializer < ActiveModel::Serializer
  
  attribute :id,                            if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :nombre,                        if: Proc.new { self.personalizar_parametros('nombre') || self.personalizar_parametros('all') }
  attribute :telefono,                      if: Proc.new { self.personalizar_parametros('telefono') || self.personalizar_parametros('all') }
  attribute :direccion,                     if: Proc.new { self.personalizar_parametros('direccion') || self.personalizar_parametros('all') }
  attribute :email,                         if: Proc.new { self.personalizar_parametros('email') || self.personalizar_parametros('all') }
  attribute :estado,                        if: Proc.new { self.personalizar_parametros('estado') || self.personalizar_parametros('all') }
  attribute :documentos_de_identidad,       if: Proc.new { self.personalizar_parametros('documentos_de_identidad') || self.personalizar_parametros('all') }

  def documentos_de_identidad
    documentos = []
    object.documentos_de_identidad.each do |documento|
      documentos.push(serialize_parser(documento, {}))
    end
    documentos
  end

  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
