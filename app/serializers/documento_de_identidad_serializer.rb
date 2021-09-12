class DocumentoDeIdentidadSerializer < ActiveModel::Serializer
  attributes :descripcion, :documento, :principal, :id
  attribute :persona,  if: Proc.new { self.personalizar_parametros('persona')  }
  attribute :persona_is,  if: Proc.new { self.personalizar_parametros('persona')  }

  def persona_is
    object.origen_type
	end

  def persona
    serialize_parser(object.origen, {all:true, documentos_de_identidad: true})
	end
  
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
