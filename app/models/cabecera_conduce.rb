class CabeceraConduce < ApplicationRecord
  belongs_to :user
  belongs_to :cliente
  has_many :detalle_conduces, dependent: :destroy


  # =========================================================================================================================================================

  def self.models_includes
    includes = [
      {user: :documentos_de_identidad},
      {cliente: :documentos_de_identidad},
      {detalle_conduces: [ :cabecera_conduce]},
    ]
    return includes
  end


  # ========================================================================================================================

  def self.create_update_conduce(params, is_save=false)
    res = Response.new
    CabeceraConduce.transaction do

      conduce                      = CabeceraConduce.where(:id => params["id"]).first_or_create

      conduce.numero_conduce       = SecuenciaFactura.find_secuencia(15)
      conduce.fecha_equivalente    = params["fecha_equivalente"] ? params["fecha_equivalente"] : DateTime.now
      conduce.cliente_id           = params["cliente_id"]
      conduce.user_id              = get_current_user['id']
			conduce.estado               = true

      conduce.valid?

      dependencias = [
        {modelo: DetalleConduce, key_object: "detalle_conduces", padre: conduce},
      ]

      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
        conduce.detalle_conduces   = dependencia_data if key_object == 'detalle_conduces'
      }

      if res.status_valid && conduce.errors.empty? && (!is_save || (is_save && conduce.save!))

        result                     = updateSecuencias(15)

        if result.status_valid
          res.set_data(serialize_parser(conduce, { all: true }))
          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Conduce #{action} correctamente.")

        else
          res.add_msgs(result.get_msgs.to_a)
          res.set_status(HTTP_STATUS.conflict)
        end

      else
        res.add_msgs(conduce.errors.to_a)
        res.set_status(HTTP_STATUS.conflict)
      end

      transaction_rollback if !conduce.errors.empty? || !res.status_valid
    end
    return res
  end

	# =========================================================================================================================================================
	def self.filtrarConduces(arg, params)
		res = Response.new(params)

		conduces = CabeceraConduce
		.joins("inner join clientes on clientes.id = cabecera_conduces.cliente_id")
		.where("lower(cabecera_conduces.numero_conduce || ' ' || clientes.nombre || ' ' || clientes.apellido ) like lower('%#{arg}%') AND cabecera_conduces.estado = true")
		.order("cabecera_conduces.id DESC")

		if conduces.length > 0
			res.set_data(conduces, {all: true}, CabeceraConduce.models_includes)
		else
			cantidad_registros = CabeceraConduce.where({estado: true}).count
			res.add_msg(cantidad_registros == 0 ? "No existen conduces de mercancías registrados." : "No existen conduces con las especificaciones introducidas.")
			res.set_status(HTTP_STATUS.conflict)
		end

		return res
	end

	# ===================================================================================================================================================

	def self.revertir(conduce_a_anular)
		res                 = Response.new
		CabeceraConduce.transaction do
			res_valid         = conduce_a_anular.procesoRevertirConduce

			if res_valid.status_valid
				conduce_a_anular.estado = false

				if conduce_a_anular.save!
					msg           =  "Conduce de mercancía anulado correctamente."
					res.add_msg(msg)
				else
					res.add_msgs(conduce_a_anular.errors.to_a)
					res.set_status(HTTP_STATUS.conflict)
				end
			else
				res.add_msgs(res_valid.get_msgs.to_a)
				res.set_status(HTTP_STATUS.conflict)
			end

			transaction_rollback unless res.status_valid
		end

		return res
	end

	# ===================================================================================================================================================

	def procesoRevertirConduce
		res_valid     = Response.new

		self.detalle_conduces.each  do | detalle_conduce |
			res_temp    = detalle_conduce.procesoAnularConduceDetalle(self)
			return res_temp unless res_temp.status_valid
		end

		return res_valid
	end
end
