class MunicipioSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,          if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }
  attribute :nombre,      if: Proc.new { self.get_param('all') || has_to_show(self.get_param('nombre')) }
  attribute :codigo,      if: Proc.new { self.get_param('all') || has_to_show(self.get_param('codigo')) }
  attribute :provincia,   if: Proc.new { has_to_show(self.get_param('provincia')) }

  def provincia
    optional_params = parse_serialize_optional_params(self.get_param('provincia'), { all: false, id: true, nombre: true  })
    serialize_parser(object.provincia, optional_params)
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    readers = {
      provincia: ->(municipio) { provincia_to_hash(municipio.provincia, params[:provincia]) }
    }

    serialize_record(object, selected_fields(params), readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :nombre, :codigo]
  end

  def self.selected_fields(params={})
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    fields << :provincia if has_to_show(params[:provincia])
    fields
  end

  def self.provincia_to_hash(provincia, param=nil)
    return nil unless provincia

    serialize_selected_record(provincia, [:id, :nombre], param: param)
  end
end
