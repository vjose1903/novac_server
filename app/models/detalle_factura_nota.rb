class DetalleFacturaNota < ApplicationRecord
  belongs_to :factura_aplicada
  belongs_to :articulo
  belongs_to :detalle_factura


  def self.crear_detalle_factura_nota(params, padre, is_save=false)
    res = Response.new

    detalle_factura_nota                             = DetalleFacturaNota.new

    detalle_factura_nota.articulo_id                 = params[:articulo_id]
    detalle_factura_nota.detalle_factura_id          = params[:detalle_factura_id]
    detalle_factura_nota.unidad                      = params[:unidad]
    detalle_factura_nota.cantidad                    = params[:cantidad]
    detalle_factura_nota.cantidad_en_unidades        = params[:cantidad_en_unidades]
    detalle_factura_nota.itbis                       = params[:itbis]
    detalle_factura_nota.costo                       = params[:costo]
    detalle_factura_nota.precio                      = params[:precio]
    detalle_factura_nota.total                       = params[:total]
    detalle_factura_nota.descuento                   = params[:descuento]

    detalle_factura_nota.valid?

    detalle_factura_nota.errors.delete(:factura_aplicada) if !is_save


    res_proceso                                      = detalle_factura_nota.procesos_detalles_facturas_notas(params, padre) if detalle_factura_nota.errors.empty?

    if res_proceso && res_proceso.status_valid && detalle_factura_nota.errors.empty? && (!is_save || (is_save && detalle_factura_nota.save!))
      res.set_data(detalle_factura_nota)
    else
      res.add_msgs(res_proceso.get_msgs.to_a) if res_proceso
      res.add_msgs(detalle_factura_nota.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  #  --------------------------------------------------------------------------------------------------------------------------------
  def procesos_detalles_facturas_notas(params, nota)
    res                = Response.new

    operador         = nota["tipo_factura_id"] == TiposNotasId.credito ? "+" : "-"
    fecha            = nota["fecha_equivalente"]
    accion           = TiposNotas.get_tipo(nota["tipo_factura_id"])

    res_valid        = MovimientosInventario.movimientos_de_inventario(params, operador, fecha, accion, nota )

    unless res_valid.status_valid
      res.add_msgs(res_valid.get_msgs.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  #  --------------------------------------------------------------------------------------------------------------------------------

  def self.validar_e_inicializar(items, padre, save)
    res_valid  = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_detalle_factura_nota(item, padre, !item[:id].nil?)

      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp
      end
    end

    res_valid.set_data array_valid
    return res_valid
  end
end
