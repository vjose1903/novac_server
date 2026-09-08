class Articulo < ApplicationRecord
  include ArticuloMedidas
  include ArticuloFiltering

  belongs_to :tipo_articulo
  belongs_to :imagen, optional: true

  has_many :contenido_articulos,           dependent: :destroy
  has_many :formulas_productos_terminados

  attribute :contenido_articulos
  attribute :formulas_productos_terminados

  # has_many :imagen
  accepts_nested_attributes_for :contenido_articulos

  validates :nombre,              presence: { :message => 'Nombre articulo no puede estar vacio.' },         uniqueness: { scope: :estado, case_sensitive: false, :message => 'Articulo ya esta registrado' }, :if => :estado
  validates :costo_principal,     presence: { :message => 'El costo del articulo no puede estar vacio.' }
  validates :precio_principal,    presence: { :message => 'El precio del articulo no puede estar vacio.' },  numericality: { greater_than: 0, :message => 'El precio del articulo debe de ser mayor a 0.' }


  def otras_validaciones(params)

    tipo_articulo = TipoArticulo.find_by_id(self.tipo_articulo_id)

    if tipo_articulo.tipo == TipoArticuloType.venta_normal

      self.errors.add(:base, 'Medida articulo no puede estar vacio.') if self.medida == nil
      self.errors.add(:base, 'Debe de especificar en que medida se vende el articulo.') if self.vendido_en == nil
      self.errors.add(:base, 'Debe de especificar una medida de alerta en venta.') if self.medida_alerta == nil
      self.errors.add(:base, 'El costo del articulo debe de ser mayor a 0.') if self.costo_principal == 0

    end

    if self.medida == 'Caja'

      self.errors.add(:base, 'Los articulos comprados en caja deben de tener la cantidad especificada.') if !params[:contenido_articulos].present? || params[:contenido_articulos].length == 0

      contenido_padre = params[:contenido_articulos].find { | contenido | contenido[:condicion].downcase == 'padre' }
      contenido_hijo  = params[:contenido_articulos].find { | contenido | contenido[:condicion].downcase == 'hijo' }

      self.errors.add(:base, 'Si la caja contiene paquetes debe de especificar cuantas unidades tiene el paquete.') if  (contenido_padre.nil? || !contenido_hijo.nil? ) && ( contenido_padre[:medida].downcase == 'paquete' && params[:contenido_articulos].length == 1 ) || ( contenido_padre[:medida].downcase == 'paquete' && contenido_hijo[:cantidad] == 0 )

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
      articulo.nombre                           = params[:nombre]
      articulo.estado                           = params[:estado]
      articulo.costo_principal                  = params[:costo_principal]
      articulo.precio_principal                 = params[:precio_principal]
      articulo.medida_alerta                    = params[:medida_alerta]
      articulo.existencia                       = params[:existencia]
      articulo.codigo                           = params[:codigo]
      articulo.fecha_ingreso                    = params[:fecha_ingreso]
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

      # imagen_attributes

      if articulo.errors.empty?

        dependencias = [
          {modelo: ContenidoArticulo,          key_object: 'contenido_articulos',           padre: articulo},
          {modelo: FormulasProductosTerminado, key_object: 'formulas_productos_terminados', padre: articulo},
        ]

        res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
          articulo.formulas_productos_terminados   = dependencia_data if key_object == 'formulas_productos_terminados'
          articulo.contenido_articulos             = dependencia_data if key_object == 'contenido_articulos'
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
            action = params['id'] ? 'actualizado' : 'creado'
            res.add_msg("Articulo #{action} correctamente.")
          else
            res.add_msgs(res_historico.get_msgs)
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end

        end

      end

      if !articulo.errors.empty? || !res.status_valid
        res.add_msgs(res.get_msgs.to_a)
        res.add_msgs(articulo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback if !articulo.errors.empty? || !res.status_valid
    end
    return res
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
