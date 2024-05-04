class Articulo < ApplicationRecord
  belongs_to :tipo_articulo
  belongs_to :sub_tipo_articulo, optional: true

  has_many  :contenido_articulos,           dependent: :destroy
  has_many  :formulas_productos_terminados
  has_many  :mantenimiento_articulos

  has_many  :entidad_cuentas_contables,  :as => :origen_entidad, dependent: :destroy, class_name: 'EntidadCuentaContable'
  has_many  :imagenes,                   :as => :origen_img,     dependent: :destroy, class_name: 'Imagen'

  attribute :contenido_articulos
  attribute :formulas_productos_terminados

  accepts_nested_attributes_for :contenido_articulos

  validates :nombre,              presence: { :message => 'Nombre articulo no puede estar vacio.' },         uniqueness: { scope: :estado, case_sensitive: false, :message => 'Articulo ya está registrado' }, :if => :estado
  validates :costo_principal,     presence: { :message => 'El costo del articulo no puede estar vacio.' }
  validates :precio_principal,    presence: { :message => 'El precio del articulo no puede estar vacio.' },  numericality: { greater_than: 0, :message => 'El precio del articulo debe de ser mayor a 0.' }


  def otras_validaciones(params)

    tipo_articulo = TipoArticulo.find_by_id(self.tipo_articulo_id)

    if tipo_articulo.tipo == TipoArticuloType.venta_normal
      self.errors.add(:base, 'Medida articulo no puede estar vacio.')                    if self.medida == nil
      self.errors.add(:base, 'Debe de especificar en que medida se vende el articulo.')  if self.vendido_en == nil
      self.errors.add(:base, 'Debe de especificar una medida de alerta en venta.')       if self.medida_alerta == nil
      self.errors.add(:base, 'El costo del articulo debe de ser mayor a 0.')             if self.costo_principal == 0
    end

    if self.medida == 'Caja'

      self.errors.add(:base, 'Los articulos comprados en caja deben de tener la cantidad especificada.') if !params.has_key?(:contenido_articulos) || params[:contenido_articulos].length == 0

      contenido_padre = params[:contenido_articulos].find { | contenido | contenido[:condicion].downcase == 'padre' }
      contenido_hijo  = params[:contenido_articulos].find { | contenido | contenido[:condicion].downcase == 'hijo' }
      self.errors.add(:base, 'Si la caja contiene paquetes debe de especificar cuantas unidades tiene el paquete.') if  (contenido_padre.nil? || !contenido_hijo.nil? ) && ( contenido_padre[:medida].downcase == 'paquete' && params[:contenido_articulos].length == 1 ) || ( contenido_padre[:medida].downcase == 'paquete' && contenido_hijo[:cantidad] == 0 )

    end


    articulo_configs   = ConfiguracionEntidadCuenta.where(:entidad => ConfigEntidadCuentaCont.articulo)
    cantidad_cuentas   = articulo_configs.length - 2

    if !params.has_key?(:cuentas_contables) || params[:cuentas_contables].nil? || ( params[:cuentas_contables].length <  cantidad_cuentas )
      self.errors.add(:base, 'Debe de especificar todos los atributos para cuentas contables.')
    end

  end

  def self.models_includes
    includes = [
      :mantenimiento_articulos,
      { tipo_articulo: :sub_tipo_articulo },
      { sub_tipo_articulo: :tipo_articulo },
      { contenido_articulos: :articulo },
      { formulas_productos_terminados: { articulo: { contenido_articulos: :articulo }, articulo_combo: { contenido_articulos: :articulo } } },
      { entidad_cuentas_contables: [ :cuenta_contable, :configuracion_entidad_cuenta, :origen_categoria ] }
    ]
    return includes
  end

  def self.create_update_articulo(params, articulo_antiguo, is_save=false)
    res = Response.new
    Articulo.transaction do

      ant_articulo                              =  articulo_antiguo.nil? ? nil : articulo_antiguo
      ant_articulo_contenido                    =  articulo_antiguo.nil? ? nil : articulo_antiguo.contenido_articulos
      ant_articulo_formula                      =  articulo_antiguo.nil? ? nil : articulo_antiguo.formulas_productos_terminados


      articulo                                  = Articulo.where(:id => params[:id]).first_or_create

      articulo.tipo_articulo_id                 = params[:tipo_articulo_id]
      articulo.sub_tipo_articulo_id             = params[:sub_tipo_articulo_id]
      articulo.nombre                           = params[:nombre]
      articulo.estado                           = params[:estado]
      articulo.costo_principal                  = params[:costo_principal]
      articulo.precio_principal                 = params[:precio_principal]
      articulo.medida_alerta                    = params[:medida_alerta]
      articulo.existencia                       = params[:existencia]
      articulo.codigo                           = params[:codigo]
      articulo.fecha_ingreso                    = params[:fecha_ingreso] if params[:id].nil?
      articulo.medida                           = params[:medida]
      articulo.is_detallable                    = params[:is_detallable]
      articulo.aviso_existencia                 = params[:aviso_existencia]
      articulo.calcular_itbis                   = params[:calcular_itbis]
      articulo.is_combo                         = params[:is_combo]
      articulo.otros_costos                     = params[:otros_costos]
      articulo.vendido_en                       = params[:vendido_en]
      articulo.is_materia_prima                 = params[:is_materia_prima]
      articulo.calcular_saco                    = params[:calcular_saco]

      articulo.valid?
      articulo.otras_validaciones(params)

      articulo.agregar_cuentas_descuento(params)                           if articulo.errors.empty?

      cuentas_config = { view_prima: false, descripcion_cuenta: articulo.nombre }.with_indifferent_access
      EntCuentaContable.parsear_cuentas_contables(params, cuentas_config ) if articulo.errors.empty?

      if articulo.errors.empty?

        dependencias = [
          { modelo: ContenidoArticulo,          key_object: 'contenido_articulos',           padre: articulo },
          { modelo: FormulasProductosTerminado, key_object: 'formulas_productos_terminados', padre: articulo },
          { modelo: EntidadCuentaContable,      key_object: 'entidad_cuentas_contables',     padre: articulo },
          { modelo: Imagen,                     key_object: 'imagenes',                      padre: articulo }
        ]

        res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
          articulo.formulas_productos_terminados   = dependencia_data if key_object == 'formulas_productos_terminados'
          articulo.contenido_articulos             = dependencia_data if key_object == 'contenido_articulos'
          articulo.entidad_cuentas_contables       = dependencia_data if key_object == 'entidad_cuentas_contables'
          articulo.imagenes                        = dependencia_data if key_object == 'imagenes'
        }

        res = articulo.set_contenido_referencia_and_codigo() if res.status_valid && articulo.errors.empty? && articulo.save!


        if res.status_valid

          if ant_articulo.nil?
            ant_articulo                = articulo
            ant_articulo_contenido      = ant_articulo.contenido_articulos
            ant_articulo_formula        = ant_articulo.formulas_productos_terminados
          end

          res_historico = MantenimientoArticulo.add_historico(ant_articulo, ant_articulo_contenido, ant_articulo_formula)

          if res_historico.status_valid

            res.set_data(articulo)
            action = params[:id] ? 'actualizado' : 'creado'
            res.add_msg("Articulo #{action} correctamente.")
          else
            res.add_msgs(res_historico.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end

        end

      end

      if !articulo.errors.empty? || !res.status_valid
        res.add_msgs(res.get_msgs.to_a)
        res.add_msgs(articulo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !articulo.errors.empty? || !res.status_valid
    end
    return res
  end

  # =====================================================================================================================

  def agregar_cuentas_descuento(params)
    if params[:id].nil? || !params.has_key?(:id)
      articulo_configs   = ConfiguracionEntidadCuenta.where(:entidad => ConfigEntidadCuentaCont.articulo).where("key IN ('descuento_ventas','descuento_compras')")

      articulo_configs.each do | config |

          argumentos = { tipo_articulo_id: params[:tipo_articulo_id], tipo_categoria: "tipo_articulo", tipo_agrupacion_contable: "categoria", is_comun: true, configuracion_entidad_cuenta_id: config.id }.with_indifferent_access
          Articulo.push_cuentas(params, argumentos)

      end

    else

      articulo_cuentas_Descuentos   = self.entidad_cuentas_contables.where("key IN ('descuento_ventas','descuento_compras')")
      articulo_cuentas_Descuentos.each do | cuenta |

        argumentos = {id: cuenta.id, tipo_articulo_id: params[:tipo_articulo_id], tipo_categoria: "tipo_articulo", tipo_agrupacion_contable: "categoria", is_comun: cuenta.is_comun, configuracion_entidad_cuenta_id: cuenta.configuracion_entidad_cuenta_id }.with_indifferent_access
        Articulo.push_cuentas(params, argumentos)

      end

    end
  end


  # =====================================================================================================================

  def self.push_cuentas(params, args)

    config_descuento = {
      id:                                args[:id] || nil,
      tipo_categoria_id:                 args[:tipo_articulo_id],
      tipo_categoria:                    args[:tipo_categoria],
      tipo_agrupacion_contable:          args[:tipo_agrupacion_contable],
      is_comun:                          args[:is_comun],
      configuracion_entidad_cuenta_id:   args[:configuracion_entidad_cuenta_id],
    }.with_indifferent_access

    params[:cuentas_contables].push(config_descuento)

  end

  # =====================================================================================================================

  def set_contenido_referencia_and_codigo
    res = Response.new
    self.contenido_articulos.last.referencia    = self.contenido_articulos.first.id if self.contenido_articulos.length > 1
    self.codigo                                 = "%05d" % self.id.to_s

    unless self.save! && (self.contenido_articulos.last.nil? || (!self.contenido_articulos.last.nil? && self.contenido_articulos.last.save!))
      res.add_msgs(self.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =====================================================================================================================


  def self.filtrarArticulo(params, parametros_opcionales=nil)
    res              = Response.new(set_paginate_options(params))
    arg              = params[:arg]
    fecha            = "#{params[:fecha]}:00"
    is_compra        = params[:is_compra].to_boolean
    signo            = is_compra ? "!=" : "="
    codigo_tipo      = is_compra ? TipoArticulos.producto_terminado : params[:tipo]

    where            = "lower(tipo_articulos.descripcion || ' ' || articulos.nombre || ' ' || articulos.codigo ) like lower('%#{arg}%') AND articulos.estado = true "

    where += "AND tipo_articulos.codigo #{signo} '#{codigo_tipo}' #{ is_compra ? "AND tipo_articulos.tipo != '#{TipoArticuloType.servicio}'" : ""} " if params[:tipo] != 'todos' || is_compra

    where += 'OR ( articulos.is_materia_prima = true AND articulos.estado = true) ' if params[:tipo] == TipoArticulos.materia_prima

    articulos_ = Articulo
    .joins('inner join tipo_articulos on articulos.tipo_articulo_id = tipo_articulos.id')
    .where(where).includes(Articulo.models_includes)
    .order('articulos.id ASC')

    articulos = []
    historicos = []
    articulos_.map { | articulo |

      fecha_ultima_edicion_articulo = calculateDateUTC(articulo['updated_at']).slice(0,17)
      fecha_ultima_edicion_articulo = "#{fecha_ultima_edicion_articulo}00"
      puts "AQUIIII".yellow

      if fecha < fecha_ultima_edicion_articulo

        hist = MantenimientoArticulo.get_historico_by_date_mayor_or_menor(fecha, articulo.id, '<=', 'DESC')

        if hist.blank?
          puts "NO HISTORICO".red
          articulos.push(articulo)
          historicos.push(articulo)
        else
          puts "SI HISTORICO".green
          historico = MantenimientoArticulo.crearArticuloHistorico(hist.first, articulo)
          historicos.push(historico)
          # TODO: aqui se estan borrando las formulas
          articulos.push(Articulo.new(historico))
        end
      else
        puts "articulo --> ".green + " #{articulo.to_json}"
        articulos.push(articulo)
        historicos.push(articulo)
      end

    }

    if articulos.length > 0

      articulos = params[:paginado].to_boolean ? articulos : articulos.to_activerecord_relation.includes(Articulo.models_includes)
      res.set_data(articulos, { all: true, historicos: historicos, **parametros_opcionales }, Articulo.models_includes)
      # res.set_data(articulos)
    else
      cantidad_registros = Articulo.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen articulos registrados.' : 'No existen articulos con las especificaciones introducidas.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

	# =====================================================================================================================

  def calcularContenidos(sacos = true)

    contenido = self.contenido_articulos
    contenidos = {}

    if sacos && self['vendido_en'] == 'Saco' && self['calcular_saco']
      [100, 50, 25].each do |c|
        contenidos["Saco_#{c}"] = c
      end
    end

    self['medida']                         = self['medida'] == 'N/A' || self['medida'] == nil ? self.tipo_articulo.tipo.capitalize : self['medida']
    contenidos[self["medida"]]             = contenido.length == 0 ? 1 : contenido.first['cantidad']
    contenidos[contenido.first["medida"]]  = 1 if contenido.length > 0

    if contenido.length == 2

      cantPrincipal = 1
      cantHijo      = 1
      cantPadre     = 1

      contenido.each do |conte|
        cantPrincipal *= conte['cantidad']
        cantPadre      = conte['cantidad'] if conte['referencia'] != nil
      end

      contenidos[self['medida']]         = cantPrincipal
      contenidos[contenido[0]['medida']] = cantPadre
      contenidos[contenido[1]['medida']] = cantHijo
    end
    contenidos.with_indifferent_access
  end

  # =====================================================================================================================

  def self.get_actual_price_detalles(params, parametros_opcionales)
    res                = Response.new()
    ids                = params[:ids].split(',').map(&:to_i)

    articulos          = Articulo.where(id: ids).includes(Articulo.models_includes)

    res.set_data( articulos, { **parametros_opcionales } )

    return res
  end

  # =====================================================================================================================

	def costos
    obj = {}

    obj["#{self.medida}"]              = {}
    obj["#{self.medida}"]['costo']     = self.costo_principal
    obj["#{self.medida}"]['precio']    = self.precio_principal

    self.contenido_articulos.each do |conte|
      obj["#{conte.medida}"]           = {}
      obj["#{conte.medida}"]['costo']  = conte.costo
      obj["#{conte.medida}"]['precio'] = conte.precio
    end

    if self.calcular_saco
      [100, 50, 25].each do | peso |
        obj["Saco_#{peso}"]            = {}
        obj["Saco_#{peso}"]['costo']   = (peso / 100.to_f) * obj['Quintal']['costo']
        obj["Saco_#{peso}"]['precio']  = (peso / 100.to_f) * obj['Quintal']['precio']
      end
    end

    obj
  end

  # =====================================================================================================================

  def calcularCantidades
    contenido  = self.contenido_articulos
    existencia = self['existencia'].nil? ? 0 : self['existencia']
    cantidades = {}

    self['medida']                         = self['medida'] == 'N/A' || self['medida'] == nil ? self.tipo_articulo.tipo.capitalize : self['medida']
    cantidades[self['medida']]             = contenido.length == 0 ? existencia : (existencia / contenido.first['cantidad'])
    cantidades[contenido.first['medida']]  = existencia if contenido.length > 0

    if contenido.length == 2

      maxCant   = 1
      cantPadre = 1

      contenido.each do |conte|
        maxCant   = conte['cantidad'] * maxCant
        cantPadre = conte['cantidad'] if conte['condicion'] == 'hijo'
      end

      cantidades[self['medida']]         = (existencia / maxCant)
      cantidades[contenido[0]['medida']] = (existencia / cantPadre)
      cantidades[contenido[1]['medida']] = existencia
    end

    return cantidades.with_indifferent_access
  end

end
