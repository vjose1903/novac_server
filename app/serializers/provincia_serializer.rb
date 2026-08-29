class ProvinciaSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,          if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }
  attribute :nombre,      if: Proc.new { self.get_param('all') || has_to_show(self.get_param('nombre')) }
  attribute :codigo,      if: Proc.new { self.get_param('all') || has_to_show(self.get_param('codigo')) }
  attribute :municipios,  if: Proc.new { self.get_param('all') || has_to_show(self.get_param('municipios')) }

  def municipios
    optional_params = parse_serialize_optional_params(self.get_param('municipios'), { all: false, id: true, nombre: true, codigo: true  })
    serialize_parser(object.municipios, optional_params)
  end

  def get_param(col)
		return @instance_options[:"#{col}"]
	end

  def self.to_hash(object, params={})
    readers = {
      municipios: ->(provincia) { municipios_to_hash(provincia, params[:municipios]) }
    }

    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :nombre, :codigo, :municipios]
  end

  def self.municipios_to_hash(object, param=nil)
    optional_params = parse_serialize_optional_params(param, { all: false, id: true, nombre: true, codigo: true })
    MunicipioSerializer.collection_to_hash(object.municipios, optional_params)
  end
end
