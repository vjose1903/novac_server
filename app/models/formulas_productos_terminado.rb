class FormulasProductosTerminado < ApplicationRecord
  belongs_to :articulo
  belongs_to :articulo_combo_articulo, class_name: "Articulo", foreign_key: "articulo_combo", optional: true

  validates :costo,     presence: { :message => "El costo del ingrediente de la formula no puede estar vacio." },   numericality: { greater_than: 0, :message => "El costo del ingrediente de la formula debe de ser mayor a 0." }
  validates :precio,    presence: { :message => "El precio del ingrediente de la formula no puede estar vacio." } , numericality: { greater_than: 0, :message => "El costo del ingrediente de la formula debe de ser mayor a 0." }

  def articulo_combo
    return self[:articulo_combo] if has_attribute?(:articulo_combo)

    articulo_combo_id
  end

  def articulo_combo=(value)
    if has_attribute?(:articulo_combo)
      self[:articulo_combo] = value
    else
      self.articulo_combo_id = value
    end
  end

  def otras_validaciones
    ingrediente = articulo_combo_articulo || Articulo.find_by_id(self.articulo_combo)
    nombre_ingrediente = ingrediente&.nombre || "ingrediente"

    return self.errors.add(:base, "Debe introducir la cantidad necesaria de #{nombre_ingrediente}, para completar la formula.") if self.cantidad.nil?

    self.errors.add(:base, "La cantidad de #{nombre_ingrediente}, debe se ser mayor a 0") if self.cantidad <= 0
  end

  def self.crear_actualizar_contenido_articulo(params, padre, is_save=false)
    formula = build_from_params(params)
    formula.valid?
    formula.otras_validaciones
    formula.errors.delete(:articulo) unless is_save

    return response_with_data(formula) if valid_or_saved?(formula, is_save)

    response_with_errors(formula.errors.to_a)
  end

  def self.validar_e_inicializar(items, padre, save)
    formulas = []

    items.each do |item|
      next unless formula_item_present?(item)

      res_temp = crear_actualizar_contenido_articulo(item, padre, item_id?(item))
      return res_temp unless res_temp.status_valid

      formulas.push(res_temp.get_data)
    end

    response_with_data(formulas)
  end

  def self.build_from_params(params)
    FormulasProductosTerminado.where(:id => params["id"]).first_or_initialize.tap do |formula|
      formula.cantidad          = params["cantidad"]
      formula.articulo_combo    = params["articulo_combo"]
      formula.precio            = params["precio"]
      formula.costo             = params["costo"]
      formula.medida            = params["medida"]
    end
  end

  def self.formula_item_present?(item)
    !item["articulo_combo"].nil? && !item["cantidad"].nil?
  end

  def self.item_id?(item)
    item[:id].present? || item["id"].present?
  end

  def self.valid_or_saved?(record, is_save)
    record.errors.empty? && (!is_save || record.save!)
  end

  def self.response_with_data(data)
    Response.new.tap { |res| res.set_data(data) }
  end

  def self.response_with_errors(errors)
    Response.new.tap do |res|
      res.add_msgs(errors)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end
  end

  private_class_method :build_from_params, :formula_item_present?, :item_id?, :valid_or_saved?, :response_with_data, :response_with_errors

end
