class CategoriaEntidadContable < ApplicationRecord
  belongs_to :cuenta_contable_control,      class_name: 'CuentaContable', optional: true
  belongs_to :cuenta_contable_auxiliar,     class_name: 'CuentaContable', optional: true
  belongs_to :configuracion_entidad_cuenta

  validates :descripcion,                presence: { :message => "Descripción de la categoria no puede estar vacia." },         uniqueness: { scope:[ :configuracion_entidad_cuenta_id ], case_sensitive: false, :message => "Categoria ya está registrada." }

  def self.create_update_categoria_entidad_contable(params, is_save=false)
    res                     = Response.new

    CategoriaEntidadContable.transaction do
      cat_entidad_cont      = CategoriaEntidadContable.where(:id => params[:id]).first_or_create
      cat_entidad_cont.configuracion_entidad_cuenta_id            = params[:configuracion_entidad_cuenta_id]
      cat_entidad_cont.descripcion                                = params[:descripcion]
      cat_entidad_cont.entidad                                    = cat_entidad_cont.configuracion_entidad_cuenta.entidad
      cat_entidad_cont.key                                        = cat_entidad_cont.configuracion_entidad_cuenta.key
      result_procesos                                             = cat_entidad_cont.procesos_crear_cuenta

      cat_entidad_cont.valid?
      if result_procesos.status_valid && cat_entidad_cont.errors.empty? && (!is_save || (is_save && cat_entidad_cont.save!))

        res.set_data(cat_entidad_cont)

        action = params[:id] ? 'actualizada' : 'creada'
        res.add_msg("Categoria de #{CatEntidadContable.get_tipo_plural(cat_entidad_cont.entidad)} #{action} correctamente.")

      else
        res.add_msgs(result_procesos.get_msgs)
        res.add_msgs(cat_entidad_cont.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
      transaction_rollback if !cat_entidad_cont.errors.empty? || !res.status_valid
    end

    return res

  end

  # ============================================================================================================================================

  def procesos_crear_cuenta
    res = Response.new

    configuracion                               = self.configuracion_entidad_cuenta

    descripcion_cuenta                          = "Categoria: #{self.descripcion}"
    if self.cuenta_contable_control_id.nil?
      res                                       = CatEntidadContable.createCuenta(configuracion.cuenta_contable, descripcion_cuenta, true)
      cuenta_contable_control                   = res.get_data()

      self.cuenta_contable_control_id           = cuenta_contable_control[:id] if res.status_valid

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


end
