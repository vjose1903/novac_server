class ClienteSerializer < ActiveModel::Serializer
  attributes :id, :imagen_id, :nombre, :estado, :apellido, :limite_credito, :telefono, :direccion, :sexo, :maximo_credito, :vendedor_id, :balance, :documentos_de_identidad, :vendedor

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
