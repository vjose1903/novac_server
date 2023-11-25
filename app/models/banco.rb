class Banco < ApplicationRecord

  has_many :cuentas_bancarias

  validates :nombre,  presence: true, uniqueness: { scope: [:estado], case_sensitive: false, :message => "Banco ya está registrado." },              :if => :estado
  validates :rnc,     presence: true, uniqueness: { scope: [:estado], case_sensitive: false, :message => "RNC ya está registrado, en otro banco." }, :if => :estado

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

      if banco.errors.empty?

        dependencias = [{modelo: CuentaBancaria, key_object: "cuentas_bancarias", padre: banco }]

        res = crear_actualizar_dependencias(dependencias, params, true) { | key_object, dependencia_data |
          banco.cuentas_bancarias = dependencia_data if key_object == 'cuentas_bancarias'
        }

        if res.status_valid && (!is_save || ( is_save && banco.save! ))
          res.set_data(serialize_parser(banco, { all: true }))

          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Banco #{action} correctamente.")
        end
      end

      unless banco.errors.empty?
        res.add_msgs(banco.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !banco.errors.empty? || !res.status_valid
    end

    return res
  end

  # ============================================================================================================================================

  def self.filtrarBancos(params, pagination_params)
    res = Response.new(pagination_params)
    arg           = params[:arg]

    bancos = Banco
                 .where("lower(bancos.nombre || ' ' || bancos.rnc) like lower('%#{arg}%')  AND bancos.estado = true")
                 .order('bancos.id ASC').to_a

    if bancos.length > 0
      res.set_data(bancos, {all: true})
    else
      res.set_data([])
      cantidad_registros = Banco.where({ estado: true }).count
      res.add_msg(cantidad_registros == 0 ? 'No existen bancos registrados.' : 'No existe banco con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end

# darlymarmolejos@gmail.com
# .PepinoDmar.
# .PepinoDmar.