class Banco < ApplicationRecord

  has_many :cuentas_bancarias

  validates :nombre,  :presence, uniqueness: { scope: [:estado], case_sensitive: false, :message => "Banco ya esta registrado." }, :if => :estado
  validates :rnc,     :presence, uniqueness: { scope: [:estado], case_sensitive: false, :message => "RNC ya esta registrado, en otro banco." }, :if => :estado

  def self.create_update_banco(params, is_save=false)
    res                                 = Response.new
    Banco.transaction do

      banco                             = Banco.where(:id => params[:id]).first_or_create

      banco.nombre                      = params[:nombre]
      banco.rnc                         = params[:rnc]
      banco.comentario                  = params[:comentario]
      banco.telefono                    = params[:telefono]
      banco.direccion                   = params[:direccion]
      banco.ejecutivo_cuenta            = params[:ejecutivo_cuenta]
      banco.telefono_ejecutivo_cuenta   = params[:telefono_ejecutivo_cuenta]
      banco.valid?

      if banco.errors.empty? && (!is_save || ( is_save && banco.save! ))

        res.set_data(serialize_parser(banco, { all: true }))

        action = params[:id] ? 'actualizado' : 'creado'
        res.add_msg("Banco #{action} correctamente.")
      else
        res.add_msgs(banco.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !banco.errors.empty? || !res.status_valid
    end

    return res
  end

end

# darlymarmolejos@gmail.com
# .PepinoDmar.
# .PepinoDmar.