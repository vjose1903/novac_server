class ContenidoArticuloSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                         if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :articulo_id,                if: Proc.new { self.get_param('articulo_id') || self.get_param('all') }
  attribute :referencia,                 if: Proc.new { self.get_param('referencia') || self.get_param('all') }
  attribute :costo,                      if: Proc.new { self.get_param('costo') || self.get_param('all') }
  attribute :precio,                     if: Proc.new { self.get_param('precio') || self.get_param('all') }
  attribute :cantidad,                   if: Proc.new { self.get_param('cantidad') || self.get_param('all') }
  attribute :medida,                     if: Proc.new { self.get_param('medida') || self.get_param('all') }
  attribute :condicion,                  if: Proc.new { self.get_param('condicion') || self.get_param('all') }
  attribute :calcular_itbis,             if: Proc.new { self.get_param('calcular_itbis') || self.get_param('all') }

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    serialize_record(object, fields, readers: { calcular_itbis: ->(item) { read_serialized_value(item, :calcular_itbis) || false } })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :articulo_id, :referencia, :costo, :precio, :cantidad, :medida, :condicion, :calcular_itbis]
  end

  def calcular_itbis
    return false if object.calcular_itbis.nil?

    object.calcular_itbis
  end

  def get_param(col)
    @instance_options[col.to_sym]
  end
end
