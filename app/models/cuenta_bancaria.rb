class CuentaBancaria < ApplicationRecord
  belongs_to :banco
  belongs_to :tipo_cuenta_bancaria
  belongs_to :divisa
  belongs_to :cuenta_contable
	belongs_to :cuenta_contable_prima, class_name: 'CuentaContable', optional: true



  # ============================================================================================================================================

  def self.create_update_cuenta_bancaria(params, padre, is_save=false)
    res                                       = Response.new

    padre                                     = Banco.find_by_id(params[:banco_id]) if padre.nil?

    unless padre.nil?

      cuenta_bancaria                         = CuentaBancaria.where(:id => params[:id]).first_or_create

      cuenta_bancaria.banco                   = params[:banco_id]
      cuenta_bancaria.tipo_cuenta_bancaria    = params[:tipo_cuenta_bancaria_id]
      cuenta_bancaria.divisa                  = params[:divisa_id]
      cuenta_bancaria.fecha_apertura          = params[:fecha_apertura]
      cuenta_bancaria.numero_cuenta           = params[:numero_cuenta]
      cuenta_bancaria.comentario              = params[:comentario]
      cuenta_bancaria.descripcion             = params[:descripcion]


      result_procesos                         = cuenta_bancaria.procesos_cuenta(padre)

      cuenta_bancaria.valid?
      cuenta_bancaria.otras_validaciones(params, padre)

      cuenta_bancaria.errors.delete(:banco) if !is_save

      if result_procesos.status_valid && cuenta_bancaria.errors.empty? && (!is_save || (is_save && cuenta_bancaria.save!))
        res.set_data(cuenta_bancaria)
      else
        res.add_msgs(result_procesos.get_msgs)
        res.add_msgs(cuenta_bancaria.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    else
      res.add_msg("El banco que seleccionó para crear esta cuanta, no existe o esta desabilitado.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def procesos_cuenta(padre)
    res = Response.new

    is_cuenta_nacional                = self.divisa.is_principal

    configuraciones_cuentas_contables = get_config_cuenta_entidad("cuenta_bancaria")

    cuentas_contables                 = []

    configuraciones_cuentas_contables.each do | config |
      descripcion_cuenta     = "Banco: #{padre.nombre} - CTA: #{self.numero_cuenta}"

      descripcion_cuenta    += " PRIMA" if !is_cuenta_nacional && config.descripcion.downcase == 'efectivo banco nacional'

      cuenta_contable        = ConfiguracionEntidadCuenta.molde_cuenta(config.cuenta_contable, descripcion_cuenta)

      if (is_cuenta_nacional && config.descripcion.downcase == 'efectivo banco nacional') || (!is_cuenta_nacional)
        cuentas_contables.push(cuenta_contable)
      end
    end

    # Efectivo banco nacional
    # Efectivo banco extranjero




    if result_next_codigo.status_valid && result_next_nivel.status_valid

      self.is_nacional              = is_cuenta_nacional
      self.cuenta_contable          = is_cuenta_nacional
      self.cuenta_contable_prima    = is_cuenta_nacional

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

  def self.validar_e_inicializar(items, padre, save)
    res_valid   = Response.new
    array_valid = []

    items.each do |item|
      res_temp  = self.create_update_cuenta_bancaria(item, padre, !item[:id].nil?)

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
