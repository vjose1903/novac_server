class TipoCuentaBancaria < ApplicationRecord

  def self.create_update_tipo_cuenta(params, is_save=false)
    res                            = Response.new

    TipoCuentaBancaria.transaction do

      tipo_cuenta                  = TipoCuentaBancaria.where(:id => params[:id]).first_or_create

      tipo_cuenta.descripcion      = params[:descripcion]
      tipo_cuenta.valid?

      if tipo_cuenta.errors.empty? && (!is_save || ( is_save && tipo_cuenta.save! ))

        res.set_data(serialize_parser(tipo_cuenta, { all: true }))

        action = params[:id] ? 'actualizado' : 'creado'
        res.add_msg("Tipo de cuenta bancaria #{action} correctamente.")
      else
        res.add_msgs(tipo_cuenta.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !tipo_cuenta.errors.empty? || !res.status_valid
    end

    return res
  end

end
