class FormulasProductosTerminado < ApplicationRecord
  belongs_to :articulo

  validates :costo,     presence: { :message => "El costo del ingrediente de la formula no puede estar vacio." },   numericality: { greater_than: 0, :message => "El costo del ingrediente de la formula debe de ser mayor a 0." }
  validates :precio,    presence: { :message => "El precio del ingrediente de la formula no puede estar vacio." } , numericality: { greater_than: 0, :message => "El costo del ingrediente de la formula debe de ser mayor a 0." }

  before_validation :otras_validaciones

  def otras_validaciones
    ingrediente = Articulo.find_by_id(self.articulo_combo)

    if self.cantidad.nil?
      self.errors.add(:base, "Debe introducir la cantidad necesaria de #{ingrediente.nombre}, para completar la formula.")
    else
      self.errors.add(:base, "La cantidad de #{ingrediente.nombre}, debe se ser mayor a 0") if self.cantidad <= 0
    end
  end

  def self.crear_actualizar_contenido_articulo(params, padre, is_save=false)
    res = Response.new

    unless params["id"]
      formula                 = FormulasProductosTerminado.new
    else
      formula                 = FormulasProductosTerminado.find_by_id(params["id"])
    end

    formula.cantidad          = params["cantidad"]
    formula.articulo_combo    = params["articulo_combo"]
    formula.precio            = params["precio"]
    formula.costo             = params["costo"]
    formula.medida            = params["medida"]

    formula.errors.delete(:articulo) if !is_save

    if formula.errors.empty? && (!is_save || (is_save && formula.save!))
      res.set_data(formula)
    else
      res.add_msgs(formula.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|

			if !item['articulo_combo'].nil? && !item['cantidad'].nil?
				res_temp = self.crear_actualizar_contenido_articulo(item, padre, !item[:id].nil?)

				if res_temp.status_valid
					array_valid.push(res_temp.get_data)
				else
					return res_temp
				end
			end
    end

    res_valid.set_data array_valid
    return res_valid
  end


end
