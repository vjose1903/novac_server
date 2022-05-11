class ChoferViajeSerializer < ActiveModel::Serializer
  attribute :id
  attribute :chofer

  def chofer
    chofer_ = object.user
    serialize_parser(chofer_, {id:true, nombre: true, apellido: true, documentos_de_identidad: true,})
  end
end
