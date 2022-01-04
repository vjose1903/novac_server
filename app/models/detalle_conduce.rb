class DetalleConduce < ApplicationRecord
  belongs_to :cabecera_conduce
  belongs_to :detalle_factura, optional: true
  belongs_to :articulo


  validates :articulo,    presence: { :message => "Articulo no puede estar vacio." }
  validates :cantidad,    presence: { :message => "Cantidad no puede estar vacio." }, numericality: { greater_than: 0, :message => "La cantidad debe de ser mayor a 0." }
  validates :unidad,      presence: { :message => "Medida no puede estar vacio." }


  def self.crear_actualizar_detalle_conduce(params, padre, is_save=false)
    res = Response.new

    unless params["id"]
      detalle_conduce                      = DetalleConduce.new
    else
      detalle_conduce                      = DetalleConduce.find_by_id(params["id"])
    end


    detalle_conduce.detalle_factura_id     = params["detalle_factura_id"]
    detalle_conduce.articulo_id            = params["articulo_id"]
    detalle_conduce.cantidad               = params["cantidad"]
    detalle_conduce.cantidad_en_unidades   = params["cantidad_en_unidades"]
    detalle_conduce.unidad                 = params["unidad"]
    
    detalle_conduce.valid?
    
    detalle_conduce.errors.delete(:cabecera_conduce) if !is_save

    res_proceso                            = detalle_conduce.procesos_detalle

    if res_proceso.status_valid && detalle_conduce.errors.empty? && (!is_save || (is_save && detalle_conduce.save!))
      res.set_data(detalle_conduce)
    else
      res.add_msgs(detalle_conduce.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end


  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]
    
    items.each do |item|
      res_temp = self.crear_actualizar_detalle_conduce(item, padre, !item[:id].nil?)

      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp 
      end
    end

    res_valid.set_data array_valid
    return res_valid
  end


  def procesos_detalle
    res = Response.new()
    
    if self.detalle_factura_id
      detalleFactura              = self.detalle_factura
      cabeceraFactura             = detalleFactura.cabecera_factura
      
      if cabeceraFactura.is_adelantada
        detalleFactura.retirado   = detalleFactura.retirado + self.cantidad_en_unidades

        unless detalleFactura.save!
          res.add_msgs(detalleFactura.errors.to_a) 
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
        
      end
    end
    
    if res.status_valid
      articulo = self.articulo
      mov      = articulo.existencia - self.cantidad_en_unidades
      
      if mov < 0
        res.add_msg("Cantidad introducida para el articulo #{articulo.nombre.titleize} ahora excede la cantidad disponible en inventario. ") 
        res.set_status(HTTP_STATUS_CODE[:conflict])
      else

        unless articulo.update({ existencia: mov })
          res.add_msgs(articulo.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      end

      return res
    else
      return res
    end
  end

end
