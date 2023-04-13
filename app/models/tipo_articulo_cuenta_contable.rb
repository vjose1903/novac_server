class TipoArticuloCuentaContable < ApplicationRecord
  self.table_name = "tipo_articulo_cuentas_contables"

  belongs_to :configuracion_entidad_cuenta, optional: true
  belongs_to :origen_tipo, polymorphic: true

  belongs_to :cuenta_contable_control,   class_name: 'CuentaContable', optional: false
  belongs_to :cuenta_contable_auxiliar,  class_name: 'CuentaContable', optional: true

  validates :key,              presence: true,       uniqueness: { scope: [:origen_tipo_type, :origen_tipo_id], case_sensitive: false, :message => "Cuenta contable ya está registrada." }

  # ============================================================================================================================================

  def self.create_updatetipo_articulo_cuenta_contable(params, padre, is_save=false)
    res                                                   = Response.new

    tipo_articulo_cuenta                                  = TipoArticuloCuentaContable.where(:id => params[:id]).first_or_create

		puts " "
		puts "params --> ".red + " #{params.to_json}"
		puts "padre  --> ".green + " #{padre.to_json}"
		puts "tipo_articulo_cuenta  --> ".cyan + " #{tipo_articulo_cuenta.to_json}"

    tipo_articulo_cuenta.key                              = params[:key]
    tipo_articulo_cuenta.configuracion_entidad_cuenta_id  = params[:configuracion_entidad_cuenta_id]
    tipo_articulo_cuenta.origen_tipo                      = padre


    result_procesos                                       = tipo_articulo_cuenta.procesos_cuentas(params)


    tipo_articulo_cuenta.valid?

		puts "is_save  --> ".yellow + " #{is_save}"
		puts "tipo_articulo_cuenta  --> ".blue + " #{tipo_articulo_cuenta.to_json}"
		puts "tipo_articulo_cuenta.errors  --> ".red + " #{tipo_articulo_cuenta.errors.to_a}"
		puts " "

    # tipo_articulo_cuenta.errors.delete(:origen_tipo) if !is_save

    if result_procesos.status_valid && tipo_articulo_cuenta.errors.empty? && (!is_save || (is_save && tipo_articulo_cuenta.save!))
			puts "================================================ ENTRO AQUIII ================================================".green
      res.set_data(tipo_articulo_cuenta)
    else
			puts "================================================ ENTRO AQUIII ================================================".red
      res.add_msgs(result_procesos.get_msgs)
      res.add_msgs(tipo_articulo_cuenta.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================

  def procesos_cuentas(params)
    res = Response.new

    if self.cuenta_contable_control_id.nil?
      res                                         = CatEntidadContable.createCuenta(params[:cuenta_contable], params[:descripcion_cuenta], params[:is_control])
      cuenta_contable_control                     = res.get_data()
      self.cuenta_contable_control_id             = cuenta_contable_control[:id] if res.status_valid
    else
      self.cuenta_contable_control.descripcion    = descripcion_cuenta.upcase
      self.cuenta_contable_control.save!
    end

    if res.status_valid && params[:has_comun]

      if self.cuenta_contable_auxiliar_id.nil?
        res                                       = CatEntidadContable.createCuenta(self.cuenta_contable_control, params[:descripcion_cuenta_comun], false)
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

  def self.validar_e_inicializar(items, padre, save)
    res_valid   = Response.new
    array_valid = []

    items.each do |item|
      res_temp  = self.create_updatetipo_articulo_cuenta_contable(item, padre, !item[:id].nil?)

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
