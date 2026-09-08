class DetalleFacturaNotaSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                        if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :unidad,                    if: Proc.new { self.get_param('unidad') || self.get_param('all') }
  attribute :cantidad,                  if: Proc.new { self.get_param('cantidad') || self.get_param('all') }
  attribute :cantidad_origin,           if: Proc.new { self.get_param('cantidad_origin') || self.get_param('all') }
  attribute :cantidad_en_unidades,      if: Proc.new { self.get_param('cantidad_en_unidades') || self.get_param('all') }
  attribute :itbis,                     if: Proc.new { self.get_param('itbis') || self.get_param('all') }
  attribute :costo,                     if: Proc.new { self.get_param('costo') || self.get_param('all') }
  attribute :precio,                    if: Proc.new { self.get_param('precio') || self.get_param('all') }
  attribute :total,                     if: Proc.new { self.get_param('total') || self.get_param('all') }
  attribute :descuento,                 if: Proc.new { self.get_param('descuento') || self.get_param('all') }
  attribute :detalle_factura_id,        if: Proc.new { self.get_param('detalle_factura_id') || self.get_param('all') }

  attribute :articulo,                  if: Proc.new { self.get_param('articulo') || self.get_param('all') }

  ALL_OR_FIELD_FIELDS = [:id, :unidad, :cantidad, :cantidad_origin, :cantidad_en_unidades, :itbis, :costo, :precio, :total, :descuento, :detalle_factura_id, :articulo].freeze

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :unidad, :cantidad, :cantidad_origin, :cantidad_en_unidades, :itbis, :costo, :precio, :total, :descuento, :detalle_factura_id, :articulo]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers
    {
      articulo: ->(record) { ArticuloSerializer.to_hash(record.articulo, {id: true, nombre: true}) }
    }
  end
end
