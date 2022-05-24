class DetalleProduccion < ApplicationRecord
  belongs_to :produccion
  belongs_to :articulo

  validates :articulo,    presence: { :message => "Articulo no puede estar vacio." }
  validates :medida,      presence: { :message => "Medida de los ingredientes no puede estar vacia." }
  validates :cantidad,    presence: { :message => "Cantidad de los ingredientes no puede estar vacio." }, numericality: { greater_than: 0, :message => "La cantidad de los ingredientes debe de ser mayor a 0." }

  def self.crear_actualizar_detalle_produccion(params, padre, is_save=false)
    res = Response.new
		detalle_produccion                           = DetalleProduccion.where(:id => params["id"]).first_or_create

    detalle_produccion.articulo_id               = params["articulo_id"]
    detalle_produccion.cantidad                  = params["cantidad"]
    detalle_produccion.cantidad_en_unidades      = params["cantidad_en_unidades"]
    detalle_produccion.medida                    = params["medida"]

    detalle_produccion.valid?

    detalle_produccion.errors.delete(:produccion) if !is_save

    res_proceso                            = detalle_produccion.procesos_detalle(params)


    if res_proceso.status_valid && detalle_produccion.errors.empty? && (!is_save || (is_save && detalle_produccion.save!))
      res.set_data(detalle_produccion)
    else
			res.add_msgs(res_proceso.get_msgs.to_a)
      res.add_msgs(detalle_produccion.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_actualizar_detalle_produccion(item, padre, !item[:id].nil?)

      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp
      end
    end

    res_valid.set_data array_valid
    return res_valid
  end

  def procesos_detalle(params)
    res = Response.new

    params["ingredientes"].each do |ingrediente|
      articulo_ingrediente     = Articulo.find_by_id(ingrediente["articulo_combo"])

      mov                      = (articulo_ingrediente.existencia - ingrediente["cantidad_en_unidades"])

      unless articulo_ingrediente.update({ existencia: mov })
        res.add_msgs(articulo_ingrediente.errors)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    if res.status_valid
      productoTerminado        = self.articulo
      movProd                  = (productoTerminado.existencia + self.cantidad_en_unidades)

      unless productoTerminado.update({ existencia: movProd })
        res.add_msgs(productoTerminado.errors)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    return res
  end

end
