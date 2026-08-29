class FormulasProductosTerminadoSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                        if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :articulo_id,               if: Proc.new { self.get_param('articulo_id') || self.get_param('all') }
  attribute :cantidad,                  if: Proc.new { self.get_param('cantidad') || self.get_param('all') }
  attribute :costo,                     if: Proc.new { self.get_param('costo') || self.get_param('all') }
  attribute :precio,                    if: Proc.new { self.get_param('precio') || self.get_param('all') }
  attribute :medida,                    if: Proc.new { self.get_param('medida') || self.get_param('all') }

  attribute :articulo_combo,            if: Proc.new { self.get_param('articulo_combo') || self.get_param('all') }
  attribute :nombre,                    if: Proc.new { self.get_param('nombre') || self.get_param('all') }
  attribute :existencia,                if: Proc.new { self.get_param('existencia') || self.get_param('all') }
  attribute :contenido,                 if: Proc.new { self.get_param('contenido') || self.get_param('all') }

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :articulo_id, :cantidad, :costo, :precio, :medida, :articulo_combo, :nombre, :existencia, :contenido]
  end

  def self.readers
    {
      nombre: ->(formula) { articulo_combo_object(formula)&.nombre },
      existencia: ->(formula) { (combo = articulo_combo_object(formula)) ? Articulo.cantidades_calculadas(combo) : {} },
      contenido: ->(formula) { (combo = articulo_combo_object(formula)) ? Articulo.contenidos_calculados(combo) : {} }
    }
  end

  def self.articulo_combo_object(formula)
    Thread.current[:articulos_cache] ||= {}
    combo_id = formula.articulo_combo
    return nil if combo_id.nil?

    return Thread.current[:articulos_cache][combo_id] if Thread.current[:articulos_cache].key?(combo_id)

    Thread.current[:articulos_cache][combo_id] = formula.respond_to?(:articulo_combo_articulo) ? formula.articulo_combo_articulo : nil
  end

  def articulo_combo
    object.articulo_combo
  end

  def nombre
    articulo_combo_object&.nombre
  end

  def existencia
    return {} unless articulo_combo_object
    Articulo.cantidades_calculadas(articulo_combo_object)
  end

  def contenido
    return {} unless articulo_combo_object
    Articulo.contenidos_calculados(articulo_combo_object)
  end

  private

  def articulo_combo_object
    Thread.current[:articulos_cache] ||= {}
    combo_id = object.articulo_combo
    return nil if combo_id.nil?

    return Thread.current[:articulos_cache][combo_id] if Thread.current[:articulos_cache].key?(combo_id)

    if object.respond_to?(:association) && object.association(:articulo_combo_articulo).loaded?
      Thread.current[:articulos_cache][combo_id] = object.articulo_combo_articulo
      return Thread.current[:articulos_cache][combo_id]
    end

    Thread.current[:articulos_cache][combo_id] = object.articulo_combo_articulo
  end

  def get_param(col)
    @instance_options[col.to_sym]
  end
end
