class EntidadCuentaContable < ApplicationRecord
  self.table_name = "entidad_cuentas_contables"

  belongs_to :cuenta_contable,               optional: true
  belongs_to :configuracion_entidad_cuenta,  optional: false

  belongs_to :origen_categoria,              optional: true,  polymorphic: true
  belongs_to :origen_entidad,                optional: false, polymorphic: true

  validates :tipo_agrupacion_contable, presence:  { :message => "Debe de especificar el tipo de agrupación de la entidad." }, inclusion: { in: TIPOS_DE_AGRUPACIONES_VALIDOS, :message => "El tipo de agrupación seleccionado no es válido." }
  validates :is_comun,                 inclusion: { in: [ true, false ], :message => "Debe de especificar si la cuenta sera común o no." }

  @modelo = {
    tipo_articulo:               TipoArticulo,
    sub_tipo_articulo:           SubTipoArticulo,
    categoria_entidad_contable:  CategoriaEntidadContable
  }.with_indifferent_access


  # ============================================================================================================================================
  def has_cuenta_contable
    return !self.cuenta_contable.nil? && self.cuenta_contable.estado && !self.is_comun
  end
  # ============================================================================================================================================

  def otras_validaciones(params, has_cuenta_contable)
    resultado = { has_error: false }.with_indifferent_access

    if self.is_comun
      if ( params[:tipo_categoria].nil? || params[:tipo_categoria_id].nil? ) && self.tipo_agrupacion_contable != TipoAgrupacionContable.individual
        configuacion          = self.configuracion_entidad_cuenta

        self.errors.add(:base, "Debe de seleccionar la categoria del #{self.origen_entidad_type}, para poder agregarlo a una cuenta común de #{ConfigEntidadCuentaCont::Keys.get_label(configuacion.key)}.")
        resultado[:has_error] = true
      end
    end

    unless params[:id].nil?
      if has_cuenta_contable
        if self.tipo_agrupacion_contable != params[:tipo_agrupacion_contable] || self.is_comun != params[:is_comun] || self.configuracion_entidad_cuenta_id.to_s != params[:configuracion_entidad_cuenta_id].to_s || self.origen_categoria_id.to_s !=  params[:tipo_categoria_id].to_s
          self.errors.add(:base, "No se le pueden cambiar las caracteristicas a una cuenta contable una vez creada.")
          resultado[:has_error] = true
        end
      end
    end

    return resultado
  end

  # ============================================================================================================================================

  def self.crear_actualizar_entidad_cuenta_contable(params, padre, is_save=false)
    res                             = Response.new
    result_procesos                 = Response.new
    categoria_entidad_contable      = nil

    if ( params[:tipo_categoria] && params[:tipo_categoria_id] ) && ( params[:tipo_agrupacion_contable] != TipoAgrupacionContable.individual )
      categoria_entidad_contable    = @modelo[params[:tipo_categoria]].find_by_id(params[:tipo_categoria_id])
    end

    entidad_cuenta                  = EntidadCuentaContable.where(:id => params[:id]).first_or_create
    has_cuenta_contable             = entidad_cuenta.has_cuenta_contable


    if !has_cuenta_contable
      entidad_cuenta.configuracion_entidad_cuenta_id    = params[:configuracion_entidad_cuenta_id]
      entidad_cuenta.tipo_agrupacion_contable           = params[:tipo_agrupacion_contable]
      entidad_cuenta.is_comun                           = params[:is_comun]
      entidad_cuenta.key                                = entidad_cuenta.configuracion_entidad_cuenta.key
      entidad_cuenta.origen_categoria                   = categoria_entidad_contable
      entidad_cuenta.origen_entidad                     = padre
    end

    entidad_cuenta.valid?

    is_valid                                            = entidad_cuenta.otras_validaciones(params, has_cuenta_contable)

    result_procesos                                     = entidad_cuenta.procesos_crear_cuenta(has_cuenta_contable, params) if !is_valid[:has_error] && params[:tipo_agrupacion_contable] != TipoAgrupacionContable.sin_cuenta

    if !is_valid[:has_error] && result_procesos.status_valid && entidad_cuenta.errors.empty? && (!is_save || (is_save && entidad_cuenta.save!))
      res.set_data(entidad_cuenta)
    else
      res.add_msgs(result_procesos.get_msgs.to_a)
      res.add_msgs(entidad_cuenta.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def procesos_crear_cuenta(has_cuenta_contable, params)
    res                         = Response.new
    if self.configuracion_entidad_cuenta.entidad == ConfigEntidadCuentaCont.articulo
      cuenta_contable_art       = self.origen_categoria.tipo_articulo_cuentas_contables.find_by({ key: self.key })
    end

    if self.is_comun

      if self.configuracion_entidad_cuenta.entidad == ConfigEntidadCuentaCont.articulo
        self.cuenta_contable_id = cuenta_contable_art.cuenta_contable_auxiliar_id
      else
        self.cuenta_contable_id = self.origen_categoria.cuenta_contable_auxiliar_id
      end

      return res
    end


    if !has_cuenta_contable
      cuenta_control                     = nil

      if self.configuracion_entidad_cuenta.entidad == ConfigEntidadCuentaCont.articulo
        cuenta_control                   = cuenta_contable_art.cuenta_contable_control
      else
        cuenta_control                   = ( self.tipo_agrupacion_contable == TipoAgrupacionContable.individual ) ? self.configuracion_entidad_cuenta.cuenta_contable : self.origen_categoria.cuenta_contable_control
      end

      res                                = CatEntidadContable.createCuenta(cuenta_control, params[:descripcion_cuenta], false)
      cuenta_contable_control            = res.get_data()
      self.cuenta_contable_id            = cuenta_contable_control[:id] if res.status_valid
    else
      self.cuenta_contable.descripcion   = params[:descripcion_cuenta]
      self.cuenta_contable.save!
    end

    return res
  end

  # ============================================================================================================================================

  def self.validar_e_inicializar(items, padre, save)
    res_valid   = Response.new
    array_valid = []

    items.each do |item|
      res_temp  = self.crear_actualizar_entidad_cuenta_contable(item, padre, save)

      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp
      end

    end
    res_valid.set_data array_valid


    return res_valid
  end

end
