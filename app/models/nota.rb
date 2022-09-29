class Nota < ApplicationRecord
  belongs_to :cliente, optional: true
  belongs_to :user
  belongs_to :tipo_factura

  validates :user,      presence: { :message => 'Falta el usuario creador de la nota.' }
  validates :total,     presence: { :message => 'El total de la nota no puede estar vacio.' }

  has_many :facturas_aplicadas, dependent: :destroy
  has_many :detalles_facturas_notas, through: :facturas_aplicadas, dependent: :destroy

	def self.models_includes
		includes = [{user: :documentos_de_identidad}, {cliente: :documentos_de_identidad}, :tipo_factura, {facturas_aplicadas: :cabecera_factura}, {detalles_facturas_notas: [:articulo, :detalle_factura]} ]
		return includes
	end

  def self.create_nota(params)
    res                                     = Response.new
    Nota.transaction do

      res_check_facturas                    = Nota.check_facturas(params)

      if res_check_facturas.status_valid
        data_facturas                       = res_check_facturas.get_data

        res_secuencias                      = Nota.find_secuencias(params)

        if res_secuencias.status_valid

          data_secuencias                   = res_secuencias.get_data
          num_factura_blank                 = Nota.where({numero_documento: data_secuencias[:numero_documento], tipo_factura_id: params[:tipo_factura_id] })

          if num_factura_blank.blank?

            res_valid                       = Response.new

            # NOTA DE CREDITO
            if params[:cliente_id] && params[:tipo_factura_id] == TiposNotasId.credito
              res_valid                     = Cliente.calculate_balance_cliente(params[:cliente_id], params[:total].to_f.abs, '-', true)
            end


            # NOTA DE DEBITO
            if res_valid.status_valid && params[:cliente_id] && params[:tipo_factura_id] == TiposNotasId.debito
              res_valid                     = Cliente.calculate_balance_cliente(params[:cliente_id], params[:total].to_f.abs, '+')
            end

            if res_valid.status_valid

              today_cuadre                  = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})
              nota                          = Nota.new

              nota.cliente_id               = params[:cliente_id]
              nota.user_id                  = get_current_user[:id]
              nota.tipo_factura_id          = params[:tipo_factura_id]
              nota.total                    = params[:total]
              nota.numero_documento         = data_secuencias[:numero_documento]
              nota.numero_comprobante       = data_secuencias[:numero_comprobante]
              nota.fecha_equivalente        = params[:fecha_equivalente] ? params[:fecha_equivalente] : today_cuadre.blank? ? DateTime.now : CabeceraFactura.calculateNextDay
              nota.fecha_valida             = params[:fecha_valida]
              nota.estado                   = true
              nota.no_cliente_nombre        = data_facturas[:no_cliente_nombre]
              nota.no_cliente_direccion     = data_facturas[:no_cliente_direccion]
              nota.valid?


              dependencias                  = [ {modelo: FacturaAplicada, key_object: 'facturas_aplicadas', padre: nota} ]

              res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
                nota.facturas_aplicadas     = dependencia_data if key_object == 'facturas_aplicadas'
              }


              if res.status_valid && nota.errors.empty? && nota.save!

                nota.identificador          = Nota.makeIdentificador(nota)

                if nota.save!

                  res_valid                 = Nota.update_secuencias(data_secuencias)

                  if res_valid.status_valid
                    res.set_data(nota, {all: true})

                    realizando = params[:tipo_factura_id] == TiposNotasId.credito ? 'Nota de crédito' : 'Nota de debito'
                    res.add_msg("#{realizando} creada correctamente.")
                  else
                    res.set_status(HTTP_STATUS_CODE[:conflict])
                  end

                else
                  res.add_msgs(res_valid.get_msgs.to_a)
                  res.add_msgs(nota.errors.to_a)
                  res.set_status(HTTP_STATUS_CODE[:conflict])
                end

              else
                res.add_msgs(nota.errors.to_a)
                res.set_status(HTTP_STATUS_CODE[:conflict])
              end

            else

              res.add_msgs(res_valid.get_msgs.to_a)
              res.set_status(HTTP_STATUS_CODE[:conflict])
            end

          else
            res.add_msg('El número de nota ya existe.')
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end

        else
          res.add_msgs(res_secuencias.get_msgs.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(res_check_facturas.get_msgs.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless res.status_valid

    end
    return res
  end

  # ===================================================================================================================================================
  def tipo_nota
    return TiposNotas.get_tipo(self.tipo_factura_id)
  end

  # ===================================================================================================================================================
  def self.check_facturas(params)
    res            = Response.new
    obj_response   = {:no_cliente_nombre => nil, :no_cliente_direccion => nil, :is_same_client => true, :all_facturas_active => true }


    for factura_aplicada in params[:facturas_aplicadas]
      cabecera     = CabeceraFactura.find_by_id(factura_aplicada[:cabecera_factura_id])

      if cabecera.estado == false
        obj_response[:all_facturas_active]       = false
        break
      else
        if cabecera.cliente_id != params[:cliente_id]
          obj_response[:is_same_client]          = false
          break
        end

        if !cabecera.NoCliente_nombre.nil?

          if !obj_response[:no_cliente_nombre].nil? && cabecera.NoCliente_nombre != obj_response[:no_cliente_nombre]
            obj_response[:is_same_client]         = false
            break
          else
            obj_response[:no_cliente_nombre]      = cabecera.NoCliente_nombre
            obj_response[:no_cliente_direccion]   = cabecera.NoCliente_direccion
          end

        end
      end
    end

    res.add_msg('Solo se le pueden realizar notas a facturas activas.') unless obj_response[:all_facturas_active]

    res.add_msg('Todas las facturas deben de ser del mismo cliente.') unless obj_response[:is_same_client]

    res.set_status(HTTP_STATUS_CODE[:conflict]) if !obj_response[:is_same_client] || !obj_response[:all_facturas_active]

    res.set_data(obj_response)
    return res
  end

  # ===================================================================================================================================================

  def self.find_secuencias(params)
    res = Response.new

    data_secuencias = {
      :actual_paquete_comprobante => nil,
      :actual_secuencia_nota   => nil,
      :numero_documento           => nil,
      :numero_comprobante         => nil,
    }

    tipoFactura                                   = TipoFactura.find_by_id(params[:tipo_factura_id])
    res_actual_paquete                            = SecuenciaComprobante.get_paquete_rnc_by_estado(params[:tipo_factura_id], true)

    return res_actual_paquete unless res_actual_paquete.status_valid

    data_secuencias[:actual_paquete_comprobante]  = res_actual_paquete.get_data
    next_secuencia_comprobante                    = data_secuencias[:actual_paquete_comprobante][:secuencia]


    data_secuencias[:actual_secuencia_nota]       = tipoFactura.secuencia_factura
    data_secuencias[:numero_documento]            = data_secuencias[:actual_secuencia_nota][:secuencia] + 1

    data_secuencias[:numero_comprobante]          = "B#{tipoFactura.referencia}#{"%08d" % next_secuencia_comprobante}"

    res.set_data(data_secuencias)
    return res
  end

  # ===================================================================================================================================================

  def self.makeIdentificador(nota, cantidad_detalles = 0)
    fecha = nota.fecha_equivalente.kind_of?(String) ? DateTime.parse(nota.fecha_equivalente) : nota.fecha_equivalente

    array = [
      {value: "#{"%04d" % (nota.cliente_id || 0)}".reverse},
      {value: "#{"%04d" % nota.user_id}"},
      {value: "#{"%04d" % cantidad_detalles == 0 ? cantidad_detalles : nota.facturas_aplicadas.length }".reverse},
      {value: "#{nota.id} ".reverse},
      {value: "#{fecha.to_i} ".reverse},
  ]

    identificador = ""

    array.each do | item |
      identificador += "#{item[:value]}"
    end

    return identificador
  end

  # ===================================================================================================================================================
  def self.update_secuencias(data_secuencias)
    res   = Response.new

    res_aumento  = nil
    res_aumento  = SecuenciaComprobante.aumentar_secuencia_comprobante(data_secuencias[:actual_paquete_comprobante][:id]) if data_secuencias[:actual_paquete_comprobante][:is_paquete]

    if !res_aumento.nil? && res_aumento.status_valid

      unless data_secuencias[:actual_secuencia_nota].update({ secuencia: data_secuencias[:numero_documento] })
        res.add_msg('Error actualizando la tabla de secuencia de notas.')
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    else
      res.add_msgs(!res_aumento.nil? ? res_aumento.get_msgs.to_a : "Error creando la nota.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================
  def self.anular_nota(params)
    res = Response.new
    res.add_msg('Esta funcion aun no esta implementada.')
    res.set_status(HTTP_STATUS_CODE[:conflict])
    return res
  end

  # =========================================================================================================================================================

  def self.filtrarNota(params, paginate_params)
    res         = Response.new(params)
		arg         = params["arg"]
		tipo_nota   = params["tipo_nota"] || nil
		query       = "lower(notas.numero_comprobante || ' ' || notas.fecha_equivalente || ' ' || notas.total || ' ' || coalesce(notas.no_cliente_nombre,'') || ' ' || coalesce(notas.no_cliente_direccion,'') || ' ' || coalesce(clientes.nombre, '') || ' ' || coalesce(clientes.apellido, '')) like lower('%#{arg}%')  AND notas.estado = true"
		query      += " AND notas.tipo_factura_id = #{TiposNotasId.get_id(tipo_nota)}" if tipo_nota != nil

    notas = Nota
    .joins('left join clientes on clientes.id = notas.cliente_id')
    .where(query)
    .order('notas.id DESC')

    if notas.length > 0
      res.set_data(notas, {all: true}, Nota.models_includes)
    else
      res.set_data([])
      cantidad_registros = Nota.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? "No existen notas registradas." : 'No existen notas con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
