class EntidadCuentaContable < ApplicationRecord
  self.table_name = "entidad_cuentas_contables"

  belongs_to :cuenta_contable
  belongs_to :origen_entidad,   polymorphic: true
  belongs_to :origen_categoria, polymorphic: true
  belongs_to :configuracion_entidad_cuenta


  validates :tipo_agrupacion_contable, presence: { :message => "Debe de especificar el tipo de agrupación de la entidad." }, inclusion: { in: TIPOS_DE_AGRIPACIONES_VALIDOS, :message => "El tipo de agrupación seleccionado no es válido." }

  @modelo = {
    tipo_articulo:               TipoArticulo,
    sub_tipo_articulo:           SubTipoArticulo,
    categoria_entidad_contable:  CategoriaEntidadContable
  }

  def self.crear_actualizar_entidad_cuenta_contable(params, padre, is_save=false)
    res                             = Response.new
    categoria_entidad_contable      = nil

    if params[:tipo_categoria] && params[:tipo_categoria_id]
      categoria_entidad_contable    = @modelo[params[:tipo_categoria]].find_by_id(params[:tipo_categoria_id])
    end

    entidad_cuenta                  = EntidadCuentaContable.where(:id => params[:id]).first_or_create

    entidad_cuenta.configuracion_entidad_cuenta_id    = params[:configuracion_entidad_cuenta_id]
    entidad_cuenta.tipo_agrupacion_contable           = params[:tipo_agrupacion_contable]
    entidad_cuenta.key                                = entidad_cuenta.configuracion_entidad_cuenta.key
    entidad_cuenta.origen_categoria                   = categoria_entidad_contable
    entidad_cuenta.origen_entidad                     = padre
    result_procesos                                   = entidad_cuenta.procesos_crear_cuenta if params[:tipo_agrupacion_contable] != TipoAgrupacionContable.sin_cuenta

    entidad_cuenta.valid?

    if entidad_cuenta.errors.empty? && (!is_save || (is_save && entidad_cuenta.save!))
      res.set_data(entidad_cuenta)
    else
      res.add_msgs(entidad_cuenta.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def procesos_crear_cuenta
    res = Response.new

    # TODO: seguir aqui
    configuracion                               = self.configuracion_entidad_cuenta


    TipoAgrupacionContable.tipo !=

    self.tipo_agrupacion_contable


    descripcion_cuenta                          = "Categoria: #{self.descripcion}"
    if self.cuenta_contable_control_id.nil?
      res                                       = CatEntidadContable.createCuenta(configuracion.cuenta_contable, descripcion_cuenta, true)
      cuenta_contable_control                   = res.get_data()

      self.cuenta_contable           = cuenta_contable_control[:id] if res.status_valid

    else
      self.cuenta_contable_control.descripcion  = descripcion_cuenta.upcase
      self.cuenta_contable_control.save!
    end

    if res.status_valid
      descripcion_cuenta                        = "Común: #{self.descripcion}"
      if self.cuenta_contable_auxiliar_id.nil?
        res                                     = CatEntidadContable.createCuenta(self.cuenta_contable_control, descripcion_cuenta, false)
        cuenta_contable_auxiliar                = res.get_data()
        self.cuenta_contable_auxiliar_id        = cuenta_contable_auxiliar[:id]
      else
        self.cuenta_contable_auxiliar.descripcion = descripcion_cuenta
        self.cuenta_contable_auxiliar.save!
      end
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
