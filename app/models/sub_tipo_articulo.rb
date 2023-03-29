class SubTipoArticulo < ApplicationRecord
  belongs_to :tipo_articulo
  belongs_to :cuenta_contable_control,   class_name: 'CuentaContable', optional: true
  belongs_to :cuenta_contable_auxiliar,  class_name: 'CuentaContable', optional: true

  validates :descripcion,                presence: { :message => "Descripción de la sub categoria no puede estar vacia." },         uniqueness: { scope: [ :tipo_articulo_id ], case_sensitive: false, :message => "Sub categoria ya está registrada." }

  # ============================================================================================================================================

  def self.create_update_sub_tipo_articulo( params, tipo_articulo)
    res            = Response.new
    tipo_articulo  = TipoArticulo.find_by_id(params[:tipo_articulo_id])

    unless tipo_articulo.nil?
      SubTipoArticulo.transaction do

        sub_tipo_articulo                    = SubTipoArticulo.where(:id => params[:id]).first_or_create
        sub_tipo_articulo.descripcion        = params[:descripcion]
        sub_tipo_articulo.tipo_articulo_id   = params[:tipo_articulo_id]

        result_procesos                      = sub_tipo_articulo.procesos_crear_cuenta(tipo_articulo)

        sub_tipo_articulo.valid?

        if (result_procesos.nil? || result_procesos.status_valid) && sub_tipo_articulo.errors.empty? && sub_tipo_articulo.save!
          res.set_data(sub_tipo_articulo)
        else
          res.add_msgs(result_procesos.get_msgs)
          res.add_msgs(sub_tipo_articulo.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
      end
    else
      res.add_msg("Tipo de articulo, no existe.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end


    return res

  end

  # ============================================================================================================================================

  def procesos_crear_cuenta(tipo_articulo)
    res = Response.new

    descripcion_cuenta                          = self.descripcion
    if self.cuenta_contable_control_id.nil?
      res                                       = CatEntidadContable.createCuenta(tipo_articulo.cuenta_contable_control, descripcion_cuenta, true)
      cuenta_contable_control                   = res.get_data()

      self.cuenta_contable_control_id           = cuenta_contable_control[:id]     if res.status_valid

    else
      self.cuenta_contable_control.descripcion  = descripcion_cuenta.upcase
      self.cuenta_contable_control.save!
    end

    if res.status_valid
      descripcion_cuenta                          = "Común: #{self.descripcion}"
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
