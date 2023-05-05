class DetalleFacturaSerializer < ActiveModel::Serializer


  attribute :id,                                         if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :articulo_id,                                if: Proc.new { self.get_param('articulo_id') || self.get_param('all') }
  attribute :total,                                      if: Proc.new { self.get_param('total') || self.get_param('all') }
  attribute :descuento_valor,                            if: Proc.new { self.get_param('descuento_valor') || self.get_param('all') }
  attribute :itbis,                                      if: Proc.new { self.get_param('itbis') || self.get_param('all') }
  attribute :cantidad,                                   if: Proc.new { self.get_param('cantidad') || self.get_param('all') }
  attribute :cantidad_en_unidades,                       if: Proc.new { self.get_param('cantidad_en_unidades') || self.get_param('all') }
  attribute :retirado,                                   if: Proc.new { self.get_param('retirado') || self.get_param('all') }
  attribute :retirado_en_venta,                          if: Proc.new { self.get_param('retirado_en_venta') || self.get_param('all') }
  attribute :calcular_saco,                              if: Proc.new { self.get_param('calcular_saco') || self.get_param('all') }
  attribute :detalle_factura_nota,                       if: Proc.new { self.get_param('detalle_factura_nota') || self.get_param('all') }
  attribute :is_devuelto,                                if: Proc.new { self.get_param('is_devuelto') || self.get_param('all') }
  attribute :is_defectuoso,                              if: Proc.new { self.get_param('is_defectuoso') || self.get_param('all') }

  attribute :articulo,                                   if: Proc.new { self.get_param('articulo') || self.get_param('all') }
  attribute :calcular_itbis,                             if: Proc.new { self.get_param('calcular_itbis') || self.get_param('all') }
  attribute :precio,                                     if: Proc.new { self.get_param('precio') || self.get_param('all') }
  attribute :costo,                                      if: Proc.new { self.get_param('costo') || self.get_param('all') }
  attribute :tipo,                                       if: Proc.new { self.get_param('tipo') || self.get_param('all') }
  attribute :codigo,                                     if: Proc.new { self.get_param('codigo') || self.get_param('all') }
  attribute :descripcion,                                if: Proc.new { self.get_param('descripcion') || self.get_param('all') }
  attribute :unidad,                                     if: Proc.new { self.get_param('unidad') || self.get_param('all') }
  attribute :peso_saco,                                  if: Proc.new { self.get_param('peso_saco') || self.get_param('all') }
  attribute :contenidos,                                 if: Proc.new { self.get_param('contenidos') || self.get_param('all') }
  attribute :articulo_estado,                            if: Proc.new { self.get_param('articulo_estado') || self.get_param('all') }
  attribute :actual_price,                               if: Proc.new { self.get_param('actual_price') }

  def articulo
    # TODO: hacer una peticion para solo buscar el nombre en el historico
    # @articuloSelect     = MantenimientoArticulo.get_one_articulo_by_date(calculateDateUTC(object.cabecera_factura.fecha_equivalente), object.articulo_id)[0]
    @articuloSelect = object.articulo
    @articuloSelect['nombre']

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
      descripcion              = "#{@articuloSelect['nombre']} (#{@unidad[2]} LBS)"
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