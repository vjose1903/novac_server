class GrupoCuenta < ApplicationRecord

  has_many :cuentas_contables

  validates :descripcion,              presence: { :message => "Descripcion del grupo de cuentas contable no puede estar vacio." },         uniqueness: { scope: :estado, case_sensitive: false, :message => "Grupo de cuenta ya esta registrado" }, :if => :estado
  validates :origen,                   presence: { :message => "Origen del grupo de cuentas contable no puede estar vacio." }


  # ============================================================================================================================================

	def self.models_includes
    includes = [:cuentas_contables]
    return includes
  end

  # ============================================================================================================================================

  def self.create_update_grupo_cuenta(params, is_save=false)
    res                              = Response.new
    GrupoCuenta.transaction do

      grupo_cuenta                   = GrupoCuenta.where(:id => params[:id]).first_or_create

      grupo_cuenta.descripcion       = params[:descripcion]       unless params[:descripcion].nil?
      grupo_cuenta.grupo             = GrupoCuenta.get_next_group if grupo_cuenta.id.nil?
      grupo_cuenta.origen            = params[:origen]            unless params[:origen].nil?
      grupo_cuenta.tipo              = params[:tipo]              unless params[:tipo].nil?
      grupo_cuenta.valid?

      if grupo_cuenta.errors.empty?
        params = create_first_cuenta(params, grupo_cuenta) if grupo_cuenta.id.nil?

        dependencias = [{modelo: CuentaContable, key_object: "cuentas_contables", padre: grupo_cuenta }]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data|
          grupo_cuenta.cuentas_contables = dependencia_data if key_object == 'cuentas_contables'
        }

        if res.status_valid && grupo_cuenta.save!
          res.set_data(serialize_parser(grupo_cuenta, {all: true}))

          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Grupo de cuenta #{action} correctamente.")
        end
      end

      unless grupo_cuenta.errors.empty?
        res.add_msgs(grupo_cuenta.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !grupo_cuenta.errors.empty? || !res.status_valid
    end

    return res
  end


  # ============================================================================================================================================

  def self.get_next_group
    next_group = 1
    last_group = GrupoCuenta.all.order("id DESC").limit(1)

    unless last_group.empty?
      next_group = last_group.first.grupo + 1
    end

    return next_group
  end

  # ============================================================================================================================================

  def self.create_first_cuenta(params, grupo_cuenta)
    params["cuentas_contables"] = [{
      "descripcion" => grupo_cuenta.descripcion,
      "origen"      => grupo_cuenta.origen,
      "tipo"        => grupo_cuenta.tipo,
      "is_control"  => true
      }]

    return params
  end

end
