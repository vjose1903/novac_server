class DetalleFacturaSerializer < ActiveModel::Serializer


  attribute :id,                                         if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :cabecera_factura_id,                        if: Proc.new { self.personalizar_parametros('cabecera_factura_id') || self.personalizar_parametros('all') }
  attribute :articulo_id,                                if: Proc.new { self.personalizar_parametros('articulo_id') || self.personalizar_parametros('all') }
  attribute :total,                                      if: Proc.new { self.personalizar_parametros('total') || self.personalizar_parametros('all') }
  attribute :descuento_valor,                            if: Proc.new { self.personalizar_parametros('descuento_valor') || self.personalizar_parametros('all') }
  attribute :descuento_porciento,                        if: Proc.new { self.personalizar_parametros('descuento_porciento') || self.personalizar_parametros('all') }
  attribute :itbis,                                      if: Proc.new { self.personalizar_parametros('itbis') || self.personalizar_parametros('all') }
  attribute :cantidad,                                   if: Proc.new { self.personalizar_parametros('cantidad') || self.personalizar_parametros('all') }
  attribute :cantidad_en_unidades,                       if: Proc.new { self.personalizar_parametros('cantidad_en_unidades') || self.personalizar_parametros('all') }
  attribute :retirado,                                   if: Proc.new { self.personalizar_parametros('retirado') || self.personalizar_parametros('all') }
  attribute :retirado_en_venta,                          if: Proc.new { self.personalizar_parametros('retirado_en_venta') || self.personalizar_parametros('all') }
  attribute :calcular_saco,                              if: Proc.new { self.personalizar_parametros('calcular_saco') || self.personalizar_parametros('all') }
  attribute :detalle_factura_nota,                       if: Proc.new { self.personalizar_parametros('detalle_factura_nota') || self.personalizar_parametros('all') }
  
  attribute :se_calcula_saco,                            if: Proc.new { self.personalizar_parametros('se_calcula_saco') || self.personalizar_parametros('all') }

  attribute :articulo,                                   if: Proc.new { self.personalizar_parametros('articulo') || self.personalizar_parametros('all') }
  attribute :precio,                                     if: Proc.new { self.personalizar_parametros('precio') || self.personalizar_parametros('all') }
  attribute :costo,                                      if: Proc.new { self.personalizar_parametros('costo') || self.personalizar_parametros('all') }
  attribute :tipo,                                       if: Proc.new { self.personalizar_parametros('tipo') || self.personalizar_parametros('all') }
  attribute :codigo,                                     if: Proc.new { self.personalizar_parametros('codigo') || self.personalizar_parametros('all') }
  attribute :descripcion,                                if: Proc.new { self.personalizar_parametros('descripcion') || self.personalizar_parametros('all') }
  attribute :unidad,                                     if: Proc.new { self.personalizar_parametros('unidad') || self.personalizar_parametros('all') }
  attribute :peso_saco,                                  if: Proc.new { self.personalizar_parametros('peso_saco') || self.personalizar_parametros('all') }

  def articulo
    @articuloSelect     = object.articulo
    continuar           = false
    # continuar           = articuloWasEdited(@articuloSelect)
    
    @articuloSelect     = MantenimientoArticulo.get_one_articulo_by_date(object.cabecera_factura.fecha_equivalente, @articuloSelect["id"])[0] unless continuar
    puts "@articuloSelect:  ".green + "#{@articuloSelect}"
    puts "@articuloSelect:  ".red + "#{@articuloSelect.to_hash}"
    @articuloSelect["nombre"]
  end

  def precio
    @articuloSelect["precio_principal"]
  end

  def costo
    @articuloSelect["costo_principal"]
  end

  def tipo
    object.articulo.tipo_articulo.descripcion
  end

  def se_calcula_saco
    "se_calcula_saco"
  end
  
  def codigo
    @articuloSelect["codigo"]
  end

  def descripcion
    "descripcion"
  end
  
  def unidad
    unidad = object.unidad.split(" ")[0]
  end
  
  def peso_saco
    "peso_saco"
  end

  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end

end