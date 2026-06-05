class FormulasProductosTerminado < ApplicationRecord
  belongs_to :articulo

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
    ingrediente = Articulo.find_by_id(self.articulo_combo)

    if self.cantidad.nil?
      self.errors.add(:base, "Debe introducir la cantidad necesaria de #{ingrediente.nombre}, para completar la formula.")
    else
      self.errors.add(:base, "La cantidad de #{ingrediente.nombre}, debe se ser mayor a 0") if self.cantidad <= 0
    end
  end

  def self.crear_actualizar_contenido_articulo(params, padre, is_save=false)
    res = Response.new
		formula                   = FormulasProductosTerminado.where(:id => params["id"]).first_or_initialize

    formula.cantidad          = params["cantidad"]
    formula.articulo_combo    = params["articulo_combo"]
    formula.precio            = params["precio"]
    formula.costo             = params["costo"]
    formula.medida            = params["medida"]
    formula.valid?
    formula.otras_validaciones

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
					puts "::::::::::::::::::::::::::::".green
					puts "::::::::::::::::::::::::::::".green
					puts ":::::::   CONTINUAR  :::::::".green
					puts "::::::::::::::::::::::::::::".green
					puts "::::::::::::::::::::::::::::".green
					array_valid.push(res_temp.get_data)
				else
					puts "::::::::::::::::::::::::::::".red
					puts "::::::::::::::::::::::::::::".red
					puts "::::::: EXISTE ERROR :::::::".red
					puts "::::::::::::::::::::::::::::".red
					puts "::::::::::::::::::::::::::::".red
					return res_temp
				end
			end
    end

    res_valid.set_data array_valid
    return res_valid
  end


end
