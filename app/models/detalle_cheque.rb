class DetalleCheque < ApplicationRecord
  belongs_to :cheque

  def self.manage_detalle_cheque(params, cheque, is_save=false)
    res = Response.new

    detalle_cheque                  = DetalleCheque.find_or_create_by(id: params[:id])

    detalle_cheque.comentario       = params[:comentario] || nil
    detalle_cheque.monto            = params[:monto]
    result_tasa                     = detalle_cheque.calculate_and_set_tasa(cheque)
    detalle_cheque.valid?

    detalle_cheque.errors.delete(:cheque) if !is_save

    if result_tasa.status_valid && detalle_cheque.errors.empty? && (!is_save || (is_save && detalle_cheque.save!))
      res.set_data(detalle_cheque)
    end

    unless result_tasa.status_valid
      res.add_msgs(result_tasa.get_msgs.to_a)
      res.set_status(HTTP_STATUS.conflict)
    end

    res.manage_error_transaction(detalle_cheque)

    return res
  end

  # =========================================================================================================================================================

  def calculate_and_set_tasa(cheque)
    res                 = Response.new

    current_tasa        = cheque.divisa.getMontoTasa(cheque.fecha_equivalente)

    self.tasa           = current_tasa.valor
    self.monto_local    = self.monto.to_f * current_tasa.valor

    if ( self.tasa.nil? || !self.tasa.present? ) || ( self.monto_local.nil? || !self.monto_local.present? )
      res.add_msg('Error agregando la tasa de cambio de la divisa para este detalle de cheque, Por favor comunicarse con el soporte de Novac System.')
      res.set_status(HTTP_STATUS.conflict)
    end

    return res
  end

  # =========================================================================================================================================================

  def self.validar_e_inicializar(items, padre)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.manage_detalle_cheque(item, padre, !item[:id].nil?)

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
