class CuentaContable < ApplicationRecord
  belongs_to :grupo_cuenta
  belongs_to :cuenta_control,   class_name: 'CuentaContable', optional: true

  attribute :cuentas_contables
  validates :descripcion,               presence: { message: "Descripción no puede estar vacío" }, uniqueness: { scope: [:estado, :nivel, :cuenta_control], case_sensitive: false, message: ->(object, data) { "La cuenta #{object.descripcion} ya está registrada" } }, if: :estado
  validates :is_control,               inclusion: { in: [ true, false ], :message => "Debe de especificar si es control o auxiliar." }

  # ============================================================================================================================================

  def label
    return "( #{self.codigo} ) - #{self.descripcion}"
  end
  # ============================================================================================================================================

  def self.models_includes
    includes = [ :grupo_cuenta, :cuenta_control ]
    return includes
  end

  # ============================================================================================================================================

  def otras_validaciones(params, grupo_cuenta, cuenta_contable_original)

    unless self.is_control
      cuenta_control          = CuentaContable.find_by({id: self.cuenta_control_id, estado: true})

      self.errors.add(:base, "El origen de la cuenta no puede ser distinto al de su cuenta control.") if cuenta_control.origen != self.origen
      self.errors.add(:base, "El tipo de la cuenta no puede ser distinto al de su cuenta control.")   if cuenta_control.tipo   != self.tipo
    end

    if !self.id.nil? && cuenta_contable_original[:is_control] != self.is_control
      cuentas_contables = CuentaContable.where({cuenta_control_id: self.id})

      if !cuentas_contables.empty?
        msg = params[:is_control] ? "No se puede cambiar a una cuenta control, por que la cuenta: #{cuenta_contable_original[:descripcion]}, ya tiene cuentas auxiliares." : "No se puede cambiar a una cuenta auxiliar, por que la cuenta: #{cuenta_contable_original[:descripcion]}, ya tiene cuentas auxiliares."
        self.errors.add(:base, msg)
      end
    end


  end

  # ============================================================================================================================================

  def self.filtrar( params, parametros_opcionales={} )

    res                   = Response.new
    only_aux              = parametros_opcionales[:"only_aux"]
    only_control          = parametros_opcionales[:"only_control"]
    all_cuentas           = CuentaContable.all.where({ estado: true }).where("#{only_aux ? 'is_control=false' : ''} #{only_control ? 'is_control=true' : ''}").order('codigo ASC').includes(CuentaContable.models_includes)
    filter_target         = params[:filter_target]

    include_fathers_tree  = parametros_opcionales[:include_fathers_tree]

    fathers_tree          = []
    cuentas_selected      = all_cuentas.select { | cuenta | (cuenta.descripcion.downcase.include? filter_target.downcase) || (cuenta.codigo.downcase.include? filter_target.downcase) }

    cuentas_selected.uniq.each {  | cuenta_filtered | CuentaContable.get_fathers_tree(fathers_tree, cuenta_filtered.cuenta_control) unless cuenta_filtered.cuenta_control_id.nil? } if include_fathers_tree

    cuentas_filtered      = [*fathers_tree, *cuentas_selected]

    cuentas_filtered      = cuentas_filtered.select { | cuenta | !cuenta.nil? }.sort_by! { | item | item.codigo }

    if !cuentas_filtered.empty? && cuentas_filtered.length > 0

      cuentas_send        = parametros_opcionales[:"iterator"] ? CatalogoCuenta::CuentaContable.iterator(cuentas_filtered.uniq, parametros_opcionales) : serialize_parser(cuentas_filtered.uniq, parametros_opcionales)

      res.set_data(cuentas_send)
    else
      res.set_data([])
      res.add_msg('No existen cuentas contables con las especificaciones introducidas.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================
  def self.get_fathers_tree(fathers_tree, current_cuenta)

      cuenta_is_pushed = current_cuenta.nil? ? true : fathers_tree.any? { |item| item.id == current_cuenta.id}

      fathers_tree.push(current_cuenta) if !cuenta_is_pushed && !current_cuenta.nil?

      CuentaContable.get_fathers_tree(fathers_tree, current_cuenta.cuenta_control) unless current_cuenta.cuenta_control_id.nil?
  end
  # ============================================================================================================================================

  def self.create_update_cuenta_contable(params, grupo_cuenta, is_save=false)
    res                                  = Response.new

    grupo_cuenta                         = GrupoCuenta.find_by_id(params[:grupo_cuenta_id]) if grupo_cuenta.nil?

    unless grupo_cuenta.nil?
      CuentaContable.transaction do
				puts " "
				puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
				puts "params --> ".red + " #{params.to_json}"
				puts "params[:id] -> (#{params[:id]}) "
				puts "params[:grupo_cuenta_id] -> (#{params[:grupo_cuenta_id]}) "
				puts "params[:cuenta_control_id] -> (#{params[:cuenta_control_id]}) "
				puts " "
        cuenta_contable                    = CuentaContable.where(:id => params[:id]).first_or_create
        cuenta_contable_original           = cuenta_contable.attributes.with_indifferent_access

        params[:descripcion]               = params[:descripcion].upcase   if params[:is_control]
        params[:descripcion]               = params[:descripcion].capitalize if !params[:is_control]

        cuenta_contable.grupo_cuenta_id    = params[:grupo_cuenta_id]
        cuenta_contable.descripcion        = params[:descripcion]
        cuenta_contable.cuenta_control_id  = params[:cuenta_control_id]
        cuenta_contable.origen             = params[:origen]
        cuenta_contable.tipo               = params[:tipo]
        cuenta_contable.is_control         = params[:is_control]

				puts "ANTES DE PROCESOS".yellow
        result_procesos                    = cuenta_contable.procesos_cuentas(grupo_cuenta, params)
				puts "DESPUES DE PROCESOS".yellow

        cuenta_contable.valid?
        cuenta_contable.otras_validaciones(params, grupo_cuenta, cuenta_contable_original)

        cuenta_contable.errors.delete(:grupo_cuenta) if !is_save
				puts " "
				puts "cuenta_contable -->  ".magenta  + " #{cuenta_contable.to_json}"
				puts " "
        if result_procesos.status_valid && cuenta_contable.errors.empty? && (!is_save || (is_save && cuenta_contable.save!))
          res.set_data(cuenta_contable)
        else
          res.add_msgs(result_procesos.get_msgs.to_a)
          res.add_msgs(cuenta_contable.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        transaction_rollback if !cuenta_contable.errors.empty? || !res.status_valid
      end

    else
      res.add_msg("Grupo de cuenta no existe.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def procesos_cuentas(grupo_cuenta, params)
		puts "params --> ".blue + " #{params.to_json}"
		puts "DENTRO DE PROCESOS".yellow
    res = Response.new

    if params[:action] == 'create'
      cuenta_control                   = CuentaContable.find_by({id: self.cuenta_control_id, estado: true}) || nil
      result_next_codigo               = CuentaContable.get_next_cuenta_codigo(self, grupo_cuenta, cuenta_control)
      result_next_nivel                = CuentaContable.get_next_cuenta_nivel(self, cuenta_control)
			puts "cuenta_control --> ".red + " #{cuenta_control.to_json}"
			puts "result_next_codigo --> ".cyan + " #{result_next_codigo.to_json}"
			puts "result_next_nivel --> ".green + " #{result_next_nivel.to_json}"

      if result_next_codigo.status_valid && result_next_nivel.status_valid
				puts "-------------------------------- ENTREEE --------------------------------".yellow
				puts "-------------------------------- ENTREEE --------------------------------".yellow
        self.codigo         = result_next_codigo.get_data
        self.nivel          = result_next_nivel.get_data

      else
        res.add_msgs(result_next_codigo.get_msgs.to_a)
        res.add_msgs(result_next_nivel.get_msgs.to_a)

        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    return res
  end

  # ============================================================================================================================================

  def self.get_next_cuenta_nivel(cuenta_contable, cuenta_control)
    res              = Response.new
    next_nivel       = nil

		puts "cuenta_control --> ".green  + " #{cuenta_control.to_json}"

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
      res.add_msg("Error creando el codigo para la cuenta contable: #{cuenta_contable.descripcion}.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def deactivate_or_reactivate(params, skip_condition=false)
    res         = Response.new

    if  self.cuenta_control.estado || skip_condition

      self.estado = params[:status].to_boolean

      if self.save!
        cuentas_contables = CuentaContable.where({cuenta_control_id: self.id})

        cuentas_contables.each do | cuenta_contable |
          cuenta_contable.deactivate_or_reactivate(params, true) if cuenta_contable.estado != params[:status].to_boolean
        end

        action = params[:status].to_boolean ? 'reactivada' : 'desactivada'

        res.add_msg("Cuenta contable: #{self.descripcion}, #{!cuentas_contables.empty? ? "y sus cuentas auxiliares #{action}s" : action}  correctamente.")
      else
        res.add_msg("Error desactivando la cuenta contable: #{self.descripcion}.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    else

      action = params[:status].to_boolean ? 'reactivar' : 'desactivar'

      res.add_msg("No puede #{action} esta cuenta, por que su cuenta control esta desactivada.")
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
