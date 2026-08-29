class DetalleFacturaSerializer < ActiveModel::Serializer
  extend FastSerializer

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

  ALL_OR_FIELD_FIELDS = [:id, :articulo_id, :total, :descuento_valor, :itbis, :cantidad, :cantidad_en_unidades, :retirado, :retirado_en_venta, :calcular_saco, :detalle_factura_nota, :is_devuelto, :is_defectuoso, :articulo, :calcular_itbis, :precio, :costo, :tipo, :codigo, :descripcion, :unidad, :peso_saco, :contenidos, :articulo_estado].freeze

  def articulo
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
    self.class.calcularContenidos(object.articulo, true)
  end

  def articulo_estado
    @articuloSelect['estado']
  end

  def actual_price
    self.class.costos_por_articulo(@articuloSelect)
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  def self.calcularContenidos(articulo, sacos)
    contenido = articulo.contenido_articulos
    contenidos = {}

    if sacos && articulo["vendido_en"] == "Saco" && articulo["calcular_saco"]
      [100, 50, 25].each do |c|
        contenidos["Saco_#{c}"] = c
      end
    end

    articulo['medida']                     = articulo['medida'] == "N/A" || articulo['medida'] == nil ? articulo.tipo_articulo.tipo.titleize : articulo['medida']
    contenidos[articulo["medida"]]         = contenido.length == 0 ? 1 : contenido.first["cantidad"]
    contenidos[contenido.first["medida"]]  = 1 if contenido.length > 0


    if contenido.length == 2

      cantPrincipal = 1
      cantHijo      = 1
      cantPadre     = 1

      contenido.each do |conte|
        cantPrincipal *= conte["cantidad"]
        cantPadre      = conte["cantidad"] if conte["referencia"] != nil
      end

      contenidos[articulo["medida"]]     = cantPrincipal
      contenidos[contenido[0]["medida"]] = cantPadre
      contenidos[contenido[1]["medida"]] = cantHijo
    end
    contenidos
  end

  def self.costos_por_articulo(articulo)
    obj = {}

    obj["#{articulo.medida}"]            = {}
    obj["#{articulo.medida}"]['costo']   = articulo.costo_principal
    obj["#{articulo.medida}"]['precio']  = articulo.precio_principal

    articulo.contenido_articulos.each do |conte|
      obj["#{conte.medida}"]           = {}
      obj["#{conte.medida}"]['costo']  = conte.costo
      obj["#{conte.medida}"]['precio'] = conte.precio
    end

    if articulo.calcular_saco
      [100, 50, 25].each do | peso |
        obj["Saco_#{peso}"]              = {}
        obj["Saco_#{peso}"]['costo']     = (peso / 100.to_f) * obj['Quintal']['costo']
        obj["Saco_#{peso}"]['precio']    = (peso / 100.to_f) * obj['Quintal']['precio']
      end
    end

    obj
  end

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers(params))
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :articulo_id, :total, :descuento_valor, :itbis, :cantidad, :cantidad_en_unidades, :retirado, :retirado_en_venta, :calcular_saco, :detalle_factura_nota, :is_devuelto, :is_defectuoso, :articulo, :calcular_itbis, :precio, :costo, :tipo, :codigo, :descripcion, :unidad, :peso_saco, :contenidos, :articulo_estado, :actual_price]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers(params)
    {
      articulo: ->(record) { params[:articulo_in_detalle] ? ArticuloSerializer.to_hash(record.articulo, {all: true}) : record.articulo['nombre'] },
      calcular_itbis: ->(record) { record.articulo.calcular_itbis },
      tipo: ->(record) { record.articulo.tipo_articulo.descripcion },
      codigo: ->(record) { record.articulo.codigo },
      descripcion: ->(record) {
        unidad_arr = record.unidad.split(" ")
        if unidad_arr.length > 1
          " (#{unidad_arr[2]} LBS) #{record.articulo['nombre']}"
        else
          descripcion = record.articulo['nombre'].to_s
          descripcion += " D*" if record.is_defectuoso
          descripcion
        end
      },
      unidad: ->(record) { record.unidad.split(" ").first },
      peso_saco: ->(record) {
        unidad_arr = record.unidad.split(" ")
        unidad_arr.length > 1 ? unidad_arr[2] : nil
      },
      contenidos: ->(record) { calcularContenidos(record.articulo, true) },
      articulo_estado: ->(record) { record.articulo['estado'] },
      actual_price: ->(record) { costos_por_articulo(record.articulo) }
    }
  end
end
