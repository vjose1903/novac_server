class DocumentoDeIdentidadSerializer < ActiveModel::Serializer
  attributes :descripcion, :documento, :principal, :id
  attribute :persona,  if: Proc.new { self.personalizar_parametros('persona')  }

  def persona
    object.origen
	end
  
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
