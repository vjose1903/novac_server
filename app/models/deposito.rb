class Deposito < ApplicationRecord
  belongs_to :cuenta_bancaria
  belongs_to :user_creador,       class_name: 'User', optional: false
  belongs_to :user_anulador,      class_name: 'User', optional: true
  belongs_to :last_user_update,   class_name: 'User', optional: true

  validates :monto,             presence: { :message => "El monto del depósito no puede estar vacio." }, numericality: { greater_than: 0, :message => "La cantidad del monto del depósito debe de ser mayor a 0." }
  validates :fecha_equivalente, presence: { :message => "Debe de especificar una fecha para el depósito." }

  # =========================================================================================================================================================

  def self.models_includes
    includes = [
      :user_creador,
      :user_anulador,
      { cuenta_bancaria: CuentaBancaria.models_includes },
    ]
    return includes
  end

  # =========================================================================================================================================================

  def self.create_update_deposito( params )
    res                 = Response.new
    Deposito.transaction do

      cuenta_bancaria   = CuentaBancaria.find_by_id(params[:cuenta_bancaria_id])

      unless cuenta_bancaria.nil?

        deposito        = Deposito.where(:id => params[:id]).first_or_create

        deposito.user_creador_id          = get_current_user[:id] if (params[:id].nil?  || !params[:id].present?) && deposito.id.nil?
        deposito.last_user_update_id      = get_current_user[:id] if (!params[:id].nil? || params[:id].present?) && !deposito.id.nil?
        deposito.cuenta_bancaria_id       = params[:cuenta_bancaria_id]
        deposito.monto                    = params[:monto]
        deposito.comentario               = params[:comentario]
        deposito.numero_referencia        = params[:numero_referencia]
        deposito.fecha_equivalente        = params[:fecha_equivalente]

        deposito.valid?
        result_tasa                       = deposito.calculate_and_get_tasa

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
        res.add_msg("La cuenta bancaria que seleccionó para crear este depósito, no existe o esta desabilitado.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    end

    return res
  end

  # =========================================================================================================================================================

  def calculate_and_get_tasa
    res                 = Response.new

    divisa              = self.cuenta_bancaria.divisa
    current_tasa        = divisa.tasas_de_cambio.find_by({ fecha_equivalente: formatearFecha(self.fecha_equivalente.to_s, TipoFecha.sin_hora) })

    self.tasa           = current_tasa.valor
    self.monto_local    = self.monto.to_f * current_tasa.valor

    if ( self.tasa.nil? || !self.tasa.present? ) || ( self.monto_local.nil? || !self.monto_local.present? )
      res.add_msg("error agregando la tasa de cambio de la divisa para este deposito, favor llamar a Victor J. Vásquez")
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
      res.add_msg("error anulando deposito.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
