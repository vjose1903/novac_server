class TipoArticulo < ApplicationRecord
  belongs_to :cuenta_contable_control,   class_name: 'CuentaContable', optional: true
  belongs_to :cuenta_contable_auxiliar,  class_name: 'CuentaContable', optional: true

	has_many   :entidad_cuentas_contables, :as => :origen_categoria, dependent: :destroy, class_name: 'EntidadCuentaContable'

  validates :descripcion,                presence: { :message => "Descripción de la categoria no puede estar vacia." },         uniqueness: { case_sensitive: false, :message => "Categoria ya está registrada." }

  def self.create_update_tipo_articulo(params, is_save=false)

    res                                = Response.new

    TipoArticulo.transaction do

      tipo_articulo                    = TipoArticulo.where(:id => params[:id]).first_or_create

      tipo_articulo.descripcion        = params[:descripcion]
      tipo_articulo.tipo               = params[:tipo]
      tipo_articulo.codigo             = tipo_articulo.descripcion.downcase.gsub(" ", "_").strip
      result_procesos                  = tipo_articulo.procesos_crear_cuenta

      tipo_articulo.valid?

      if result_procesos.status_valid && tipo_articulo.errors.empty? && (!is_save || (is_save && tipo_articulo.save!))
        res.set_data(tipo_articulo)
      else
        res.add_msgs(result_procesos.get_msgs)
        res.add_msgs(tipo_articulo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    return res

  end

  # ============================================================================================================================================

  def procesos_crear_cuenta
    res = Response.new

    # --------------------------------------------------------------------------------------------------------------
    # INVENTARIO
    # --------------------------------------------------------------------------------------------------------------

    config_inventario                           = ConfiguracionEntidadCuenta.find_by_entidad( "inventario" )

    descripcion_cuenta                          = "Inventario: #{self.descripcion}"
    if self.cuenta_contable_control_id.nil?
      res                                       = CatEntidadContable.createCuenta(config_inventario.cuenta_contable, descripcion_cuenta, true)
      cuenta_contable_control                   = res.get_data()
      self.cuenta_contable_control_id           = cuenta_contable_control[:id] if res.status_valid
    else
      self.cuenta_contable_control.descripcion  = descripcion_cuenta.upcase
      self.cuenta_contable_control.save!
    end

    if res.status_valid
      descripcion_cuenta                          = "Inventario común: #{self.descripcion}"
      if self.cuenta_contable_auxiliar_id.nil?
        res                                       = CatEntidadContable.createCuenta(self.cuenta_contable_control, descripcion_cuenta, false)
        cuenta_contable_auxiliar                  = res.get_data()
        self.cuenta_contable_auxiliar_id          = cuenta_contable_auxiliar[:id]
      else
        self.cuenta_contable_auxiliar.descripcion = descripcion_cuenta
        self.cuenta_contable_auxiliar.save!
      end
    end

    return res
  end

  # ============================================================================================================================================

end
