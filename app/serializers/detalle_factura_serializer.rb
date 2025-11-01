class DetalleFacturaSerializer < ActiveModel::Serializer


  attribute :id,                                         if: Proc.new { self.get_param('all') || self.get_param('id') }
  attribute :articulo_id,                                if: Proc.new { self.get_param('all') || self.get_param('articulo_id') }
  attribute :total,                                      if: Proc.new { self.get_param('all') || self.get_param('total') }
  attribute :descuento_valor,                            if: Proc.new { self.get_param('all') || self.get_param('descuento_valor') }
  attribute :itbis,                                      if: Proc.new { self.get_param('all') || self.get_param('itbis') }
  attribute :cantidad,                                   if: Proc.new { self.get_param('all') || self.get_param('cantidad') }
  attribute :cantidad_en_unidades,                       if: Proc.new { self.get_param('all') || self.get_param('cantidad_en_unidades') }
  attribute :retirado,                                   if: Proc.new { self.get_param('all') || self.get_param('retirado') }
  attribute :retirado_en_venta,                          if: Proc.new { self.get_param('all') || self.get_param('retirado_en_venta') }
  attribute :calcular_saco,                              if: Proc.new { self.get_param('all') || self.get_param('calcular_saco') }
  attribute :detalle_factura_nota,                       if: Proc.new { self.get_param('all') || self.get_param('detalle_factura_nota') }
  attribute :is_devuelto,                                if: Proc.new { self.get_param('all') || self.get_param('is_devuelto') }
  attribute :is_defectuoso,                              if: Proc.new { self.get_param('all') || self.get_param('is_defectuoso') }

  attribute :articulo,                                   if: Proc.new { self.get_param('all') || self.get_param('articulo') }
  attribute :calcular_itbis,                             if: Proc.new { self.get_param('all') || self.get_param('calcular_itbis') }
  attribute :precio,                                     if: Proc.new { self.get_param('all') || self.get_param('precio') }
  attribute :costo,                                      if: Proc.new { self.get_param('all') || self.get_param('costo') }
  attribute :tipo,                                       if: Proc.new { self.get_param('all') || self.get_param('tipo') }
  attribute :codigo,                                     if: Proc.new { self.get_param('all') || self.get_param('codigo') }
  attribute :descripcion,                                if: Proc.new { self.get_param('all') || self.get_param('descripcion') }
  attribute :unidad,                                     if: Proc.new { self.get_param('all') || self.get_param('unidad') }
  attribute :peso_saco,                                  if: Proc.new { self.get_param('all') || self.get_param('peso_saco') }
  attribute :contenidos,                                 if: Proc.new { self.get_param('all') || self.get_param('contenidos') }
  attribute :articulo_estado,                            if: Proc.new { self.get_param('all') || self.get_param('articulo_estado') }
  attribute :actual_price,                               if: Proc.new { self.get_param('actual_price') }

  def articulo
    # TODO: hacer una peticion para solo buscar el nombre en el historico
    # @articuloSelect     = MantenimientoArticulo.get_one_articulo_by_date(calculateDateUTC(object.cabecera_factura.fecha_equivalente), object.articulo_id)[0]
    articulo_in_detalle = get_param('articulo_in_detalle')
    
    @articuloSelect = object.articulo
    @articuloSelect['nombre']

    if articulo_in_detalle
      serialize_parser(@articuloSelect, { all: true })
    else
      @articuloSelect['nombre']
    end

  end

  def calcular_itbis
    @articuloSelect.calcular_itbis
  end

  def tipo
    @articuloSelect.tipo_articulo.descripcion
  end

  def codigo
    object.articulo.codigo
  end

  def descripcion
    @unidad                     = object.unidad.split(" ")

    if @unidad.length > 1
      descripcion              = " (#{@unidad[2]} LBS) #{@articuloSelect['nombre']}"
      @peso_saco               = @unidad[2]
    else
      descripcion              = "#{@articuloSelect['nombre']}"

      descripcion += " D*" if object.is_defectuoso
    end

    descripcion
  end


  def unidad
    unidad = @unidad[0]
  end

  def peso_saco
    @peso_saco
  end

  def contenidos
    object.articulo.calcularContenidos(true)
  end

  def articulo_estado
    @articuloSelect['estado']
  end

  def actual_price
    costos()
  end

  def costos
    @articuloSelect.costos
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end

end