class Deposito < ApplicationRecord
  belongs_to :cuenta_bancaria
  belongs_to :divisa

  belongs_to :user_creador,       class_name: 'User', optional: false
  belongs_to :user_anulador,      class_name: 'User', optional: true
  belongs_to :last_user_update,   class_name: 'User', optional: true

  validates :monto,             presence: { :message => "El monto del depósito no puede estar vacío." }, numericality: { greater_than: 0, :message => "La cantidad del monto del depósito debe de ser mayor a 0." }
  validates :fecha_equivalente, presence: { :message => "Debe de especificar una fecha para el depósito." }

  # =========================================================================================================================================================

  def self.models_includes
    includes = [
      :user_creador,
      :last_user_update,
      :user_anulador,
      { divisa: Divisa.models_includes },
      { cuenta_bancaria: CuentaBancaria.models_includes },
    ]
    return includes
  end

  # =========================================================================================================================================================

  def self.create_update_deposito( params )
    res                 = Response.new
    Deposito.transaction do

      cuenta_bancaria   = CuentaBancaria.find_by_id(params[:cuenta_bancaria_id])

      unless cuenta_bancaria.nil? || !cuenta_bancaria.estado

        deposito        = Deposito.where(:id => params[:id]).first_or_create

        deposito.user_creador_id          = get_current_user[:id] if (params[:id].nil?  || !params.has_key?(:id)) && deposito.id.nil?
        deposito.last_user_update_id      = get_current_user[:id] if (!params[:id].nil? || params.has_key?(:id)) && !deposito.id.nil?
        deposito.cuenta_bancaria_id       = params[:cuenta_bancaria_id]
        deposito.divisa_id                = params[:divisa_id]
        deposito.monto                    = params[:monto]
        deposito.comentario               = params[:comentario]
        deposito.numero_referencia        = params[:numero_referencia]
        deposito.fecha_equivalente        = params[:fecha_equivalente]

        deposito.valid?
        result_tasa                       = deposito.calculate_and_set_tasa

        # deposito.otras_validaciones(params)

        if result_tasa.status_valid && deposito.errors.empty? && deposito.save!
          res.set_data( deposito )

          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Depósito #{action} correctamente.")
        end

        if !deposito.errors.empty? || !result_tasa.status_valid
          res.add_msgs(result_tasa.get_msgs.to_a)
          res.add_msgs(deposito.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        transaction_rollback if !deposito.errors.empty? || !res.status_valid

      else

        res.add_msg("La cuenta bancaria que seleccionó para crear este depósito, no existe")          if cuenta_bancaria.nil?
        res.add_msg("La cuenta bancaria que seleccionó para crear este depósito, está deshabilitada.") if !cuenta_bancaria.nil? && !cuenta_bancaria.estado

        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    end

    return res
  end

  # =========================================================================================================================================================

  def calculate_and_set_tasa
    res                 = Response.new

    current_tasa        = self.divisa.getMontoTasa(self.fecha_equivalente)

    self.tasa           = current_tasa.valor
    self.monto_local    = self.monto.to_f * current_tasa.valor

    if ( self.tasa.nil? || !self.tasa.present? ) || ( self.monto_local.nil? || !self.monto_local.present? )
      res.add_msg("Error agregando la tasa de cambio de la divisa para este deposito, Por favor comunicarse con el soporte de Novac System")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =========================================================================================================================================================

  def anular_registro()
    res                        = Response.new

    self.user_anulador_id      = get_current_user[:id]
    self.fecha_anulacion       = DateTime.now
    self.estado                = false

    if self.save!
      res.add_msg("Depósito anulado correctamente.")
    else
      res.add_msg("error anulando depósito.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =========================================================================================================================================================
  def self.filtrarDepositos(params, pagination_params)
    res    = Response.new(pagination_params)
    arg    = params[:arg]

    depositos = Deposito
               .joins('inner join cuentas_bancarias on depositos.cuenta_bancaria_id = cuentas_bancarias.id')
               .where("lower(depositos.monto || ' ' || depositos.comentario || ' ' || coalesce(depositos.numero_referencia, '') || ' ' || cuentas_bancarias.numero_cuenta || ' ' || cuentas_bancarias.descripcion ) like lower('%#{arg}%')  AND depositos.estado = true").order('depositos.id ASC').to_a

    if depositos.length > 0
      res.set_data(depositos, {all: true})
    else
      res.set_data([])
      cantidad_registros = Deposito.where({ estado: true }).count
      res.add_msg(cantidad_registros == 0 ? 'No existen depositos registrados.' : 'No existe deposito con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
