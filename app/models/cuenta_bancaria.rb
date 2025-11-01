class CuentaBancaria < ApplicationRecord
  belongs_to :banco
  belongs_to :tipo_cuenta_bancaria
  belongs_to :divisa
  belongs_to :cuenta_contable,           dependent: :destroy
  belongs_to :cuenta_contable_prima,     dependent: :destroy, class_name: 'CuentaContable', optional: true

  has_one    :secuencia_documento,       dependent: :destroy, class_name: 'SecuenciaDocumento', :as => :origen_secuencia

  validates :banco,                  presence: { :message => "Debe de seleccionar el banco al cual agregar la cuenta." }
  validates :tipo_cuenta_bancaria,   presence: { :message => "Debe de seleccionar el tipo de cuenta de la cuenta." }
  validates :divisa,                 presence: { :message => "Debe de seleccionar la divisa de la cuenta." }
  validates :descripcion,            presence: { :message => "Descripcion de la cuenta no puede estar vacío." }
  validates :numero_cuenta,          presence: { :message => "Número de la cuenta no puede estar vacío." },         uniqueness: { scope: [:estado, :banco_id], case_sensitive: false, :message => "Número de cuenta esta registrado en otra cuenta." }, :if => :estado

  # ============================================================================================================================================

  def self.models_includes
    includes = [ :tipo_cuenta_bancaria, :divisa, :cuenta_contable, :cuenta_contable_prima ]
    return includes
  end

  # ============================================================================================================================================

  def info_completa
    info    = self.banco.nombre
    info    += ": #{self.numero_cuenta}"
    info    = info.gsub('  ',' ').strip
    info
  end

  # ============================================================================================================================================

  def self.create_update_cuenta_bancaria(params, banco, is_save=false)
    res                                            = Response.new

    banco                                          = Banco.find_by_id(params[:banco_id]) if banco.nil?

    if !banco.nil? && banco.estado
      CuentaBancaria.transaction do

        cuenta_bancaria                            = CuentaBancaria.where(:id => params[:id]).first_or_create
        cuenta_bancaria_original                   = cuenta_bancaria.attributes.with_indifferent_access if params.obj_has?(:id)

        cuenta_bancaria.banco_id                   = params[:banco_id]                    if params.obj_has?(:banco_id)
        cuenta_bancaria.tipo_cuenta_bancaria_id    = params[:tipo_cuenta_bancaria_id]     if params.obj_has?(:tipo_cuenta_bancaria_id)
        cuenta_bancaria.divisa_id                  = params[:divisa_id]                   if params.obj_has?(:divisa_id)
        cuenta_bancaria.fecha_apertura             = params[:fecha_apertura]              if params.obj_has?(:fecha_apertura)
        cuenta_bancaria.numero_cuenta              = params[:numero_cuenta]               if params.obj_has?(:numero_cuenta)
        cuenta_bancaria.balance_inicial_libro      = params[:balance_inicial_libro]       if params.obj_has?(:balance_inicial_libro)
        cuenta_bancaria.balance_inicial_banco      = params[:balance_inicial_banco]       if params.obj_has?(:balance_inicial_banco)
        cuenta_bancaria.comentario                 = params[:comentario]                  if params.obj_has?(:comentario)
        cuenta_bancaria.descripcion                = params[:descripcion]                 if params.obj_has?(:descripcion)
        cuenta_bancaria.has_chequera               = params[:has_chequera]                if params.obj_has?(:has_chequera)
        cuenta_bancaria.fecha_primera_conciliacion = params[:fecha_primera_conciliacion]  if params.obj_has?(:fecha_primera_conciliacion)


        result_procesos                            = cuenta_bancaria.procesos_crear_cuenta(banco)  unless params.obj_has?(:id)
        result_procesos                            = cuenta_bancaria.procesos_update_cuenta(cuenta_bancaria_original, params) if params.obj_has?(:id)

        cuenta_bancaria.valid?

        cuenta_bancaria.errors.delete(:banco) if !is_save

        if result_procesos.status_valid && cuenta_bancaria.errors.empty?

          params[:secuencia_documento] = {} if cuenta_bancaria.has_chequera && cuenta_bancaria.secuencia_documento.nil?

          dependencies = [
            { modelo: SecuenciaDocumento,         key_object: "secuencia_documento",           origin: cuenta_bancaria }
          ]

          res = crear_actualizar_dependencias(dependencies, params) { | key_object, dependency_data |
            cuenta_bancaria.secuencia_documento    = dependency_data if key_object == 'secuencia_documento'
          }

          if res.status_valid && (!is_save || (is_save && cuenta_bancaria.save!))
            res.set_data(cuenta_bancaria)
          end
        end

        unless result_procesos.status_valid
          res.add_msgs(result_procesos.get_msgs.to_a)
          res.set_status(HTTP_STATUS.conflict)
        end

        res.manage_error_transaction(cuenta_bancaria)
      end

    else

      res.add_msg("El banco que seleccionó para crear esta cuanta, no existe.")         if banco.nil?
      res.add_msg("El banco que seleccionó para crear esta cuanta, está destabilisation.") if !banco.nil? && !banco.estado
      res.set_status(HTTP_STATUS.conflict)
    end

    return res
  end

  # ============================================================================================================================================

  def procesos_crear_cuenta(banco)
    res = Response.new

    is_cuenta_nacional                = self.divisa.is_principal

    configuraciones_cuentas_contables = ConfiguracionEntidadCuenta.where({ entidad: ConfigEntidadCuentaCont.cuenta_bancaria })

    configuraciones_cuentas_contables.each do | config |
      is_prima               = !is_cuenta_nacional && config.is_nacional

      descripcion_cuenta     = "#{banco.nombre} - CTA: #{self.numero_cuenta}"
      descripcion_cuenta    += " PRIMA" if is_prima

      cuenta_contable        = ConfiguracionEntidadCuenta.molde_cuenta(config.cuenta_contable, descripcion_cuenta)

      if (is_cuenta_nacional && config.is_nacional) || (!is_cuenta_nacional)

        temp_cuenta_contable              = CuentaContable.create_update_cuenta_contable(cuenta_contable, nil, true)
        if temp_cuenta_contable.status_valid
          cuenta_contable                 = temp_cuenta_contable.get_data.as_json.with_indifferent_access
          self.cuenta_contable_id         = cuenta_contable[:id] if !is_prima
          self.cuenta_contable_prima_id   = cuenta_contable[:id] if is_prima

        else
          res.add_msgs(temp_cuenta_contable.get_msgs.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      end
    end

    self.is_nacional = is_cuenta_nacional

    return res
  end

  # ============================================================================================================================================
  def procesos_update_cuenta(cuenta_bancaria_original, params)
    res = Response.new

    cuenta_contable_bool       = !self.cuenta_contable_id.nil?        && cuenta_bancaria_original[:numero_cuenta] != params[:numero_cuenta]
    cuenta_contable_prima_bool = !self.cuenta_contable_prima_id.nil?  && cuenta_bancaria_original[:numero_cuenta] != params[:numero_cuenta]

    self.cuenta_contable.descripcion.gsub!(cuenta_bancaria_original[:numero_cuenta], params[:numero_cuenta])       if cuenta_contable_bool
    self.cuenta_contable_prima.descripcion.gsub!(cuenta_bancaria_original[:numero_cuenta], params[:numero_cuenta]) if cuenta_contable_prima_bool

    if (cuenta_contable_bool && !self.cuenta_contable.save!) || (cuenta_contable_prima_bool && !self.cuenta_contable_prima.save!)
      res.add_msgs(self.cuenta_contable.errors.to_a)
      res.add_msgs(self.cuenta_contable_prima.errors.to_a) unless self.cuenta_contable_prima_id.nil?
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
  # ============================================================================================================================================

  def self.validar_e_inicializar(items, padre)
    res_valid   = Response.new
    array_valid = []

    items.each do |item|
      res_temp  = self.create_update_cuenta_bancaria(item, padre, item.obj_has?(:id))

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
