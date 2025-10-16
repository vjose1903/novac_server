class MovimientoViajeSerializer < ActiveModel::Serializer
  attributes :id
  attribute :chofer
  attribute :vehiculo
  attribute :vehiculo_id
  attribute :user_id


  def chofer
    chofer_ = object.user
    serialize_parser(chofer_, { id: true, nombre: true, apellido: true, documentos_de_identidad: true })
  end

  def vehiculo
    vehiculo_ = object.vehiculo
    serialize_parser(vehiculo_, { id: true, propietario: true, user_id: true, info_vehiculo: true, marca_modelo_anio: self.get_param('marca_modelo_anio') || false })
  end


  def get_param(col)
    @instance_options[:"#{col}"]
  end
end
