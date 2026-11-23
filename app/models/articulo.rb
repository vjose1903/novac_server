class Articulo < ApplicationRecord
  include ArticuloMedidas
  include ArticuloFiltering

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

  validates :nombre,              presence: { :message => 'Nombre articulo no puede estar vacío.' },         uniqueness: { scope: :estado, case_sensitive: false, :message => 'Articulo ya está registrado' }, :if => :estado
  validates :costo_principal,     presence: { :message => 'El costo del articulo no puede estar vacío.' }
  validates :precio_principal,    presence: { :message => 'El precio del articulo no puede estar vacío.' },  numericality: { greater_than: 0, :message => 'El precio del articulo debe de ser mayor a 0.' }


  def otras_validaciones(params)

    tipo_articulo = TipoArticulo.find_by_id(self.tipo_articulo_id)

    if tipo_articulo.tipo == TipoArticuloType.venta_normal
      self.errors.add(:base, 'Medida articulo no puede estar vacío.')                    if self.medida == nil
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

  def self.create_update_articulo(params, articulo_antiguo, is_save=false)
    res = Response.new
    Articulo.transaction do

      ant_articulo                              =  articulo_antiguo.nil? ? nil : articulo_antiguo
      ant_articulo_contenido                    =  articulo_antiguo.nil? ? nil : articulo_antiguo.contenido_articulos
      ant_articulo_formula                      =  articulo_antiguo.nil? ? nil : articulo_antiguo.formulas_productos_terminados


      articulo                                  = Articulo.where(:id => params[:id]).first_or_initialize

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
      articulo.imagen_id                        = params[:imagen_id]

      articulo.valid?
      articulo.otras_validaciones(params)

      articulo.agregar_cuentas_descuento(params)                           if articulo.errors.empty?

      cuentas_config = { view_prima: false, descripcion_cuenta: articulo.nombre }.with_indifferent_access
      EntCuentaContable.parsear_cuentas_contables(params, cuentas_config, true) if articulo.errors.empty?
      puts " "
      puts " "
      puts " "
      puts "params ".red + " #{params}"
      puts " "
      puts " "
      puts " "
      if articulo.errors.empty?

        dependencias = [
          {modelo: ContenidoArticulo,          key_object: 'contenido_articulos',           padre: articulo},
          {modelo: FormulasProductosTerminado, key_object: 'formulas_productos_terminados', padre: articulo},
        ]

        puts " "
        puts " "
        puts " "
        puts " params[:entidad_cuentas_contables] ".red + " #{params[:entidad_cuentas_contables]}"
        puts " "
        puts " "
        puts " "

        res = crear_actualizar_dependencias(dependencias, params) { |key_object, dependencia_data|
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


  # =====================================================================================================================
  def self.parseal(objeto)

    begin
      att = objeto.attributes
    rescue
      att = objeto
    end

    att = att.first if att.kind_of?(Array)
    id  = att["id"]

    att["contenido_articulos"]           = ContenidoArticulo.where({ articulo_id: id })
    att["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: id })

    tipoArt            = TipoArticulo.find_by_id(objeto["tipo_articulo_id"])
    att["descripcion"] = tipoArt["descripcion"]
    return att
  end
  # =====================================================================================================================
  def self.parsealHistorico(objeto)

    objeto["descripcion"]              = objeto["descripcion"]
    objeto["contenido_articulos"]      = objeto["contenido_articulos"]

    objeto["contenido"]                = calcularContenidos(objeto)
    objeto["cantidades"]               = calcularCantidades(objeto)

    return objeto
  end

  def self.calcularContenidos(articulo, sacos = true )
    contenidos_calculados(articulo, sacos).with_indifferent_access
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
  def self.calcularCantidades(articulo)
    cantidades_calculadas(articulo).with_indifferent_access
  end

end
