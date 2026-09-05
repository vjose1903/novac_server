class ProduccionSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                                 if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :user_id,                            if: Proc.new { self.get_param('user_id') || self.get_param('all') }
  attribute :numero,                             if: Proc.new { self.get_param('numero') || self.get_param('all') }
  attribute :fecha_equivalente,                  if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :detalles_produccion,                   if: Proc.new { self.get_param('detalles_produccion') || self.get_param('all') }

  attribute :user,                               if: Proc.new { self.get_param('user') || self.get_param('all') }

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: {
      detalles_produccion: ->(produccion) { DetalleProduccionSerializer.collection_to_hash(produccion.detalles_produccion, { all: true }) },
      user: ->(produccion) { user_to_hash(produccion) }
    })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :user_id, :numero, :fecha_equivalente, :detalles_produccion, :user]
  end

  def self.user_to_hash(produccion)
    user = produccion.user
    user ? UserSerializer.to_hash(user, { nombre: true, apellido: true }) : nil
  end

  def detalles_produccion
    DetalleProduccionSerializer.collection_to_hash(object.detalles_produccion, {all: true})
  end

  def user
    UserSerializer.to_hash(object.user, {nombre: true, apellido: true})
  end
  
  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
