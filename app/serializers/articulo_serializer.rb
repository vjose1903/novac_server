class ArticuloSerializer < ActiveModel::Serializer
  attribute :id
  attribute :tipo_articulo_id,                   if: Proc.new { self.get_param('tipo_articulo_id')           || self.get_param('all') }
  attribute :sub_tipo_articulo_id,               if: Proc.new { self.get_param('sub_tipo_articulo_id')       || self.get_param('all') }
  attribute :nombre,                             if: Proc.new { self.get_param('nombre')                     || self.get_param('all') }
  attribute :costo_principal,                    if: Proc.new { self.get_param('costo_principal')            || self.get_param('all') }
  attribute :precio_principal,                   if: Proc.new { self.get_param('precio_principal')           || self.get_param('all') }
  attribute :existencia,                         if: Proc.new { self.get_param('existencia')                 || self.get_param('all') }
  attribute :aviso_existencia,                   if: Proc.new { self.get_param('aviso_existencia')           || self.get_param('all') }
  attribute :codigo,                             if: Proc.new { self.get_param('codigo')                     || self.get_param('all') }
  attribute :fecha_ingreso,                      if: Proc.new { self.get_param('fecha_ingreso')              || self.get_param('all') }
  attribute :medida,                             if: Proc.new { self.get_param('medida')                     || self.get_param('all') }
  attribute :is_detallable,                      if: Proc.new { self.get_param('is_detallable')              || self.get_param('all') }
  attribute :medida_alerta,                      if: Proc.new { self.get_param('medida_alerta')              || self.get_param('all') }
  attribute :calcular_itbis,                     if: Proc.new { self.get_param('calcular_itbis')             || self.get_param('all') }
  attribute :estado,                             if: Proc.new { self.get_param('estado')                     || self.get_param('all') }
  attribute :is_combo,                           if: Proc.new { self.get_param('is_combo')                   || self.get_param('all') }
  attribute :otros_costos,                       if: Proc.new { self.get_param('otros_costos')               || self.get_param('all') }
  attribute :vendido_en,                         if: Proc.new { self.get_param('vendido_en')                 || self.get_param('all') }
  attribute :is_materia_prima,                   if: Proc.new { self.get_param('is_materia_prima')           || self.get_param('all') }

  attribute :contenido_articulos,                if: Proc.new { self.get_param('contenido_articulos')        || self.get_param('costos') || self.get_param('all') }
  attribute :formulas_productos_terminados,      if: Proc.new { object.is_combo && (self.get_param('formulas_productos_terminados')      || self.get_param('all')) }

  attribute :descripcion,                        if: Proc.new { self.get_param('descripcion')                || self.get_param('all') }
  attribute :contenido,                          if: Proc.new { self.get_param('contenido')                  || self.get_param('all') }
  attribute :cantidades,                         if: Proc.new { self.get_param('cantidades')                 || self.get_param('all') }
  attribute :calcular_saco,                      if: Proc.new { self.get_param('calcular_saco')              || self.get_param('all') }

  attribute :costos,                             if: Proc.new { self.get_param('costos')                     || self.get_param('all') }
  attribute :tipo_articulo,                      if: Proc.new { self.get_param('tipo_articulo')              || self.get_param('all')}
  attribute :sub_tipo_articulo,                  if: Proc.new { self.get_param('sub_tipo_articulo')          || self.get_param('all')}

  attribute :cuentas_contables,                  if: Proc.new { self.get_param('cuentas_contables') }


  def medida
    object.medida || 'N/A'
  end

  def otros_costos
    object.otros_costos || 0
  end

  def precio_principal
    object.precio_principal
  end

  def contenido_articulos
    contenido = getContentHistorico('contenidos')

    serialize_parser(contenido, {all: true})
  end

  def formulas_productos_terminados
    formulas = getContentHistorico('formulas')
    serialize_parser(formulas, {all: true})
  end

  def descripcion
    object.tipo_articulo.descripcion
  end

  def contenido
    object.calcularContenidos(true)
  end

  def cantidades
    object.calcularCantidades
  end

  def cuentas_contables
    serialize_parser(object.entidad_cuentas_contables, { id: true, key: true, tipo_agrupacion_contable: true, cuenta_contable: true, is_comun: true, origen_categoria: true, configuracion_entidad_cuenta_id: true })
  end

  def costos
    object.costos
  end

  def getContentHistorico(tipo)

    historicos  = self.get_param('historicos')
    content     = nil

    if historicos.blank? || historicos.empty?
      content = object.contenido_articulos           if tipo == 'contenidos'
      content = object.formulas_productos_terminados if tipo == 'formulas'
    else

      articulo  = historicos.find  { |item| item['id'] == object.id }
      content = articulo['contenido_articulos'] || articulo.contenido_articulos                     if tipo == 'contenidos'
      content = articulo['formulas_productos_terminados'] || articulo.formulas_productos_terminados if tipo == 'formulas'
    end

    return content
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end