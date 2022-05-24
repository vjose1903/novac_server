class CabeceraConduce < ApplicationRecord
  belongs_to :user
  belongs_to :cliente
  has_many :detalle_conduces, dependent: :destroy

  # ========================================================================================================================

  def self.create_update_conduce(params, is_save=false)
		res = Response.new
    CabeceraConduce.transaction do

			conduce                      = CabeceraConduce.where(:id => params["id"]).first_or_create

      conduce.numero_conduce       = SecuenciaFactura.find_secuencia(15)
      conduce.fecha_equivalente    = params["fecha_equivalente"] ? params["fecha_equivalente"] : DateTime.now
      conduce.cliente_id           = params["cliente_id"]
      conduce.user_id              = get_current_user['id']

      conduce.valid?

      dependencias = [
        {modelo: DetalleConduce, key_object: "detalle_conduces", padre: conduce},
      ]

      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
        conduce.detalle_conduces   = dependencia_data if key_object == 'detalle_conduces'
      }

      if res.status_valid && conduce.errors.empty? && (!is_save || (is_save && conduce.save!))

        res                        = updateSecuencias(15)

        if res.status_valid
          res.set_data(serialize_parser(conduce, {all: true}))
          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Conduce #{action} correctamente.")

        else
          res.add_msgs(res.get_msgs)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(conduce.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless conduce.errors.empty?
    end
		return res
  end

  # ========================================================================================================================

end
