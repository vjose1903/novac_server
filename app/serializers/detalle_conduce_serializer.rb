class DetalleConduceSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :cabecera_conduce_id,                if: Proc.new { self.personalizar_parametros('cabecera_conduce_id') || self.personalizar_parametros('all') }
  attribute :detalle_factura_id,                 if: Proc.new { self.personalizar_parametros('detalle_factura_id') || self.personalizar_parametros('all') }
  attribute :articulo_id,                        if: Proc.new { self.personalizar_parametros('articulo_id') || self.personalizar_parametros('all') }
  attribute :cantidad,                           if: Proc.new { self.personalizar_parametros('cantidad') || self.personalizar_parametros('all') }
	attribute :cantidad_en_unidades,               if: Proc.new { self.personalizar_parametros('cantidad_en_unidades') || self.personalizar_parametros('all') }
  
	attribute :articulo,                           if: Proc.new { self.personalizar_parametros('articulo') || self.personalizar_parametros('all') }
  attribute :descripcion,                        if: Proc.new { self.personalizar_parametros('descripcion') || self.personalizar_parametros('all') }
  attribute :unidad,                             if: Proc.new { self.personalizar_parametros('unidad') || self.personalizar_parametros('all') }
	attribute :peso_saco,                          if: Proc.new { self.personalizar_parametros('peso_saco') || self.personalizar_parametros('all') }
  
  def articulo
    object.articulo.nombre
  end
  
  def descripcion
    @unidad_en_turno          = object.unidad.split(" ")

    descripcion               = @unidad_en_turno.length > 1 ? "#{object.articulo.nombre} (#{@unidad_en_turno[2]} LBS)" : object.articulo.nombre
  end
  
  def unidad
    object.unidad             = @unidad_en_turno.length > 1  ? @unidad_en_turno[0] : object.unidad
  end
  
  def peso_saco
    peso_saco                 = @unidad_en_turno.length > 1 ? @unidad_en_turno[2] : nil
  end
	
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
