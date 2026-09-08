class FormulasProductosTerminadoSerializer < ActiveModel::Serializer
  extend FastSerializer



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

end
