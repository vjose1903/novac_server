class ClienteSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :imagen_id,                          if: Proc.new { self.personalizar_parametros('imagen_id') || self.personalizar_parametros('all') }
  attribute :nombre,                             if: Proc.new { self.personalizar_parametros('nombre') || self.personalizar_parametros('all') }
  attribute :estado,                             if: Proc.new { self.personalizar_parametros('estado') || self.personalizar_parametros('all') }
  attribute :apellido,                           if: Proc.new { self.personalizar_parametros('apellido') || self.personalizar_parametros('all') }
  attribute :limite_credito,                     if: Proc.new { self.personalizar_parametros('limite_credito') || self.personalizar_parametros('all') }
  attribute :telefono,                           if: Proc.new { self.personalizar_parametros('telefono') || self.personalizar_parametros('all') }
  attribute :direccion,                          if: Proc.new { self.personalizar_parametros('direccion') || self.personalizar_parametros('all') }
  attribute :sexo,                               if: Proc.new { self.personalizar_parametros('sexo') || self.personalizar_parametros('all') }
  attribute :maximo_credito,                     if: Proc.new { self.personalizar_parametros('maximo_credito') || self.personalizar_parametros('all') }
  attribute :vendedor_id,                        if: Proc.new { self.personalizar_parametros('vendedor_id') || self.personalizar_parametros('all') }
  attribute :balance,                            if: Proc.new { self.personalizar_parametros('balance') || self.personalizar_parametros('all') }
  attribute :documentos_de_identidad,            if: Proc.new { self.personalizar_parametros('documentos_de_identidad') || self.personalizar_parametros('all') }
  attribute :vendedor,                           if: Proc.new { self.personalizar_parametros('vendedor') || self.personalizar_parametros('all') }

  def vendedor
		vendedor = User.find_by_id(object.vendedor_id)
    serialize_parser(vendedor, {nombre: true, apellido: true, vendedor_id: true })
	end

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
