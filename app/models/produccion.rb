class Produccion < ApplicationRecord
  belongs_to :user

  attribute :user

  has_many :detalles_produccion, dependent: :destroy

  # =========================================================================================================

  def self.create_update_produccion(params, is_save=false)
		res                                   = Response.new
    Produccion.transaction do

			produccion                          = Produccion.where(:id => params[:id]).first_or_initialize

      produccion.user_id                  = get_current_user[:id]
      produccion.numero                   = SecuenciaFactura.find_secuencia(16)
      produccion.fecha_equivalente        = params[:fecha_equivalente] ? params[:fecha_equivalente] : DateTime.now
      produccion.valid?

      dependencias = [ {modelo: DetalleProduccion, key_object: 'detalles_produccion', padre: produccion} ]

      res = crear_actualizar_dependencias(dependencias, params) { |key_object, dependencia_data|
        produccion.detalles_produccion    = dependencia_data if key_object == 'detalles_produccion'
      }

      if res.status_valid && produccion.errors.empty? && (!is_save || (is_save && produccion.save!))

        result                               = updateSecuencias(16)

        if result.status_valid
          res.set_data( serialize_parser( produccion, { all: true } ))
          res.add_msg('Produccion creada correctamente.')

        else
          res.add_msgs(result.get_msgs.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(produccion.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !produccion.errors.empty? || !res.status_valid
    end

		return res
  end

  # =========================================================================================================================================================

  def self.filtrarProduccion(arg, params)
    res = Response.new(params)

    producciones = Produccion.all.order("id ASC").to_a

    if producciones.length > 0
      res.set_data(producciones, {all: true})
    else
      res.set_data([])
			cantidad_registros = Produccion.all.count
      res.add_msg(cantidad_registros == 0 ? "No existen producciones registradas." : "No existen producciones con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
