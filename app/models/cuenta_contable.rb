class CuentaContable < ApplicationRecord
  belongs_to :grupo_cuenta

  attribute :cuentas_contables

  validates :descripcion,              presence: { :message => "Descripcion de la cuenta contable no puede estar vacio." },         uniqueness: { scope: [:estado, :nivel, :cuenta_control], case_sensitive: false, :message => "Cuenta contable ya está registrada." }, :if => :estado
  validates :is_control,               inclusion: { in: [ true, false ], :message => "Debe de especificar si es control o auxiliar." }


  def otras_validaciones(params, grupo_cuenta)

    unless self.is_control
      cuenta_control          = CuentaContable.find_by({id: self.cuenta_control, estado: true})

      self.errors.add(:base, "El origen de la cuenta no puede ser distinto al de su cuenta control.") if cuenta_control.origen != self.origen
      self.errors.add(:base, "El tipo de la cuenta no puede ser distinto al de su cuenta control.")   if cuenta_control.tipo   != self.tipo
    end

  end

  # ============================================================================================================================================

  def self.create_update_cuenta_contable(params, grupo_cuenta, is_save=false)
    res                                  = Response.new

    grupo_cuenta                         = GrupoCuenta.find_by_id(params[:grupo_cuenta_id]) if grupo_cuenta.nil?

    unless grupo_cuenta.nil?

      cuenta_contable                    = CuentaContable.where(:id => params[:id]).first_or_create

      params[:descripcion]               = params[:descripcion].upcase if params[:is_control]

      cuenta_contable.grupo_cuenta_id    = params[:grupo_cuenta_id]
      cuenta_contable.descripcion        = params[:descripcion]
      cuenta_contable.cuenta_control     = params[:cuenta_control]
      cuenta_contable.origen             = params[:origen]
      cuenta_contable.tipo               = params[:tipo]
      cuenta_contable.is_control         = params[:is_control]

      result_procesos                    = cuenta_contable.procesos_cuentas(grupo_cuenta)

      cuenta_contable.valid?
      cuenta_contable.otras_validaciones(params, grupo_cuenta)

      cuenta_contable.errors.delete(:grupo_cuenta) if !is_save

      if result_procesos.status_valid && cuenta_contable.errors.empty? && (!is_save || (is_save && cuenta_contable.save!))
        res.set_data(cuenta_contable)
      else
        res.add_msgs(result_procesos.get_msgs)
        res.add_msgs(cuenta_contable.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    else
      res.add_msg("Grupo de cuenta no existe.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def procesos_cuentas(grupo_cuenta)
    res = Response.new
    cuenta_control                   = CuentaContable.find_by({id: self.cuenta_control, estado: true}) || nil
    result_next_codigo               = CuentaContable.get_next_cuenta_codigo(self, grupo_cuenta, cuenta_control)
    result_next_nivel                = CuentaContable.get_next_cuenta_nivel(self, cuenta_control)


    if result_next_codigo.status_valid && result_next_nivel.status_valid
      self.codigo         = result_next_codigo.get_data
      self.nivel          = result_next_nivel.get_data

    else
      res.add_msgs(result_next_codigo.get_msgs)
      res.add_msgs(result_next_nivel.get_msgs)

      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def self.get_next_cuenta_nivel(cuenta_contable, cuenta_control)
    res              = Response.new
    next_nivel       = nil

    next_nivel       = cuenta_contable.cuenta_control.nil? ? NivelesGrupos.mayor : cuenta_control.nivel + 1

    unless next_nivel.nil?
      res.set_data(next_nivel)
    else
      res.add_msg("Error creando el nivel para la cuenta contable: #{cuenta_contable.descripcion}")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def self.get_next_cuenta_codigo(cuenta_contable, grupo_cuenta, cuenta_control)
    res              = Response.new
    next_codigo      = nil

    if cuenta_contable.cuenta_control.nil?
      next_codigo    = grupo_cuenta.grupo.to_s

    else
      cantidad_cuentas   = CuentaContable.where({cuenta_control: cuenta_contable.cuenta_control, estado: true}).count

      if cuenta_control.nivel == NivelesGrupos.mayor
        next_codigo      = "#{(grupo_cuenta.grupo * 100) + (cantidad_cuentas + 1)}"
      else
        next_codigo      = "#{cuenta_control.codigo}-#{("%02d" % (cantidad_cuentas + 1))}"
      end
    end

    unless next_codigo.nil?
      res.set_data(next_codigo)
    else
      res.add_msg("Error creando el codigo para la cuenta contable: #{cuenta_contable.descripcion}")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def self.validar_e_inicializar(items, grupo_cuenta, save)
    res_valid   = Response.new
    array_valid = []

    items.each do |item|
      res_temp  = self.create_update_cuenta_contable(item, grupo_cuenta, !item[:id].nil?)

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
