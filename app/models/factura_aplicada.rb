class FacturaAplicada < ApplicationRecord
  belongs_to :nota
  belongs_to :cabecera_factura
  belongs_to :tipo_factura
  has_many :detalles_facturas_notas, dependent: :destroy



  def self.models_includes
    includes = [
      {nota: [{user: :documentos_de_identidad}, {cliente: :documentos_de_identidad}, :tipo_factura, :facturas_aplicadas, :detalles_facturas_notas]},
      :cabecera_factura,
      {detalles_facturas_notas: [:articulo, :detalle_factura]}
    ]
    return includes
  end

  def self.crear_factura_aplicada(params, padre, is_save=false)
    res = Response.new

    factura_aplicada                             = FacturaAplicada.new

    factura_aplicada.cabecera_factura_id         = params[:cabecera_factura_id]
    factura_aplicada.total                       = params[:total]
    factura_aplicada.tipo_factura_id             = padre.tipo_factura_id

    factura_aplicada.valid?

    factura_aplicada.errors.delete(:nota) if !is_save


    dependencias                                 = [ {modelo: DetalleFacturaNota, key_object: "detalles_facturas_notas", padre: padre} ]

    res_proceso = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
      factura_aplicada.detalles_facturas_notas   = dependencia_data if key_object == 'detalles_facturas_notas'
    }

    res_proceso                                  = factura_aplicada.procesos_facturas_aplicadas(params, padre) if res_proceso.status_valid

    if res_proceso && res_proceso.status_valid && factura_aplicada.errors.empty? && (!is_save || (is_save && factura_aplicada.save!))
      res.set_data(factura_aplicada)
    else
      res.add_msgs(res_proceso.get_msgs.to_a) if res_proceso
      res.add_msgs(factura_aplicada.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  #  --------------------------------------------------------------------------------------------------------------------------------
  def procesos_facturas_aplicadas(params, nota)
    res                = Response.new
    res_valid          = CabeceraFactura.agregar_nota_a_CabeceraFactura(params, nota)

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
      res_temp = self.crear_factura_aplicada(item, padre, !item[:id].nil?)

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
  def self.get_cantidad_devueltos(params)
    res                = Response.new

    facturas_aplicadas = {}
    ids                = params[:ids].split(",").map(&:to_i)
    facturas           = FacturaAplicada.where(cabecera_factura_id: ids).includes(FacturaAplicada.models_includes)


    facturas.each do |fact_aplicada|
      facturas_aplicadas[fact_aplicada.cabecera_factura_id] = { :detalles => {} } if facturas_aplicadas[fact_aplicada.cabecera_factura_id].nil?

      arrayDetalle = fact_aplicada.detalles_facturas_notas

      arrayDetalle.each do |detalle|
        facturas_aplicadas[fact_aplicada.cabecera_factura_id][:detalles][detalle.detalle_factura_id] = 0 unless facturas_aplicadas[fact_aplicada.cabecera_factura_id][:detalles][detalle.detalle_factura_id]
        facturas_aplicadas[fact_aplicada.cabecera_factura_id][:detalles][detalle.detalle_factura_id] += detalle.cantidad
      end
    end
    res.set_data(facturas_aplicadas)

    return res
  end

  # ===================================================================================================================================================
  def tipo_nota
    return TiposNotas.get_tipo(self.tipo_factura_id)
  end
end
