class DetalleFacturaNota < ApplicationRecord
  belongs_to :factura_aplicada
  belongs_to :articulo
  belongs_to :detalle_factura
	belongs_to :tipo_factura

  def self.crear_detalle_factura_nota(params, padre, is_save=false)
    res = Response.new

    detalle_factura_nota                             = DetalleFacturaNota.new
    cantidad_en_unidades_calculada                   = self.calcular_cantidad_en_unidades(params)

    detalle_factura_nota.articulo_id                 = params[:articulo_id]
    detalle_factura_nota.codigo                      = params[:codigo]
    detalle_factura_nota.detalle_factura_id          = params[:detalle_factura_id]
    detalle_factura_nota.unidad                      = params[:unidad]
    detalle_factura_nota.cantidad                    = params[:cantidad]
    detalle_factura_nota.cantidad_origin             = params[:cantidad_origin]
    detalle_factura_nota.cantidad_en_unidades        = cantidad_en_unidades_calculada
    detalle_factura_nota.itbis                       = params[:itbis]
    detalle_factura_nota.itbis_real                  = params[:itbis_real]
    detalle_factura_nota.costo                       = params[:costo]
    detalle_factura_nota.precio                      = params[:precio]
    detalle_factura_nota.precio_real                 = params[:precio_real]
    detalle_factura_nota.total                       = params[:total]
    detalle_factura_nota.descuento                   = params[:descuento]
    detalle_factura_nota.descuento_real              = params[:descuento_real]
		detalle_factura_nota.tipo_factura_id             = padre.tipo_factura_id

    detalle_factura_nota.valid?

    detalle_factura_nota.errors.delete(:factura_aplicada) if !is_save


    res_proceso                                      = detalle_factura_nota.procesos_detalles_facturas_notas(params, padre, cantidad_en_unidades_calculada) if detalle_factura_nota.errors.empty?

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
  def procesos_detalles_facturas_notas(params, nota, cantidad_en_unidades)
    res                = Response.new

    tipos_nota_credito = [TiposNotasId.credito, TiposNotasId.credito_electronica]

		if tipos_nota_credito.include?(nota[:tipo_factura_id]) && cantidad_en_unidades.to_f > 0
				operador         = '+'
				fecha            = nota[:fecha_equivalente]
				accion           = TiposNotas.get_tipo(nota[:tipo_factura_id])

	      res_valid        = MovimientosInventario.movimientos_de_inventario(params.merge('cantidad_en_unidades' => cantidad_en_unidades), operador, fecha, accion, nota )

	      unless res_valid.status_valid
	        res.add_msgs(res_valid.get_msgs.to_a)
	        res.set_status(HTTP_STATUS_CODE[:conflict])
	      end
		end

    return res
  end

  def self.calcular_cantidad_en_unidades(params)
    cantidad_en_unidades = params[:cantidad_en_unidades].present? ? params[:cantidad_en_unidades] : params['cantidad_en_unidades']
    return cantidad_en_unidades if cantidad_en_unidades.present?

    cantidad = params[:cantidad].present? ? params[:cantidad].to_f : params['cantidad'].to_f
    return 0 if cantidad <= 0

    articulo_id = params[:articulo_id].present? ? params[:articulo_id] : params['articulo_id']
    articulo    = Articulo.includes(:contenido_articulos, :tipo_articulo).find_by(id: articulo_id)
    return cantidad if articulo.nil?

    contenidos = Articulo.calcularContenidos(articulo).with_indifferent_access
    unidad     = params[:unidad].present? ? params[:unidad] : params['unidad']
    unidad_key = self.normalizar_unidad(unidad, contenidos)

    multiplicador = contenidos[unidad_key]
    multiplicador  = multiplicador.present? ? multiplicador.to_f : 1

    cantidad * multiplicador
  end

  def self.normalizar_unidad(unidad, contenidos)
    return unidad if unidad.blank?

    unidad = unidad.to_s
    return unidad if contenidos[unidad].present?

    if unidad.match?(/\ASaco[_\s]?(?:de\s*)?(\d+)\z/i)
      return "Saco_#{$1}" if contenidos["Saco_#{$1}"].present?
    end

    if unidad.match?(/\A(Saco)\z/i) && contenidos['Saco'].present?
      return 'Saco'
    end

    unidad
  end

  #  --------------------------------------------------------------------------------------------------------------------------------

  def procesos_remover_detalles_facturas_notas
    res                = Response.new

    tipo_nota = self.tipo_nota

    if tipo_nota == TiposNotas.credito && self.cantidad_en_unidades > 0
      operador         = '-'
      fecha            = self.factura_aplicada.nota.fecha_equivalente
      accion           = "devolución de #{TiposNotas.get_tipo(self.tipo_factura_id)}"

      res_valid        = MovimientosInventario.movimientos_de_inventario(self, operador, fecha, accion, self.factura_aplicada.nota )

      unless res_valid.status_valid
        res.add_msgs(res_valid.get_msgs.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    # TODO: colocar condicion para notas de debito

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

	# ===================================================================================================================================================
  def tipo_nota
    return TiposNotas.get_tipo(self.tipo_factura_id)
  end
end
