class Transferencia < ApplicationRecord
  belongs_to :divisa
  belongs_to :cuenta_bancaria_origen,        class_name: 'CuentaBancaria', optional: false
  belongs_to :cuenta_bancaria_destino,       class_name: 'CuentaBancaria', optional: true

  belongs_to :user_creador,                  class_name: 'User',           optional: false
  belongs_to :user_anulador,                 class_name: 'User',           optional: true
  belongs_to :last_user_update,              class_name: 'User',           optional: true


  # =========================================================================================================================================================

  def otras_validaciones(params)

    if ( !params.has_key?(:cuenta_bancaria_destino_id) || params[:cuenta_bancaria_destino_id].nil? ) && ( params[:nombre_banco_tercero].nil? || !params.has_key?(:nombre_banco_tercero) )
      self.errors.add(:base, 'Debe de seleccionar el banco de tercero, para esta transferencia.')
    end

    if ( !params.has_key?(:cuenta_bancaria_destino_id) || params[:cuenta_bancaria_destino_id].nil? ) && ( params[:cuenta_bancaria_tercero].nil? || !params.has_key?(:cuenta_bancaria_tercero) )
      self.errors.add(:base, 'Debe de especificar la cuenta del banco de tercero a la cual ira dirigida la transferencia.')
    end


    if !params[:cuenta_bancaria_destino_id].nil?
      cuenta_bancaria_destino   = CuentaBancaria.find_by_id(params[:cuenta_bancaria_destino_id])

      self.errors.add(:base, 'La cuenta bancaria de destino que seleccionó, no existe.')          if cuenta_bancaria_destino.nil?
      self.errors.add(:base, 'La cuenta bancaria de destino que seleccionó, está deshabilitada.') if !cuenta_bancaria_destino.nil? && !cuenta_bancaria_destino.estado
    end

  end

  # =========================================================================================================================================================

  def self.models_includes
    includes = [
      :user_creador,
      :last_user_update,
      :user_anulador,
      { divisa: Divisa.models_includes },
      { cuenta_bancaria_origen: CuentaBancaria.models_includes },
      { cuenta_bancaria_destino: CuentaBancaria.models_includes },
    ]
    return includes
  end

  # =========================================================================================================================================================

  def self.create_update_transferencia( params )
    res                        = Response.new
    Transferencia.transaction do

      cuenta_bancaria_origen   = CuentaBancaria.find_by_id(params[:cuenta_bancaria_origen_id])

      unless cuenta_bancaria_origen.nil? || !cuenta_bancaria_origen.estado

        transferencia               = Transferencia.where(:id => params[:id]).first_or_create

        transferencia.cuenta_bancaria_origen_id   = params[:cuenta_bancaria_origen_id]
        transferencia.cuenta_bancaria_destino_id  = params[:cuenta_bancaria_destino_id]
        transferencia.divisa_id                   = params[:divisa_id]
        transferencia.user_creador_id             = get_current_user[:id] if (params[:id].nil?  || !params.has_key?(:id)) && transferencia.id.nil?
        transferencia.last_user_update_id         = get_current_user[:id] if (!params[:id].nil? || params.has_key?(:id)) && !transferencia.id.nil?
        transferencia.monto                       = params[:monto]
        transferencia.comentario                  = params[:comentario]
        transferencia.nombre_banco_tercero        = params[:nombre_banco_tercero]
        transferencia.cuenta_bancaria_tercero     = params[:cuenta_bancaria_tercero]
        transferencia.numero_referencia           = params[:numero_referencia]
        transferencia.fecha_equivalente           = params[:fecha_equivalente]

        transferencia.valid?
        result_tasa                       = transferencia.calculate_and_set_tasa

        transferencia.otras_validaciones(params)

        if result_tasa.status_valid && transferencia.errors.empty? && transferencia.save!
          res.set_data( transferencia )

          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Depósito #{action} correctamente.")
        end

        if !transferencia.errors.empty? || !result_tasa.status_valid
          res.add_msgs(result_tasa.get_msgs.to_a)
          res.add_msgs(transferencia.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        transaction_rollback if !transferencia.errors.empty? || !res.status_valid

      else

        res.add_msg('La cuenta bancaria de origen que seleccionó, no existe.')         if cuenta_bancaria_origen.nil?
        res.add_msg('La cuenta bancaria de origen que seleccionó, está deshabilitada.') if !cuenta_bancaria_origen.nil? && !cuenta_bancaria_origen.estado
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    end

    return res
  end

  # =========================================================================================================================================================

  def self.filtrarTransferencias(params, pagination_params)
    res    = Response.new(pagination_params)
    arg    = params[:arg]

    transferencias = Transferencia
                  .joins('inner join cuentas_bancarias on transferencias.cuenta_bancaria_origen_id = cuentas_bancarias.id')
                  .where("lower(transferencias.monto || ' ' || transferencias.comentario || ' ' || transferencias.numero_referencia || ' ' || cuentas_bancarias.numero_cuenta || ' ' || cuentas_bancarias.descripcion || ' ' || transferencias.cuenta_bancaria_origen_id || ' ' || transferencias.nombre_banco_tercero ) like lower('%#{arg}%')  AND transferencias.estado = true").order('transferencias.id ASC').to_a

    puts "transferencias ".red + " #{transferencias.to_json}"
    if transferencias.length > 0
      res.set_data(transferencias, {all: true})
    else
      res.set_data([])
      cantidad_registros = Transferencia.where({ estado: true }).count
      res.add_msg(cantidad_registros == 0 ? 'No existen transferencias registradas.' : 'No existe transferencia con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
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
      res.add_msg("Error agregando la tasa de cambio de la divisa para esta transferencia, favor llamar a Victor J. Vásquez")
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
      res.add_msg("Transferencia anulada correctamente.")
    else
      res.add_msg("error anulando transferencia.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
