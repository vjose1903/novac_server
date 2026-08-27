class DivisaSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                               if: Proc.new { self.get_param('id')             || self.get_param('all') }
  attribute :nombre,                           if: Proc.new { self.get_param('nombre')         || self.get_param('all') }
  attribute :simbolo,                          if: Proc.new { self.get_param('simbolo')        || self.get_param('all') }
  attribute :code,                             if: Proc.new { self.get_param('code')           || self.get_param('all') }
  attribute :is_principal,                     if: Proc.new { self.get_param('is_principal')   || self.get_param('all') }
  attribute :estado,                           if: Proc.new { self.get_param('estado')         || self.get_param('all') }
  attribute :current_tasa,                     if: Proc.new { self.get_param('current_tasa')   || self.get_param('all') }
	attribute :imagen,                           if: Proc.new { self.get_param('imagen')         || self.get_param('all') }

	def imagen
    serialize_parser(object.imagenes.first, { id: true, file_name: true })
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    readers = {
      imagen: ->(divisa) { divisa.imagenes.first&.as_json }
    }
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :nombre, :simbolo, :code, :is_principal, :estado, :current_tasa, :imagen]
  end
end
