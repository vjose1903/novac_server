class CabeceraFactura < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :suplidor, optional: true
  belongs_to :cliente, optional: true
  belongs_to :user

  has_many :detalle_facturas, dependent: :destroy
  has_many :detalle_recibos, dependent: :destroy

  # ===================================================================================================================================================

  def is_contado
    return self.condicion == 'Contado'
  end

  # ===================================================================================================================================================

  def self.create_factura(params , is_save=false)
    CabeceraFactura.transaction do
      res                                  = Response.new
      res_secuencias                       = CabeceraFactura.find_secuencias(params)

      if res_secuencias.status_valid

        data_secuencias                    = res_secuencias.get_data
        num_factura_blank                  = CabeceraFactura.where({numero_factura: data_secuencias[:numero_factura], tipo: params["tipo"], tipo_factura_id: params["tipo_factura_id"], condicion: params['condicion']}).blank?

        if num_factura_blank

          res_valid                        = Response.new

          if params["condicion"] == "Crédito" && params["tipo"] == "venta" || params["is_viaje"]
            res_valid                      = Cliente.calculate_balance_cliente(params["cliente_id"], params["total_factura"], "+")
          end

          # NOTA DE CREDITO
          if res_valid.status_valid && params["is_nota"] && params["cliente_id"] && params["tipo_factura_id"] == 5
            res_valid                      = Cliente.calculate_balance_cliente(params["cliente_id"], params["total_factura"].to_f.abs, "-")
            res_valid                      = CabeceraFactura.agregar_nota_a_CabeceraFactura(params["factura_id"], params)                       if res_valid.status_valid
          end

          # NOTA DE DEBITO
          if res_valid.status_valid && params["is_nota"] && params["cliente_id"] && params["tipo_factura_id"] == 4
            res_valid                      = Cliente.calculate_balance_cliente(params["cliente_id"], params["total_factura"].to_f.abs, "+")
            res_valid                      = CabeceraFactura.agregar_nota_a_CabeceraFactura(params["factura_id"], params)                       if res_valid.status_valid
          end

          if res_valid.status_valid

            today_cuadre                              = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})
            cabecera_factura                          = CabeceraFactura.new()

            cabecera_factura.fecha_equivalente        = params["fecha_equivalente"] ? params["fecha_equivalente"] : today_cuadre.blank? ? DateTime.now : CabeceraFactura.calculateNextDay
            cabecera_factura.fecha_completada         = params["condicion"] == "Contado" && !params["is_viaje"] ? cabecera_factura.fecha_equivalente : nil
            cabecera_factura.user_id                  = get_current_user["id"]
            cabecera_factura.numero_comprobante       = data_secuencias[:numero_comprobante]
            cabecera_factura.numero_factura           = data_secuencias[:numero_factura]
            cabecera_factura.estado                   = true

            cabecera_factura.tipo_factura_id          = params["tipo_factura_id"]
            cabecera_factura.suplidor_id              = params["suplidor_id"]
            cabecera_factura.cliente_id               = params["cliente_id"]
            cabecera_factura.fecha_viaje              = params["fecha_viaje"]
            cabecera_factura.fecha_vencimiento        = params["fecha_vencimiento"]
            cabecera_factura.fecha_valida             = params["fecha_valida"]
            cabecera_factura.condicion                = params["condicion"]
            cabecera_factura.forma_pago               = params["forma_pago"]
            cabecera_factura.total_factura            = params["total_factura"]
            cabecera_factura.itbis                    = params["itbis"]
            cabecera_factura.descuento                = params["descuento"]
            cabecera_factura.Bruto                    = params["Bruto"]
            cabecera_factura.tipo                     = params["tipo"]
            cabecera_factura.NoCliente_nombre         = params["NoCliente_nombre"]
            cabecera_factura.NoCliente_direccion      = params["NoCliente_direccion"]
            cabecera_factura.costoYgasto              = params["costoYgasto"]
            cabecera_factura.pagada                   = params["pagada"]
            cabecera_factura.vendedor_id              = params["vendedor_id"]
            cabecera_factura.balance                  = params["balance"]
            cabecera_factura.devuelta                 = params["devuelta"]
            cabecera_factura.is_adelantada            = params["is_adelantada"]
            cabecera_factura.is_nota                  = params["is_nota"]
            cabecera_factura.is_viaje                 = params["is_viaje"]
            cabecera_factura.tiene_nota               = params["tiene_nota"]
            cabecera_factura.aplicada_a               = params["aplicada_a"]

            dependencias = [ {modelo: DetalleFactura, key_object: "detalle_facturas", padre: cabecera_factura} ]

            res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
              cabecera_factura.detalle_facturas   = dependencia_data if key_object == 'detalle_facturas'
            }

            if res.status_valid && cabecera_factura.errors.empty? && (!is_save || (is_save && cabecera_factura.save!))

							cabecera_factura.identificador      = CabeceraFactura.makeIdentificador(cabecera_factura)
							if cabecera_factura.save!

								res_valid                           = CabeceraFactura.update_secuencias(params, data_secuencias)
								if res_valid.status_valid


									saco = Articulo.find_by_nombre("Saco sistema")
									res.set_data(cabecera_factura, {all: true, saco_sistema: saco})

									realizando = params["tipo_factura_id"] == 5 ? "Nota de crédito" : params["tipo_factura_id"] == 4 ? "Nota de debito" : "Factura"
									res.add_msg("#{realizando} creada correctamente.")
								else
									res.add_msgs(res_valid.get_msgs.to_a)
									res.set_status(HTTP_STATUS_CODE[:conflict])
								end
							end

            else
              res.add_msgs(cabecera_factura.errors.to_a)
              res.set_status(HTTP_STATUS_CODE[:conflict])
            end

          else
            res.add_msgs(res_valid.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end

        else
          res.add_msg("El número de factura ya existe.")
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(res_secuencias.get_msgs.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      unless res.status_valid
        raise ActiveRecord::Rollback
      end

      return res
    end
  end

  # ===================================================================================================================================================

  def self.makeIdentificador(factura)
		fecha = factura.fecha_equivalente.kind_of?(String) ? DateTime.parse(factura.fecha_equivalente) : factura.fecha_equivalente

		array = [
			{value: "#{"%04d" % (factura.cliente_id || 0)}".reverse},
			{value: "#{"%04d" % factura.user_id}"},
			{value: "#{"%04d" % factura.detalle_facturas.length}".reverse},
			{value: "#{factura.id} ".reverse},
			{value: "#{fecha.to_i} ".reverse},
	]

		identificador = ""

		array.each do | item |
			identificador += "#{item[:value]}"
		end

		return identificador
	end


	# ===================================================================================================================================================

	def self.comprobar_serial(params)
		res = Response.new
		serial = params['serial']
		serial_split = serial.split(' ')

		obj={}

		serial_split.each_with_index do |serial_part, index|
			if index == 0
				cliente_id                    = serial_part[0,4].reverse.to_i
				obj["cliente"]                = cliente_id > 0 ? serialize_parser(Cliente.find_by_id(cliente_id), {nombre_completo: true}) : nil

				user_id                       = serial_part[4,4].to_i
				obj["user"]                   = serialize_parser(User.find_by_id(user_id), {nombre_completo: true})

				obj["cantidad_de_detalles"]   = serial_part[8,4].reverse.to_i
			else
				if index == 1
					obj["factura_id"]           = serial_part.reverse
				elsif index == 2
					fecha                       = DateTime.parse(calculateDateUTC(Time.at(serial_part.reverse.to_i)))
					obj["fecha_equivalente"]    = "#{fecha.strftime("%d/%m/%Y %I:%M:%S")}"
				end
			end
		end


		res.set_data(obj)
		return res

	end


  # ===================================================================================================================================================

  def self.find_secuencias(params)
    res = Response.new

    data_secuencias = {
      :actual_paquete_comprobante => nil,
      :actual_secuencia_factura   => nil,
      :numero_factura             => nil,
      :numero_comprobante         => nil,
    }

    if params["tipo"] == "venta" || params["is_nota"]

      res_actual_paquete                            = SecuenciaComprobante.get_paquete_rnc_by_estado(params["tipo_factura_id"], true)

      return res_actual_paquete unless res_actual_paquete.status_valid

      data_secuencias[:actual_paquete_comprobante]  = res_actual_paquete.get_data
      next_secuencia_comprobante                    = data_secuencias[:actual_paquete_comprobante]["secuencia"]
    end

    tipoFactura = TipoFactura.find_by_id(params["tipo_factura_id"])

    entidad_secuencia_id                          = !params["FACTURA_DE"].nil? ? params["FACTURA_DE"] : params["tipo_factura_id"]

    data_secuencias[:actual_secuencia_factura]    = SecuenciaFactura.find_by_tipo_factura_id(entidad_secuencia_id)
    data_secuencias[:numero_factura]              = data_secuencias[:actual_secuencia_factura]["secuencia"] + 1


    if params["FACTURA_DE"] == 14 # COMPRA
      data_secuencias[:numero_comprobante]          = params["numero_comprobante"].upcase
    else # VENTA / NOTAS
      data_secuencias[:numero_comprobante]          = "B#{tipoFactura["referencia"]}#{"%08d" % next_secuencia_comprobante}"
    end

    res.set_data(data_secuencias)
    return res
  end

  # ===================================================================================================================================================
  def self.update_secuencias(params, data_secuencias)
    res   = Response.new
    if params["FACTURA_DE"] == 14
      # --------- COMPRA ---------
      unless data_secuencias[:actual_secuencia_factura].update({ secuencia: data_secuencias[:numero_factura] })
        res.add_msg("Error actualizando la tabla de secuencia de Factura Compra")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    else
      # --------- VENTA / NOTA ---------

      res_aumento  = SecuenciaComprobante.aumentar_secuencia_comprobante(data_secuencias[:actual_paquete_comprobante]["id"]) if data_secuencias[:actual_paquete_comprobante][:is_paquete]

      if res_aumento.status_valid

        unless data_secuencias[:actual_secuencia_factura].update({ secuencia: data_secuencias[:numero_factura] })
          res.add_msg("Error actualizando la tabla de secuencia de Factura Venta")
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(res_aumento.get_msgs.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    return res
  end

  # ===================================================================================================================================================
  def self.getDetallesNotasByFactura(params)
    res = Response.new

    detalles_nota = {}
    notas = CabeceraFactura.where({ aplicada_a: params["aplicadaA"] })

    notas.each do |nota|
      arrayDetalle = nota.detalle_facturas

      arrayDetalle.each do |detalle|
        detalles_nota[detalle.detalle_factura_nota] = 0 unless detalles_nota[detalle.detalle_factura_nota]
        detalles_nota[detalle.detalle_factura_nota] += detalle.cantidad
      end
    end
    res.set_data(detalles_nota)

    return res
  end
  # ===================================================================================================================================================
  def self.calculateNextDay
    tomorrow = (DateTime.now.beginning_of_day + 1.days).strftime("%a")

    next_date = ""
    if tomorrow.downcase === "sun"
      next_date = (DateTime.now.beginning_of_day + 2.days).strftime("%Y-%m-%d")
    else
      next_date = (DateTime.now.beginning_of_day + 1.days).strftime("%Y-%m-%d")
    end

    return DateTime.parse("#{next_date}T12:00:00").in_time_zone
  end

  # ===================================================================================================================================================
  def self.get_notas_credito_debito(params, paginate_options)
    CabeceraFactura.transaction do
      res           = Response.new(paginate_options)
      tipo_factura  = TipoFactura.find_by_id(params["tipo_factura_id"])

      facturas      = CabeceraFactura.where({tipo_factura_id: params["tipo_factura_id"], estado: true}).order("cabecera_facturas.id DESC").to_a

      puts "facturas -> ".red + "#{facturas.to_json}"

      if facturas.length > 0
        saco = Articulo.find_by_nombre("Saco sistema")
        res.set_data(facturas, {all: true, saco_sistema: saco})
      else
        res.add_msg("No existen #{tipo_factura.descripcion.lowercase} con las especificaciones introducidas") unless is_adelantada
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
      return res
    end
  end

  def self.get_facturas_by_params(params, paginate_options)
    CabeceraFactura.transaction do
      res                = Response.new(paginate_options)

      campoNum           = params[:campo]
      valor_des          = desencriptarBase64(params[:valor].gsub(/\b&^IC\b/, '\\'))
      tipo_factura_id    = params[:tipo_factura_id]
      is_adelantada      = params[:is_adelantada].to_boolean
      fact_de            = params[:fact_de] ? params[:fact_de] : "venta"

      campo              = FacturasParams.get_campo_by_param(campoNum)
      valor_des          = FacturasParams.parse_valor_by_param(campoNum, valor_des)
      limit_             = campo == "last_50" ? 50 : nil

      valor_where = campo == "cliente_id" || campo == "numero_factura" ? valor_des : "'#{valor_des}' "

      where_ = "cabecera_facturas.tipo = '#{fact_de}' and cabecera_facturas.is_adelantada = #{is_adelantada} "

      where_ = "detalle_facturas.retirado < detalle_facturas.cantidad_en_unidades "  if is_adelantada

      where_ += "and cabecera_facturas.#{campo} = #{valor_where} "              unless campo == "last_50"

      where_ += "and cabecera_facturas.tipo_factura_id = #{tipo_factura_id}"    unless tipo_factura_id == "0"


      joins_ = "inner join tipo_facturas on cabecera_facturas.tipo_factura_id = tipo_facturas.id inner join users on cabecera_facturas.user_id = users.id "

      joins_ += "inner join detalle_facturas on cabecera_facturas.id = detalle_facturas.cabecera_factura_id" if is_adelantada


      facturas = CabeceraFactura.joins(joins_).where(where_).order("cabecera_facturas.id DESC").group("cabecera_facturas.id").limit(limit_).to_a

      if facturas.length > 0
        saco = Articulo.find_by_nombre("Saco sistema")
        res.set_data(facturas, {all: true, saco_sistema: saco})
      else
        res.add_msg("No existen facturas con las especificaciones introducidas") unless is_adelantada
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res
    end
  end

  # ===================================================================================================================================================
  def self.get_viajes_by_completar(params, paginate_options)
    res          = Response.new(paginate_options)

    arg          = params["arg"]
    where        = "is_viaje = true and ( fecha_completada is null or (fecha_completada between '#{DateTime.now.beginning_of_day}' and '#{DateTime.now.end_of_day}') )"
    joins_       = "inner join clientes on clientes.id = cabecera_facturas.cliente_id"

    cabeceras    = CabeceraFactura
    .joins(joins_)
    .where("#{where} and lower(cabecera_facturas.numero_comprobante || ' ' || cabecera_facturas.numero_factura || ' ' || clientes.nombre || ' ' || clientes.apellido) like lower('%#{arg}%') ")
    .order("cabecera_facturas.id DESC").group("cabecera_facturas.id").to_a


    if cabeceras.length > 0
      saco = Articulo.find_by_nombre("Saco sistema")
      res.set_data(cabeceras, {all: true, saco_sistema: saco})
    else
      res.add_msg("No existen facturas con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================
  def self.get_facturas_by_cliente_id_and_estado(params, paginate_options)
    res                          = Response.new(paginate_options)
    joins                        = "inner join tipo_facturas on cabecera_facturas.tipo_factura_id = tipo_facturas.id  inner join users on cabecera_facturas.user_id = users.id"
    where                        = "cliente_id=#{params["cliente_id"]} and pagada=#{params["pagada"]} and tipo='venta' and condicion='Crédito' and cabecera_facturas.estado=true"

    cabeceras                    = CabeceraFactura.joins(joins).where(where).order("cabecera_facturas.id DESC").group("cabecera_facturas.id").to_a

    cabe_viajes_contado_deviendo = CabeceraFactura.where({ cliente_id: params["cliente_id"], is_viaje: true, condicion: "Contado", estado: true }).where.not(balance: 0).to_a

    cabeceras.concat cabe_viajes_contado_deviendo

    if cabeceras.length > 0
      saco = Articulo.find_by_nombre("Saco sistema")
      res.set_data(cabeceras, {all: true, saco_sistema: saco})
    else
      res.add_msg("El cliente buscado no tiene facturas pendientes.")
      res.set_status(HTTP_STATUS_CODE[:not_found])
    end

    return res
  end

  # ====================================================================================================

  def verificateFacturaHasPagos()
    res     = Response.new
    pagos   = DetalleRecibo.where({ cabecera_factura_id: self.id })
    res.set_data(pagos.length > 0 )
    return res
  end

  # ====================================================================================================

  def verificateFacturaHasNotas()
    res     = Response.new
    notas   = CabeceraFactura.where({ aplicada_a: self.numero_comprobante })
    res.set_data(notas.length > 0)
    return res
  end

  # ====================================================================================================

  def verificateCanUpdateViaje(factura)
    res                = Response.new
    res_pagos          = factura.verificateFacturaHasPagos
    ha_recibido_pagos  = res_pagos.get_data

    res.set_data({is_viaje: self.is_viaje, can_update: !ha_recibido_pagos})
    return
  end

    # ====================================================================================================
  def self.verificateCanUpdate(id)
    res            = Response.new
    factura        = CabeceraFactura.find_by_id(id)
    last_cuadre    = CuadreCaja.all.last

    if factura
      msg_             = nil

      if last_cuadre.nil? || comparar_fecha(calculateDateUTC(factura[:fecha_equivalente]).to_s, calculateDateUTC(last_cuadre[:created_at]).to_s, ">=")


        # ver si la factura tiene algun pago.
        res_pagos        = factura.verificateFacturaHasPagos
        has_pagos        = res_pagos.get_data
        msg_             = "La factura no puede ser editada, por que ya ha recibido pagos anteriormente." if has_pagos && !factura.is_contado

        # ver si la factura tiene alguna nota de credito.
        res_notas        = factura.verificateFacturaHasNotas
        has_hotas        = res_notas.get_data
        msg_             = "La factura no puede ser editada, por que ha sido modificada por una nota." if has_hotas

        if has_hotas || (has_pagos && !factura.is_contado)
          res.add_msg(msg_)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        return res unless res.status_valid

      else
        res_verificate   = factura.verificateCanUpdateViaje
        verificacion     = res_verificate.get_data

        msg_             = "La factura no puede ser editada, por que no es del dia de hoy."                           if !verificacion[:is_viaje] && !verificacion[:can_update]
        msg_             = "La factura no puede ser editada, por que el viaje ya ha recibido un pago anteriormente."  if verificacion[:is_viaje] && !verificacion[:can_update]

        res.set_status(HTTP_STATUS_CODE[:conflict]) if !verificacion[:can_update]
      end

      res.data({canUpdate: true}) unless msg_.nil?
      res.add_msg(msg_) unless msg_.nil?
    else
      res.add_msg("No se encuentra la factura a editar, contactar a Victor José Vásquez.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ====================================================================================================
  def self.updateFactura(params)
    CabeceraFactura.transaction do
      res                  = Response.new
      res_validado         = verificateCanUpdate(params["id"])

      if res_validado.status_valid

        factura_de         = params['FACTURA_DE']
        factura_nueva      = params

        factura_original   = CabeceraFactura.find_by_id(params["id"])


        if factura_original.condicion == "Crédito"
          calculo_para_balancear_cliente  = factura_nueva["total_factura"] - factura_original.total_factura
          resultCliente                   = Cliente.calculate_balance_cliente(factura_original.cliente_id, calculo_para_balancear_cliente, "+")

          unless resultCliente.status_valid
            res.add_msg(resultCliente.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
            return res
          end
        end

        res_detalles                      = DetalleFactura.proceso_editar_detalles(factura_nueva, factura_original)

        if res_detalles.status_valid
          factura_original.total_factura   = factura_nueva['total_factura']
          factura_original.itbis           = factura_nueva['itbis']
          factura_original.descuento       = factura_nueva['descuento']
          factura_original.Bruto           = factura_nueva['Bruto']
          factura_original.pagada          = factura_nueva['pagada']
          factura_original.balance         = factura_nueva['balance']
          factura_original.devuelta        = factura_nueva['devuelta']

          if factura_original.save!
            res.add_msg("Factura editada correctamente.")
            saco = Articulo.find_by_nombre("Saco sistema")
            factura_editada                = CabeceraFactura.find_by_id(params["id"])
            res.set_data(factura_editada, {all: true, saco_sistema: saco})
          else
            res.add_msgs(factura_original.errors.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end

        else
          res.add_msgs(res_detalles.get_msgs.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(res_validado.get_msgs.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res
      raise ActiveRecord::Rollback unless res.status_valid
    end
  end


  # ====================================================================================================
  def self.payFactura(factura_id, recibo)
    CabeceraFactura.transaction do
      res               = Response.new
      factura_a_pagar   = CabeceraFactura.find_by_id(factura_id)

      newBalance                          = factura_a_pagar["balance"] - recibo["deposito"]
      is_pago_total                       = newBalance < 1 || recibo["deposito"] == factura_a_pagar["balance"]

      factura_a_pagar.balance             = newBalance >= 1 ? newBalance : 0
      factura_a_pagar.pagada              = true           if is_pago_total
      factura_a_pagar.fecha_completada    = DateTime.now   if is_pago_total

      unless factura_a_pagar.save!
        res.add_msgs(factura_a_pagar.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res
    end
  end

  # =====================================================================================================================
  def self.anular_factura(params)
    res               = Response.new
    cabecera          = CabeceraFactura.find_by_id(params["id"])
    cabecera.estado   = false

    if cabecera.condicion == "Crédito" && ( cabecera.tipo == "venta" || cabecera.is_viaje )
      res_valid       = Cliente.calculate_balance_cliente(cabecera.cliente_id, cabecera.total_factura, "-")
    end

    if res_valid.status_valid && cabecera.save!
      res.add_msg("Factura anulada correctamente.")
    else
      res.add_msgs(res_valid.get_msgs.to_a)
      res.add_msgs(cabecera.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =====================================================================================================================
  def self.calculateNextBalanceFactura(id, montoRecibido)
    res = Response.new

      factura                     = CabeceraFactura.find_by_id(id)
      balance                     = factura.balance
      sumatoria                   = 0

      if montoRecibido.to_f > balance
        res.set_data({ :balance => 0, :balance_anterior => balance, :devolucion => (montoRecibido.to_f - balance), :factura => factura})
      else
        sumatoria = (balance - montoRecibido.to_f).to_d.truncate(2).to_f
        res.set_data({ :balance => sumatoria, :balance_anterior => balance, :devolucion => 0, :factura => factura})
      end

    return res
  end

  # =====================================================================================================================
  def self.agregar_nota_a_CabeceraFactura(id, nota)
    res                 = Response.new
    factura             = CabeceraFactura.find_by_id(id)

    factura.balance     = factura.balance - (nota["total_factura"].to_d).abs
    factura.estado      = false if factura.balance < 1
    factura.tiene_nota  = true

    unless factura.save!
      res.add_msgs(factura.errors.to_a)
      res.add_msg("Error agregando nota la factura")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
