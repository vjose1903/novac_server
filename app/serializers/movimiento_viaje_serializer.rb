class MovimientoViajeSerializer < ActiveModel::Serializer
  attributes :id
  attribute :chofer
  attribute :vehiculo


  def chofer
    chofer_ = object.user
    serialize_parser(chofer_, { id:true, nombre: true, apellido: true, documentos_de_identidad: true })
  end

  def vehiculo
    vehiculo_ = object.vehiculo
    serialize_parser(vehiculo_, { id:true, propietario:true, user_id:true })
  end
end
