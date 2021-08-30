class DocumentoDeIdentidadSerializer < ActiveModel::Serializer
  attributes :descripcion, :documento, :principal, :id, :prueba
  def prueba
    'lol'
  end
end
