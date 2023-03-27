class CabeceraFactura < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :suplidor, optional: true
  belongs_to :cliente, optional: true
  belongs_to :user

  has_many :detalle_facturas, dependent: :destroy
  has_many :detalle_recibos, dependent: :destroy
  has_many :facturas_aplicadas
  # TODO: quitar esto despues de que todo este modificado
  has_many :camiones_viajes, :as => :origen, dependent: :destroy, class_name: "CamionViaje"
  has_many :movimientos_viaje, dependent: :destroy


  # ===================================================================================================================================================

  def otras_validaciones(params, tipo_de_factura)

    documento = tipo_de_factura.descripcion == TiposFacturasDescripcion.cotizacion  ? 'Cotización' : tipo_de_factura.descripcion == TiposFacturasDescripcion.pre_venta ? 'Pre-Venta' : 'Factura'

    self.errors.add(:base, "Total de la #{documento} no puede estar vacio.")   if self.total_factura == nil
    self.errors.add(:base, "Total de la #{documento} no puede estar vacio.")   if self.Bruto == nil

    if self.is_viaje && self.cliente_id == nil
      self.errors.add(:base, "Para realizar una factura de viajes, tiene que seleccionar un cliente.")
    end

  end

  # ===================================================================================================================================================


  def self.models_includes
    user_includes   = [:documentos_de_identidad, :roles_permisos_acciones ]
    includes = [ :tipo_factura,
        :suplidor,
        {cliente: :documentos_de_identidad},
        {user: user_includes},
        {detalle_facturas: {articulo: [:tipo_articulo, :contenido_articulos]}},
        {detalle_recibos: {recibos_ingreso: :user}},
        {movimientos_viaje: [:vehiculo, :user]},
        {facturas_aplicadas: [:nota, {detalles_facturas_notas:[:articulo]}]}
    ]
    return includes
  end

  # ===================================================================================================================================================

  def is_contado
    return self.condicion == 'Contado'
  end

  # ===================================================================================================================================================

  def self.create_factura(params , is_save=false)
    res                                    = Response.new
    @tipo_de_documento                     = TipoFactura.find_by_id(params['FACTURA_DE'])
    @tipo_de_factura                       = TipoFactura.find_by_id(params['tipo_factura_id'])

    CabeceraFactura.transaction do
      res_secuencias                       = CabeceraFactura.find_secuencias(params)
      if res_secuencias.status_valid

        data_secuencias                    = res_secuencias.get_data
        num_factura_blank                  = CabeceraFactura.where({numero_factura: data_secuencias[:numero_factura], tipo: params["tipo"], tipo_factura_id: params["tipo_factura_id"], condicion: params['condicion']})

        if num_factura_blank.blank?

          res_valid                        = Response.new

          if params["condicion"] == "Crédito" && params["tipo"] != TiposFacturasDescripcion.compra.downcase
          res_valid                      = Cliente.calculate_balance_cliente(params["cliente_id"], params["total_factura"], "+")
          end

          if res_valid.status_valid

            today_cuadre                              = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})
            cabecera_factura                          = CabeceraFactura.new

            cabecera_factura.fecha_equivalente        = params[:fecha_equivalente] ? params[:fecha_equivalente] : today_cuadre.blank? ? DateTime.now : CabeceraFactura.calculateNextDay
            cabecera_factura.fecha_completada         = params[:condicion] == 'Contado' ? cabecera_factura.fecha_equivalente : nil
            cabecera_factura.user_id                  = get_current_user[:id]
            cabecera_factura.numero_comprobante       = data_secuencias[:numero_comprobante]
            cabecera_factura.numero_factura           = data_secuencias[:numero_factura]
            cabecera_factura.estado                   = true

            cabecera_factura.tipo_factura_id          = params[:tipo_factura_id]
            cabecera_factura.suplidor_id              = params[:suplidor_id]
            cabecera_factura.cliente_id               = params[:cliente_id]
            cabecera_factura.fecha_viaje              = params[:fecha_viaje]
            cabecera_factura.fecha_vencimiento        = params[:fecha_vencimiento]
            cabecera_factura.fecha_valida             = params[:fecha_valida]
            cabecera_factura.condicion                = params[:condicion]
            cabecera_factura.forma_pago               = params[:forma_pago]
            cabecera_factura.total_factura            = params[:total_factura]
            cabecera_factura.itbis                    = params[:itbis]
            cabecera_factura.descuento                = params[:descuento]
            cabecera_factura.Bruto                    = params[:Bruto]
            cabecera_factura.tipo                     = params[:tipo]
            cabecera_factura.NoCliente_nombre         = params[:NoCliente_nombre]
            cabecera_factura.NoCliente_direccion      = params[:NoCliente_direccion]
            cabecera_factura.costoYgasto              = params[:costoYgasto]
            cabecera_factura.pagada                   = params[:pagada]
            cabecera_factura.vendedor_id              = params[:vendedor_id]
            cabecera_factura.balance                  = params[:balance]
            cabecera_factura.devuelta                 = params[:devuelta]
            cabecera_factura.is_adelantada            = params[:is_adelantada]
            cabecera_factura.is_nota                  = params[:is_nota]
            cabecera_factura.is_viaje                 = params[:is_viaje]
            cabecera_factura.tiene_nota               = params[:tiene_nota]
            cabecera_factura.pre_factura              = params[:pre_factura]
            cabecera_factura.cotizacion               = params[:cotizacion]

            cabecera_factura.otras_validaciones(params, @tipo_de_factura)

            dependencias = [
              {modelo: DetalleFactura,     key_object: 'detalle_facturas',   padre: cabecera_factura},
              {modelo: MovimientoViaje,    key_object: 'movimientos_viaje',  padre: cabecera_factura},
            ]

            res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
              cabecera_factura.detalle_facturas   = dependencia_data if key_object == 'detalle_facturas'
              cabecera_factura.movimientos_viaje  = dependencia_data if key_object == 'movimientos_viaje'
            }

            if res.status_valid && cabecera_factura.errors.empty? && (!is_save || (is_save && cabecera_factura.save!))

              cabecera_factura.identificador      = CabeceraFactura.makeIdentificador(cabecera_factura)
              if cabecera_factura.save!

                res_valid                         = CabeceraFactura.update_secuencias(params, data_secuencias)
                res_valid                         = cabecera_factura.procesos_cabecera() if res_valid.status_valid

                if res_valid.status_valid
                  res.set_data(cabecera_factura, {all: true})

                  documento =  @tipo_de_factura.descripcion == TiposFacturasDescripcion.cotizacion  ? 'Cotización' : @tipo_de_factura.descripcion == TiposFacturasDescripcion.pre_venta ? 'Pre-Venta' : 'Factura'

                  res.add_msg("#{documento} creada correctamente.")
                else
                  res.add_msgs(res_valid.get_msgs.to_a)

                  res.set_status(HTTP_STATUS_CODE[:conflict])
                end

              else
                res.add_msgs(cabecera_factura.errors.to_a)
                res.set_status(HTTP_STATUS_CODE[:conflict])
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
          res.add_msg('El número de factura ya existe.')
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(res_secuencias.get_msgs.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback unless res.status_valid
    end

    return res
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
        obj['cliente']                = cliente_id > 0 ? serialize_parser(Cliente.find_by_id(cliente_id), {nombre_completo: true}) : nil

        user_id                       = serial_part[4,4].to_i
        obj['user']                   = serialize_parser(User.find_by_id(user_id), {nombre_completo: true})

        obj['cantidad_de_detalles']   = serial_part[8,4].reverse.to_i
      else
        if index == 1
          obj['factura_id']           = serial_part.reverse
        elsif index == 2
          fecha                       = DateTime.parse(calculateDateUTC(Time.at(serial_part.reverse.to_i)))
          obj['fecha_equivalente']    = "#{fecha.strftime("%d/%m/%Y %I:%M:%S")}"
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
      :actual_secuencia_entidad   => nil,
      :numero_factura             => nil,
      :numero_comprobante         => nil,
    }

    if params['tipo'] == 'venta' && @tipo_de_factura.descripcion != TiposFacturasDescripcion.pre_venta

      res_actual_paquete                            = SecuenciaComprobante.get_paquete_rnc_by_estado(params['tipo_factura_id'], true)

      return res_actual_paquete unless res_actual_paquete.status_valid

      data_secuencias[:actual_paquete_comprobante]  = res_actual_paquete.get_data
      next_secuencia_comprobante                    = data_secuencias[:actual_paquete_comprobante]['secuencia']
    end

    entidad_secuencia_id                            = !params['FACTURA_DE'].nil? ? params['FACTURA_DE'] : params['tipo_factura_id']

    data_secuencias[:actual_secuencia_entidad]      = SecuenciaFactura.find_by_tipo_factura_id(entidad_secuencia_id)
    data_secuencias[:numero_factura]                = data_secuencias[:actual_secuencia_entidad]['secuencia'] + 1

    numero_comprobante                              = params['tipo'] == TiposFacturasDescripcion.compra.downcase ? params['numero_comprobante'].upcase : params['tipo'] == 'venta' ? "B#{@tipo_de_factura.referencia}#{"%08d" % next_secuencia_comprobante}" : nil
    data_secuencias[:numero_comprobante]            = numero_comprobante


    res.set_data(data_secuencias)
    return res
  end

  # ===================================================================================================================================================

  def procesos_cabecera()
    res               = Response.new

    unless self.pre_factura.nil?
      res = CabeceraFactura.payFactura(self.pre_factura, {'deposito' => self.total_factura}, true)
    end

    unless self.cotizacion.nil?
      res = CabeceraFactura.payFactura(self.cotizacion, {'deposito' => self.total_factura}, true)
    end

    return res
  end

  # ===================================================================================================================================================
  def self.update_secuencias(params, data_secuencias)
    res   = Response.new
    if @tipo_de_documento.descripcion == TiposFacturasDescripcion.compra
      # --------- COMPRA ---------
      unless data_secuencias[:actual_secuencia_entidad].update({ secuencia: data_secuencias[:numero_factura] })
        res.add_msg('Error actualizando la tabla de secuencia de Factura Compra')
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    else
      # --------- VENTA / NOTA ---------

      if data_secuencias[:actual_secuencia_entidad].update({ secuencia: data_secuencias[:numero_factura] })

        res_aumento  = nil
        res_aumento  = SecuenciaComprobante.aumentar_secuencia_comprobante(data_secuencias[:actual_paquete_comprobante]["id"]) if !data_secuencias[:actual_paquete_comprobante].nil? &&  data_secuencias[:actual_paquete_comprobante][:is_paquete]

        unless res_aumento.nil?
          unless res_aumento.status_valid
            res.add_msgs(res_aumento.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end
        end

      else
        res.add_msg('Error actualizando la tabla de secuencia de Factura Venta')
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    end

    return res
  end


  # ===================================================================================================================================================
  def self.calculateNextDay
    tomorrow = (DateTime.now.beginning_of_day + 1.days).strftime('%a')

    next_date = ""

    if tomorrow.downcase === 'sun'
      next_date = (DateTime.now.beginning_of_day + 2.days).strftime('%Y-%m-%d')
    else
      next_date = (DateTime.now.beginning_of_day + 1.days).strftime('%Y-%m-%d')
    end

    return DateTime.parse("#{next_date}T12:00:00").in_time_zone
  end

  # ===================================================================================================================================================
  def self.get_group_facturas_by_id(params)
    res                = Response.new()

    ids                = params[:ids].split(",").map(&:to_i)
    facturas           = CabeceraFactura.where(id: ids).includes(CabeceraFactura.models_includes)

    res.set_data(facturas, {all: true})

    return res
  end

  # ===================================================================================================================================================
  # def self.get_one_by_id(params)
  # end
  # ===================================================================================================================================================

  def self.get_facturas_by_params(params, paginate_options)
    res                  = Response.new(paginate_options)

    campoNum           = params[:campo]
    valor_des          = params[:valor].present? ? desencriptarBase64(params[:valor].gsub(/\b&^IC\b/, '\\')) : ''
    tipo_factura_id    = params[:tipo_factura_id]
    is_adelantada      = params[:is_adelantada] != '0' ? params[:is_adelantada].to_boolean : false
    tipo               = params[:tipo] ? params[:tipo] : 'venta'
    pagada             = params[:pagada] != '0' ? params[:pagada].to_boolean : '0'
    estado             = params[:estado] != '0' ? params[:estado].to_boolean : '0'


    campo              = FacturasParams.get_campo_by_param(campoNum)
    valor_des          = FacturasParams.parse_valor_by_param(campoNum, valor_des)
    limit_             = campo == FacturasParams.last_50 ? 50 : nil


    valor_where = campo == FacturasParams.cliente_id || campo == FacturasParams.numero_factura ? valor_des : "'#{valor_des}' "

    where_ = "cabecera_facturas.tipo = '#{tipo}' "
    where_ += "AND cabecera_facturas.is_adelantada = #{is_adelantada} "                                               if is_adelantada
    where_ += "AND (detalle_facturas.retirado < detalle_facturas.cantidad_en_unidades and articulos.estado = true) "  if is_adelantada
    where_ += "AND cabecera_facturas.#{campo} = #{valor_where} "                                                      unless campo == FacturasParams.last_50 || campo == FacturasParams.todas
    where_ += "AND cabecera_facturas.tipo_factura_id = #{tipo_factura_id}"                                            unless tipo_factura_id == "0"
    where_ += "AND cabecera_facturas.pagada = #{pagada} "                                                             if params[:pagada].present? && pagada != "0"
    where_ += "AND cabecera_facturas.estado = #{estado} "                                                             if params[:estado].present? && estado != "0"

    joins_ = 'inner join tipo_facturas on cabecera_facturas.tipo_factura_id = tipo_facturas.id inner join users on cabecera_facturas.user_id = users.id '
    joins_ += 'inner join detalle_facturas on cabecera_facturas.id = detalle_facturas.cabecera_factura_id ' if is_adelantada
    joins_ += 'inner join articulos on detalle_facturas.articulo_id = articulos.id'                         if is_adelantada

    facturas = CabeceraFactura.joins(joins_).where(where_).order('cabecera_facturas.id DESC').group('cabecera_facturas.id').limit(limit_)

    if facturas.length > 0
      res.set_data(facturas, {all: true}, CabeceraFactura.models_includes)
    else
      cantidad_registros = CabeceraFactura.all.count

      documento =  tipo == TiposFacturasDescripcion.cotizacion  ? 'Cotizaciones' : tipo == TiposFacturasDescripcion.pre_venta ? 'Pre-Ventas' : 'Facturas'

      res.add_msg("No existen #{documento} con las especificaciones introducidas") if !is_adelantada && cantidad_registros != 0
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================
  def self.get_viajes_by_completar(params, paginate_options)
    res                  = Response.new(paginate_options)

    palabra_a_buscar     = params["palabra_a_buscar"]
    where                = "is_viaje = true AND cabecera_facturas.estado = true AND ( fecha_completada is null or (fecha_completada between '#{DateTime.now.beginning_of_day}' AND '#{DateTime.now.end_of_day}') )"
    joins_               = 'inner join clientes on clientes.id = cabecera_facturas.cliente_id'

    cabeceras    = CabeceraFactura
    .joins(joins_)
    .where("#{where} AND lower(cabecera_facturas.numero_comprobante || ' ' || cabecera_facturas.numero_factura || ' ' || clientes.nombre || ' ' || clientes.apellido) like lower('%#{palabra_a_buscar}%') ")
    .order('cabecera_facturas.id DESC').group('cabecera_facturas.id')

    if cabeceras.length > 0
      res.set_data(cabeceras, {all: true, movimientos_viaje: true}, CabeceraFactura.models_includes)
    else
      cantidad_registros = CabeceraFactura.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen facturas registradas.' : 'No existen facturas con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================
  def self.get_facturas_by_cliente_id_and_estado(params, paginate_options)
    res                          = Response.new(paginate_options)

    where                        = "cliente_id=#{params["cliente_id"]} AND pagada=#{params["pagada"]} AND tipo='venta' AND condicion='Crédito' AND cabecera_facturas.estado=true"

    cabeceras                    = CabeceraFactura.where(where).order('cabecera_facturas.id DESC').group('cabecera_facturas.id').to_a

    cabe_viajes_contado_deviendo = CabeceraFactura.where({ cliente_id: params[:cliente_id], is_viaje: true, condicion: 'Contado', estado: true }).where.not(balance: 0).to_a

    cabeceras.concat cabe_viajes_contado_deviendo

    if cabeceras.length > 0
      res.set_data(cabeceras, {all: true}, CabeceraFactura.models_includes)
    else
      res.add_msg('El cliente buscado no tiene facturas pendientes.')
      res.set_status(HTTP_STATUS_CODE[:not_found])
    end

    return res
  end

  # ====================================================================================================

  def verificateFacturaHasPagos()
    res     = Response.new
    pagos   = DetalleRecibo.where({ cabecera_factura_id: self.id })

    res.set_data(pagos.length > 0 || self.balance < self.total_factura)
    return res
  end

  # ====================================================================================================

  def verificateFacturaHasNotas()
    res         = Response.new
    has_notas   = self.facturas_aplicadas.length > 0
    res.set_data(has_notas)
    return res
  end

  # ====================================================================================================

  def verificateCanUpdateViaje()
    res                = Response.new
    res_pagos          = self.verificateFacturaHasPagos
    ha_recibido_pagos  = res_pagos.get_data

    res.set_data({is_viaje: self.is_viaje, can_update: !ha_recibido_pagos})
    return res
  end

    # ====================================================================================================
  def self.verificate_can_update_factura(id)
    res            = Response.new
    factura        = CabeceraFactura.find_by_id(id)
    last_cuadre    = CuadreCaja.all.last

    if factura
      msg_             = nil

      if last_cuadre.nil? || comparar_fecha(calculateDateUTC(factura[:fecha_equivalente]).to_s, calculateDateUTC(last_cuadre[:fecha_equivalente]).to_s, ">=")


        # ver si la factura tiene algun pago.
        res_pagos        = factura.verificateFacturaHasPagos
        has_pagos        = res_pagos.get_data
        msg_             = 'La factura no puede ser editada, por que ya ha recibido pagos anteriormente.' if has_pagos && !factura.is_contado

        # ver si la factura tiene alguna nota de credito.
        res_notas        = factura.verificateFacturaHasNotas
        has_hotas        = res_notas.get_data
        msg_             = 'La factura no puede ser editada, por que ha sido modificada por una nota.' if has_hotas

        if has_hotas || (has_pagos && !factura.is_contado)
          res.add_msg(msg_)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        return res unless res.status_valid

      else
        res_verificate   = factura.verificateCanUpdateViaje
        verificacion     = res_verificate.get_data

        msg_             = 'La factura no puede ser editada, por que no es del dia de hoy.'                           if !verificacion[:is_viaje] && !verificacion[:can_update]
        msg_             = 'La factura no puede ser editada, por que el viaje ya ha recibido un pago anteriormente.'  if verificacion[:is_viaje] && !verificacion[:can_update]

        res.set_status(HTTP_STATUS_CODE[:conflict]) if !verificacion[:can_update]
      end

      res.set_data({canUpdate: true}) unless msg_.nil?
      res.add_msg(msg_) unless msg_.nil?
    else
      res.add_msg('No se encuentra la factura a editar, contactar a Victor José Vásquez.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ====================================================================================================
  def self.updateFactura(params)
    res                    = Response.new
    CabeceraFactura.transaction do
      res_validado         = verificate_can_update_factura(params[:id])

      if res_validado.status_valid

        factura_de         = params['FACTURA_DE']
        factura_nueva      = params

        factura_original   = CabeceraFactura.find_by_id(params[:id])

        if factura_original.condicion == 'Crédito'
          calculo_para_balancear_cliente  = factura_nueva['total_factura'] - factura_original.total_factura
          resultCliente                   = Cliente.calculate_balance_cliente(factura_original.cliente_id, calculo_para_balancear_cliente, "+")

          unless resultCliente.status_valid
            res.add_msg(resultCliente.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
            return res
          end
        end

        res_detalles                       = DetalleFactura.proceso_editar_detalles(factura_nueva, factura_original)

        if res_detalles.status_valid
          factura_original.total_factura   = factura_nueva['total_factura']
          factura_original.itbis           = factura_nueva['itbis']
          factura_original.descuento       = factura_nueva['descuento']
          factura_original.Bruto           = factura_nueva['Bruto']
          factura_original.pagada          = factura_nueva['pagada']
          factura_original.balance         = factura_nueva['balance']
          factura_original.devuelta        = factura_nueva['devuelta']
          factura_original.forma_pago      = factura_nueva['forma_pago']

          if factura_original.save!
            factura_editada                = CabeceraFactura.find_by_id(params['id'])
            res.set_data(factura_editada, {all: true})
            res.add_msg('Factura editada correctamente.')
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

      transaction_rollback if !factura_original.errors.empty? || !res.status_valid
    end

    return res
  end

  # =====================================================================================================================

  def self.update_movimientos_viaje(params)
    res                          = Response.new
    factura                      = CabeceraFactura.find_by_id(params[:id])
    CabeceraFactura.transaction do
      # TODO: validar que los campos necesarios del movimiento lleguen

      factura.movimientos_viaje.each do | movimiento |
        movimiento.vehiculo.ajustarCantViaje('-') unless movimiento.vehiculo_id.nil?
        movimiento.destroy
      end

      dependencias                 = [ {modelo: MovimientoViaje,    key_object: 'movimientos_viaje',  padre: factura} ]

      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
        factura.movimientos_viaje  = dependencia_data if key_object == 'movimientos_viaje'
      }

      if factura.save!
        res.add_msg('Pedido actualizado correctamente.')
      else
        res.add_msgs(factura.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !factura.errors.empty? || !res.status_valid
    end

    return res
  end

  # ====================================================================================================
  def self.payFactura(factura_id, recibo, is_pago_total = false)
    res               = Response.new
    CabeceraFactura.transaction do
      factura_a_pagar   = CabeceraFactura.find_by_id(factura_id)
      newBalance                          = factura_a_pagar['balance'] - recibo['deposito']
      is_pago_total                       = is_pago_total ? is_pago_total : newBalance < 1 || recibo['deposito'] == factura_a_pagar['balance']

      factura_a_pagar.balance             = newBalance >= 1 ? newBalance : 0
      factura_a_pagar.pagada              = true           if is_pago_total
      factura_a_pagar.fecha_completada    = DateTime.now   if is_pago_total

      unless factura_a_pagar.save!
        res.add_msgs(factura_a_pagar.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !factura_a_pagar.errors.empty? || !res.status_valid
    end

    return res
  end


  # =====================================================================================================================
  def self.delete_documentos(params)
    res                 = Response.new
    res_valid           = Response.new

    ids                 = params[:ids].split(",").map(&:to_i)
    documentos          = CabeceraFactura.where(id: ids).includes(CabeceraFactura.models_includes)
    obj_deleted         = { success: [], error: [] }.with_indifferent_access

    documentos.each do | documento |
      success_deleted   = true

      if documento.tipo != TiposFacturasDescripcion.cotizacion && documento.tipo != TiposFacturasDescripcion.compra.downcase && documento.condicion == 'Crédito' || documento.is_viaje
        res_valid       = Cliente.calculate_balance_cliente(documento.cliente_id, documento.total_factura, "-")
      end

      if res_valid.status_valid

        if documento.tipo != TiposFacturasDescripcion.cotizacion
          res_valid     = DetalleFactura.proceso_borrar_detalles(documento)
        end

        if params[:tipo] == 'anular'
          documento.estado  = false
          success_deleted   = false unless documento.save!

        elsif params[:tipo] == 'delete'
          success_deleted   = false unless documento.destroy
        end

        if success_deleted
        else
        end
        type                = success_deleted ? 'success' : 'error'
        obj_deleted[type].push(documento)

      else
        obj_deleted[:error].push(documento)
      end

    end

    res.set_data(obj_deleted)
    return res
  end

  # ---------------------------------------------------------------------------------------------------------------------
  def procesos_delete(data)

  end

  # =====================================================================================================================

  def get_total_modificado_por_notas(tipo)
    aplicaciones_en_notas           = FacturaAplicada.where(cabecera_factura_id: self.id)
    total_modificado                = 0

    aplicaciones_en_notas.each do |fact_aplicada|
      tipo_nota = fact_aplicada.tipo_nota

      if tipo_nota    == tipo
        total_modificado += fact_aplicada.total

      elsif tipo_nota == tipo
        total_modificado += fact_aplicada.total

      end

    end

    return total_modificado
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
  def self.agregar_nota_a_CabeceraFactura(factura_aplicada, nota)
    res                 = Response.new
    factura             = CabeceraFactura.find_by_id(factura_aplicada[:cabecera_factura_id])
    dias_de_creada      = (DateTime.now - Date.parse(factura.fecha_equivalente.to_s)).to_i
    operador            = nota.tipo_nota == TiposNotas.credito ? '-' : '+'


    total_en_favor_factura     = factura.total_factura
    total_en_favor_factura    += factura.get_total_modificado_por_notas(TiposNotas.debito)
    total_en_favor_factura    -= factura.itbis if dias_de_creada >= 30

    total_en_favor_factura    -= factura.itbis if dias_de_creada >= 30

    total_en_contra_factura    = factura.get_total_modificado_por_notas(TiposNotas.credito) + (factura_aplicada[:total].to_d).abs

    factura.balance      = eval "#{factura.balance} #{operador} #{(factura_aplicada[:total].to_d).abs}" if !factura.is_contado || ( factura.is_viaje && !factura.pagada )
    factura.estado       = false if (total_en_favor_factura - total_en_contra_factura) < 1
    factura.tiene_nota   = true

    unless factura.save!
      res.add_msgs(factura.errors.to_a)
      res.add_msg('Error agregando nota la factura')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
