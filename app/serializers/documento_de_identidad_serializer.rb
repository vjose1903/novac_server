class DocumentoDeIdentidadSerializer < ActiveModel::Serializer
  attributes :descripcion, :documento, :principal
end
