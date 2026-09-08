class DetalleFactura < ApplicationRecord
  belongs_to :cabecera_factura
  belongs_to :articulo

  has_one :detalles_facturas_notas

  # ===================================================================================================================================================
  def otras_validaciones(params)
    self.errors.add(:base, "No se puede registrar la factura, el articulo <<#{self.articulo.nombre}>> no tiene medida.")      if params[:unidad] == nil
    self.errors.add(:base, "No se puede registrar la factura, el articulo <<#{self.articulo.nombre}>> no tiene total.")       if params[:total] == nil || params[:total] == 0
    self.errors.add(:base, "No se puede registrar la factura, el articulo <<#{self.articulo.nombre}>> no tiene cantidad.")    if params[:cantidad] == nil || params[:cantidad] == 0
  end


  # ===================================================================================================================================================
  def self.crear_detalle_factura(params, padre, is_save=false)
    detalle_factura = build_detalle_factura(params, padre, is_save)
    res_proceso     = detalle_factura.procesos_detalle(params, padre)

    return error_detalle_response(res_proceso, detalle_factura) unless detalle_listo_para_guardar?(detalle_factura, res_proceso, is_save)

    res = Response.new
    res.set_data(detalle_factura)
    res

  end

  private_class_method def self.build_detalle_factura(params, padre, is_save)
    detalle_factura                           = DetalleFactura.new
    detalle_factura.articulo_id               = params[:articulo_id]
    detalle_factura.codigo                    = params[:codigo]
    detalle_factura.unidad                    = params[:unidad]
    detalle_factura.total                     = params[:total]
    detalle_factura.cantidad                  = params[:cantidad]
    detalle_factura.cantidad_en_unidades      = params[:cantidad_en_unidades]
    detalle_factura.itbis                     = params[:itbis]
    detalle_factura.precio                    = params[:precio]
    detalle_factura.costo                     = params[:costo]
    detalle_factura.retirado                  = params[:retirado]
    detalle_factura.retirado_en_venta         = params[:retirado_en_venta]
    detalle_factura.descuento_valor           = params[:descuento_valor]
    detalle_factura.calcular_saco             = params[:calcular_saco] || false
    detalle_factura.detalle_factura_nota      = params[:detalle_factura_nota]
    detalle_factura.is_defectuoso             = params[:is_defectuoso] || false
    detalle_factura.is_devuelto               = params[:is_devuelto] || false
    detalle_factura.cabecera_factura_id       = padre[:id] if is_save

    detalle_factura.valid?
    detalle_factura.errors.delete(:cabecera_factura) unless is_save
    detalle_factura.otras_validaciones(params)

    detalle_factura
  end

  private_class_method def self.detalle_listo_para_guardar?(detalle_factura, res_proceso, is_save)
    res_proceso.status_valid &&
      detalle_factura.errors.empty? &&
      (!is_save || detalle_factura.save!)
  end

  private_class_method def self.error_detalle_response(res_proceso, detalle_factura)
    res = Response.new
    res.add_msgs(res_proceso.get_msgs.to_a)
    res.add_msgs(detalle_factura.errors.to_a)
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end

  # ===================================================================================================================================================
  def self.validar_e_inicializar(items, padre, save)
    res_valid  = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_detalle_factura(item, padre, !item[:id].nil?)

      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp
      end
    end

    res_valid.set_data array_valid
    return res_valid
  end

  # ===================================================================================================================================================
  def procesos_detalle(params, cabecera)
    return Response.new if cabecera["tipo"] == TiposFacturasDescripcion.cotizacion
    return Response.new if cabecera["pre_factura"].present? && (!params['is_devuelto'] || params['is_defectuoso'])

    operador = cabecera["pre_factura"].present? ? "+" : operador_inventario(cabecera)
    MovimientosInventario.movimientos_de_inventario(params, operador, cabecera["fecha_equivalente"], "factura", cabecera)
  end

  def operador_inventario(cabecera)
    cabecera["tipo"] == "compra" ? "+" : "-"
  end

  # ===================================================================================================================================================
  def self.anular_detalles(detalle, documento)
    res              = Response.new
    articulo         = detalle.articulo
    operacion        = documento.tipo == TiposFacturasDescripcion.compra.downcase ? '-' : '+'

    mov              = eval "#{articulo.existencia} #{operacion} #{detalle.cantidad_en_unidades.to_f}"

    if articulo.update({ existencia: mov }) && !detalle.destroy
      res.add_msgs(articulo.errors.to_a)
      res.add_msgs(detalle.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================
  def self.proceso_editar_detalles(factura_nueva, factura_original)
    res                = Response.new

    factura_original.detalle_facturas.each do |detalle|
      res_anular       = DetalleFactura.anular_detalles(detalle, factura_original)
      return res_anular unless res_anular.status_valid
    end

    factura_nueva['detalle_facturas'].each do |detalle|
      factura_nueva["fecha_equivalente"] = factura_original.fecha_equivalente
      res_temp = self.crear_detalle_factura(detalle, factura_nueva, true)
      return res_temp unless res_temp.status_valid
    end
    return res
  end

  # ===================================================================================================================================================
  def self.proceso_borrar_detalles(documento)

    documento.detalle_facturas.each do |detalle|
      DetalleFactura.anular_detalles(detalle, documento)
    end

  end
end
