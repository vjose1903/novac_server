class ContenidoArticulo < ApplicationRecord
  belongs_to :articulo

  validates :costo,     presence: { :message => "El costo del contenido no puede estar vacio." }
  validates :precio,    presence: { :message => "El precio del contenido no puede estar vacio." }
  validates :cantidad,  presence: { :message => "La cantidad del contenido no puede estar vacio." }, numericality: { greater_than: 0, :message => "La cantidad del contendio del articulo debe de ser mayor a 0." }
  validates :medida,    presence: { :message => "La medida del contenido no puede estar vacio." },   uniqueness: { scope: [:articulo_id, :condicion], case_sensitive: false, :message => "El articulo ya tiene registrado esta medida << %{value} >>" }
  validates :condicion, presence: { :message => "La condicion del contenido no puede estar vacio." }


  def self.crear_actualizar_contenido_articulo(params, padre, is_save=false)
    contenido = build_from_params(params)
    contenido.valid?
    contenido.errors.delete(:articulo) unless is_save

    return response_with_data(contenido) if valid_or_saved?(contenido, is_save)

    response_with_errors(contenido.errors.to_a)
  end

  def self.validar_e_inicializar(items, padre, save)
    contenidos = []

    items.each do |item|
      res_temp = crear_actualizar_contenido_articulo(item, padre, item_id?(item))
      return res_temp unless res_temp.status_valid

      contenidos.push(res_temp.get_data)
    end

    response_with_data(contenidos)
  end

  def self.build_from_params(params)
    ContenidoArticulo.where(:id => params["id"]).first_or_initialize.tap do |contenido|
      contenido.referencia        = params["referencia"] || nil
      contenido.costo             = params["costo"]
      contenido.precio            = params["precio"]
      contenido.cantidad          = params["cantidad"]
      contenido.medida            = params["medida"]
      contenido.condicion         = params["condicion"]
      contenido.calcular_itbis    = params["calcular_itbis"]
    end
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

  private_class_method :build_from_params, :item_id?, :valid_or_saved?, :response_with_data, :response_with_errors

end
