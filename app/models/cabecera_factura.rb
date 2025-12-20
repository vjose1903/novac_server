class CabeceraFactura < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :suplidor, optional: true
  belongs_to :cliente,  optional: true
  belongs_to :user

  has_many :detalle_facturas, dependent: :destroy
  has_many :detalle_recibos,  dependent: :destroy
  has_many :facturas_aplicadas

  has_one  :document_reference_as_origin,     :as => :document_origin,     dependent: :destroy, class_name: 'DocumentReference'
  has_one  :document_reference_as_referenced, :as => :document_referenced, dependent: :destroy, class_name: 'DocumentReference'

  has_many :movimientos_viaje, dependent: :destroy

  validates :tipo_factura,              presence: { :message => 'El tipo de la factura no puede estar vacio.' }

  # Callbacks
  after_create :generar_identificador

  # ===================================================================================================================================================

  private

  def generar_identificador
    update_column(:identificador, make_identificador)
  end

  public

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
        {facturas_aplicadas: [:nota, {detalles_facturas_notas:[:articulo]}]},
        :document_reference_as_origin,
        :document_reference_as_referenced
    ]
    return includes
  end

  # ===================================================================================================================================================

  def is_contado
    return self.condicion == 'Contado'
  end

  # ===================================================================================================================================================

  def self.create_factura(params, is_save = false)
    res                            = Response.new
    @tipo_de_documento             = TipoFactura.find_by_id(params[:FACTURA_DE])
    @tipo_de_factura               = TipoFactura.find_by_id(params[:tipo_factura_id])
    @increment_secuencia_comprobante = false
    @is_electronica                = params[:serie].present? && params[:serie] == SerieFactura.electronica
    @res_valid_dgii                = nil

    CabeceraFactura.transaction do
      res = validar_y_crear_factura(params, is_save)
      raise ActiveRecord::Rollback unless res.status_valid
    end

    @res_valid_dgii&.status_valid == false ? @res_valid_dgii : res
  end
  

  def self.validar_y_crear_factura(params, is_save)
    res = Response.new

    # Validar secuencias
    res_secuencias = CabeceraFactura.find_secuencias(params)
    return set_error_response(res, res_secuencias.get_msgs.to_a) unless res_secuencias.status_valid

    data_secuencias = res_secuencias.get_data

    # Validar que no exista la factura
    factura_existente = CabeceraFactura.exists?(
      numero_factura: data_secuencias[:numero_factura],
      tipo: params[:tipo],
      tipo_factura_id: params[:tipo_factura_id],
      condicion: params[:condicion],
      serie: params[:serie]
    )
    return set_error_response(res, "El número de factura ya existe.") if factura_existente

    # Validar balance del cliente si es crédito
    if requiere_validacion_credito?(params)
      res_balance = Cliente.calculate_balance_cliente(params[:cliente_id], params[:total_factura], '+')
      return set_error_response(res, res_balance.get_msgs.to_a) unless res_balance.status_valid
    end

    # Crear cabecera
    cabecera_factura = build_cabecera_factura(params, data_secuencias)

    # Crear dependencias
    res = crear_dependencias_factura(cabecera_factura, params)
    return set_error_response(res, cabecera_factura.errors.to_a) unless res.status_valid && cabecera_factura.errors.empty?

    # Guardar factura (el identificador se genera automáticamente via after_create)
    return set_error_response(res, cabecera_factura.errors.to_a) unless cabecera_factura.save!

    # Procesar DGII si aplica
    procesar_dgii(cabecera_factura)

    # Actualizar secuencias y procesos
    res_valid = CabeceraFactura.update_secuencias(data_secuencias)
    res_valid = cabecera_factura.procesos_cabecera if res_valid&.status_valid || res_valid.nil?

    return set_error_response(res, res_valid.get_msgs.to_a) unless res_valid.status_valid

    # Respuesta exitosa
    res.set_data(cabecera_factura, { all: true, movimientos_viaje: true })
    res.add_msg("#{nombre_documento} creada correctamente.")
    res
  end

  private_class_method def self.requiere_validacion_credito?(params)
    return false unless params[:condicion] == 'Crédito'

    tipo_downcase = params[:tipo].downcase
    tipo_downcase != TiposFacturasDescripcion.compra.downcase &&
      tipo_downcase != TiposFacturasDescripcion.cotizacion.downcase
  end

  private_class_method def self.build_cabecera_factura(params, data_secuencias)
    today_cuadre = CuadreCaja.exists?(fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day)

    cabecera_factura                          = CabeceraFactura.new

    cabecera_factura.fecha_equivalente        = params[:fecha_equivalente] || (today_cuadre ? CabeceraFactura.calculateNextDay : DateTime.now)
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
    cabecera_factura.serie                    = params[:serie]

    cabecera_factura.otras_validaciones(params, @tipo_de_factura)
    cabecera_factura
  end

  private_class_method def self.crear_dependencias_factura(cabecera_factura, params)
    dependencias = [
      { modelo: DetalleFactura,  key_object: "detalle_facturas",  padre: cabecera_factura },
      { modelo: MovimientoViaje, key_object: "movimientos_viaje", padre: cabecera_factura }
    ]

    crear_actualizar_dependencias(dependencias, params, false) do |key_object, dependencia_data|
      case key_object
      when 'detalle_facturas'  then cabecera_factura.detalle_facturas  = dependencia_data
      when 'movimientos_viaje' then cabecera_factura.movimientos_viaje = dependencia_data
      end
    end
  end

  private_class_method def self.procesar_dgii(cabecera_factura)
    es_compra = @tipo_de_documento.descripcion == TiposFacturasDescripcion.compra

    if @is_electronica && !es_compra
      @res_valid_dgii = DGII_MANAGER.send(cabecera_factura)
      data_response_dgii = @res_valid_dgii.get_data
      @increment_secuencia_comprobante = data_response_dgii[:secuenciaUtilizada] == true
    else
      @increment_secuencia_comprobante = true
    end
  end

  private_class_method def self.nombre_documento
    case @tipo_de_factura.descripcion
    when TiposFacturasDescripcion.cotizacion then 'Cotización'
    when TiposFacturasDescripcion.pre_venta  then 'Pre-Venta'
    else 'Factura'
    end
  end

  private_class_method def self.set_error_response(res, msgs)
    msgs = [msgs] unless msgs.is_a?(Array)
    res.add_msgs(msgs)
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end

  # ===================================================================================================================================================

  def make_identificador
    fecha = fecha_equivalente.is_a?(String) ? DateTime.parse(fecha_equivalente) : fecha_equivalente

    cliente_id_formatted     = ("%04d" % (cliente_id || 0)).reverse
    user_id_formatted        = "%04d" % user_id
    detalles_count_formatted = ("%04d" % detalle_facturas.length).reverse
    factura_id_formatted     = "#{id} ".reverse
    fecha_formatted          = "#{fecha.to_i} ".reverse

    "#{cliente_id_formatted}#{user_id_formatted}#{detalles_count_formatted}#{factura_id_formatted}#{fecha_formatted}"
  end


  # ===================================================================================================================================================

  def self.comprobar_serial(params)
    res = Response.new
    serial_split = params[:serial].split(' ')
    obj = {}

    if serial_split[0]
      first_part = serial_split[0]

      cliente_id = first_part[0,4].reverse.to_i
      obj[:cliente] = cliente_id > 0 ? serialize_parser(Cliente.find_by_id(cliente_id), { nombre_completo: true }) : nil

      user_id = first_part[4,4].to_i
      obj[:user] = serialize_parser(User.find_by_id(user_id), { nombre_completo: true })

      obj[:cantidad_de_detalles] = first_part[8,4].reverse.to_i
    end

    obj[:factura_id] = serial_split[1].reverse if serial_split[1]

    if serial_split[2]
      fecha = DateTime.parse(calculateDateUTC(Time.at(serial_split[2].reverse.to_i)))
      obj[:fecha_equivalente] = fecha.strftime("%d/%m/%Y %I:%M:%S")
    end

    res.set_data(obj)
    res
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

    if params[:tipo] == 'venta' && @tipo_de_factura.descripcion != TiposFacturasDescripcion.pre_venta

      res_actual_paquete                            = SecuenciaComprobante.get_paquete_rnc_by_estado(params[:tipo_factura_id], true)

      return res_actual_paquete unless res_actual_paquete.status_valid

      data_secuencias[:actual_paquete_comprobante]  = res_actual_paquete.get_data
      next_secuencia_comprobante                    = data_secuencias[:actual_paquete_comprobante][:secuencia]
    end

    entidad_secuencia_id                            = params[:FACTURA_DE].present? && !params[:FACTURA_DE].nil? ? params[:FACTURA_DE] : params[:tipo_factura_id]

    data_secuencias[:actual_secuencia_entidad]      = SecuenciaFactura.find_by_tipo_factura_id(entidad_secuencia_id)
    data_secuencias[:numero_factura]                = data_secuencias[:actual_secuencia_entidad][:secuencia] + 1

    numero_comprobante                              = CabeceraFactura.format_comprobante(next_secuencia_comprobante, params)
    data_secuencias[:numero_comprobante]            = numero_comprobante


    res.set_data(data_secuencias)
    return res
  end

  # ===================================================================================================================================================

  def self.format_comprobante(next_secuencia_comprobante, params)
    comprobante = nil

    if params[:tipo] == 'venta'
      serie_indicator   = @is_electronica ? 'E' : 'B'
      secuencial_length = @is_electronica ? '10' : '8'
      comprobante       = "#{serie_indicator}#{@tipo_de_factura.referencia}#{"%0#{secuencial_length}d" % next_secuencia_comprobante}"

    elsif params[:tipo] == TiposFacturasDescripcion.compra.downcase
      comprobante = params[:numero_comprobante].upcase
    end

    comprobante
  end

  # ===================================================================================================================================================

  def procesos_cabecera
    res               = Response.new

    unless self.estado
      return res
    end

    unless self.pre_factura.nil?
      res = CabeceraFactura.payFactura(self.pre_factura, {"deposito" => self.total_factura}, true)
    end

    unless self.cotizacion.nil?
      res = CabeceraFactura.payFactura(self.cotizacion, {"deposito" => self.total_factura}, true)
    end

    return res
  end

  # ===================================================================================================================================================
  def self.update_secuencias(data_secuencias)
    res   = Response.new

    if @tipo_de_documento.descripcion == TiposFacturasDescripcion.compra
      # --------- COMPRA ---------
      unless data_secuencias[:actual_secuencia_entidad].update({ secuencia: data_secuencias[:numero_factura] })
        res.add_msg("Error actualizando la tabla de secuencia de Factura Compra")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    else
      # --------- VENTA / NOTA ---------

      if data_secuencias[:actual_secuencia_entidad].update({ secuencia: data_secuencias[:numero_factura] })

        res_aumento  = nil
        puts " "
        puts " "
        puts " "
        puts "@increment_secuencia_comprobante >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ".red + " #{@increment_secuencia_comprobante}"
        puts " "
        puts " "
        puts " "
        if @increment_secuencia_comprobante
          res_aumento  = SecuenciaComprobante.aumentar_secuencia_comprobante(data_secuencias[:actual_paquete_comprobante][:id]) if !data_secuencias[:actual_paquete_comprobante].nil? && data_secuencias[:actual_paquete_comprobante][:is_paquete]
        end

        unless res_aumento.nil?
          unless res_aumento.status_valid
            res.add_msgs(res_aumento.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end
        end

      else
        res.add_msg("Error actualizando la tabla de secuencia de Factura Venta")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    end

    return res
  end


  # ===================================================================================================================================================
  def self.calculateNextDay
    tomorrow = (DateTime.now.beginning_of_day + 1.days).strftime('%a')

    next_date = ''

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

    ids                = params[:ids].split(',').map(&:to_i)
    facturas           = CabeceraFactura.where(id: ids).includes(CabeceraFactura.models_includes)

    res.set_data(facturas, {all: true})

    return res
  end

  # ===================================================================================================================================================
  # def self.get_one_by_id(params)
  # end
  # ===================================================================================================================================================

  def self.get_facturas_by_params(params, paginate_options, parametros_opcionales)
    res                  = Response.new(paginate_options)

    campoNum           = params[:campo]
    valor_des          = params[:valor].present? ? desencriptarBase64(params[:valor].gsub(/\b&^IC\b/, '\\')) : ''
    tipo_factura_id    = params[:tipo_factura_id]
    is_adelantada      = params[:is_adelantada] != '0' ? params[:is_adelantada].to_boolean : false
    tipo               = params[:tipo] ? params[:tipo] : 'venta'
    pagada             = params[:pagada] != '0' ? params[:pagada].to_boolean : '0'
    estado             = params[:estado] != '0' ? params[:estado].to_boolean : '0'
    serie              = params[:serie] ? params[:serie] : SerieFactura.all


    campo              = FacturasParams.get_campo_by_param(campoNum)
    valor_des          = FacturasParams.parse_valor_by_param(campoNum, valor_des)
    limit_             = campo == FacturasParams.last_50 ? 50 : nil

    valor_where = FacturasParams.params_to_parse_int.my_includes_str(FacturasParams.enum[:"#{campo}"]) ? valor_des : "'#{valor_des}' "

    where_ = "cabecera_facturas.tipo = '#{tipo}' "
    where_ += "AND cabecera_facturas.is_adelantada = #{is_adelantada} "                                               if is_adelantada
    where_ += 'AND (detalle_facturas.retirado < detalle_facturas.cantidad_en_unidades and articulos.estado = true) '  if is_adelantada
    where_ += "AND cabecera_facturas.#{campo} = #{valor_where} "                                                      unless campo == FacturasParams.last_50 || campo == FacturasParams.todas
    where_ += "AND cabecera_facturas.tipo_factura_id = #{tipo_factura_id}"                                            unless tipo_factura_id == "0"
    where_ += "AND cabecera_facturas.pagada = #{pagada} "                                                             if params[:pagada].present? && pagada != "0"
    where_ += "AND cabecera_facturas.estado = #{estado} "                                                             if params[:estado].present? && estado != "0"
    where_ += "AND cabecera_facturas.serie = '#{serie}' "                                                             if serie != SerieFactura.all

    joins_ = 'inner join tipo_facturas on cabecera_facturas.tipo_factura_id = tipo_facturas.id inner join users on cabecera_facturas.user_id = users.id '
    joins_ += 'inner join detalle_facturas on cabecera_facturas.id = detalle_facturas.cabecera_factura_id ' if is_adelantada
    joins_ += 'inner join articulos on detalle_facturas.articulo_id = articulos.id'                         if is_adelantada

    facturas = CabeceraFactura.joins(joins_)
                             .where(where_)
                             .includes(CabeceraFactura.models_includes)
                             .order('cabecera_facturas.id DESC')
                             .group('cabecera_facturas.id')
                             .limit(limit_)

    if facturas.length > 0
      res.set_data(facturas, {all: true, **parametros_opcionales})
    else
      cantidad_registros = CabeceraFactura.all.count

      documento =  tipo == TiposFacturasDescripcion.cotizacion  ? 'Cotizaciones' : tipo == TiposFacturasDescripcion.pre_venta ? 'Pre-Ventas' : 'Facturas'

      res.add_msg("No existen #{documento} con las especificaciones introducidas") if !is_adelantada && cantidad_registros != 0
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================
  def self.get_viajes_by_completar(params, paginate_options, parametros_opcionales)
    res                  = Response.new(paginate_options)

    palabra_a_buscar     = params[:palabra_a_buscar]
    where                = "is_viaje = true AND cabecera_facturas.estado = true AND ( fecha_completada is null or (fecha_completada between '#{DateTime.now.beginning_of_day - 3.days}' AND '#{DateTime.now.end_of_day}') )"
    joins_               = 'inner join clientes on clientes.id = cabecera_facturas.cliente_id'

    cabeceras    = CabeceraFactura
    .joins(joins_)
    .where("#{where} AND lower(cabecera_facturas.numero_comprobante || ' ' || cabecera_facturas.numero_factura || ' ' || clientes.nombre || ' ' || clientes.apellido) like lower('%#{palabra_a_buscar}%') ")
    .order('cabecera_facturas.id DESC').group('cabecera_facturas.id')

    if cabeceras.length > 0
      res.set_data(cabeceras, {all: true, **parametros_opcionales}, CabeceraFactura.models_includes)
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

    where                        = "cliente_id=#{params[:cliente_id]} AND pagada=#{params[:pagada]} AND tipo='venta' AND condicion='Crédito' AND cabecera_facturas.estado=true"

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
        has_notas        = res_notas.get_data
        msg_             = 'La factura no puede ser editada, por que ha sido modificada por una nota.' if has_notas

        if has_notas || (has_pagos && !factura.is_contado)
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
            factura_editada                = CabeceraFactura.find_by_id(params[:id])
            res.set_data(factura_editada, {all: true, movimientos_viaje: true})
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

      raise ActiveRecord::Rollback if !factura_original.errors.empty? || !res.status_valid
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

			raise ActiveRecord::Rollback if !factura.errors.empty? || !res.status_valid
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

      raise ActiveRecord::Rollback if !factura_a_pagar.errors.empty? || !res.status_valid
    end

    return res
  end


  # =====================================================================================================================
  def self.delete_documentos(params)
    res                 = Response.new
    res_valid           = Response.new

    ids                 = params[:ids].split(',').map(&:to_i)
    documentos          = CabeceraFactura.where(id: ids).includes(CabeceraFactura.models_includes)
    obj_deleted         = { success: [], error: [] }.with_indifferent_access

    documentos.each do | documento |
      success_deleted   = true

      if documento.tipo != TiposFacturasDescripcion.cotizacion && documento.tipo != TiposFacturasDescripcion.compra.downcase && documento.condicion == "Crédito" || documento.is_viaje
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
    aplicaciones_en_notas           = FacturaAplicada.where(cabecera_factura_id: self.id).joins(:nota).where(notas: {estado: true})
    total_modificado                = 0

    aplicaciones_en_notas.each do | fact_aplicada |
      tipo_nota = fact_aplicada.tipo_nota

      if tipo_nota == tipo
        total_modificado += fact_aplicada.total
      end

    end

    return total_modificado
  end

  # =====================================================================================================================
  def self.calculateNextBalanceFactura(id, monto_recibido)
    res = Response.new

      factura                     = CabeceraFactura.find_by_id(id)
      balance                     = factura.balance

      if monto_recibido.to_f > balance
        res.set_data({ :balance => 0, :balance_anterior => balance, :devolucion => (monto_recibido.to_f - balance), :factura => factura})
      else
        sumatoria = (balance - monto_recibido.to_f).to_d.truncate(2).to_f
        res.set_data({ :balance => sumatoria, :balance_anterior => balance, :devolucion => 0, :factura => factura})
      end

    return res
  end

  # =====================================================================================================================
  def self.agregar_nota_a_cabecera_factura(factura_aplicada, nota)
    res                 = Response.new
    factura             = CabeceraFactura.find_by_id(factura_aplicada[:cabecera_factura_id])
    dias_de_creada      = (DateTime.now - Date.parse(factura.fecha_equivalente.to_s)).to_i
    operador            = nota.tipo_nota == TiposNotas.credito ? '-' : '+'


    total_en_favor_factura     = factura.total_factura
    total_en_favor_factura    += factura.get_total_modificado_por_notas(TiposNotas.debito)
    total_en_favor_factura    -= factura.itbis if dias_de_creada >= 30

    total_en_contra_factura    = factura.get_total_modificado_por_notas(TiposNotas.credito) + (factura_aplicada[:total].to_d).abs

    factura.balance      = eval "#{factura.balance} #{operador} #{(factura_aplicada[:total].to_d).abs}" if !factura.is_contado || ( factura.is_viaje && !factura.pagada )
    factura.estado       = false if (total_en_favor_factura - total_en_contra_factura) < 1
    factura.tiene_nota   = true

    unless factura.save!
      res.add_msgs(factura.errors.to_a)
      res.add_msg('Error agregando nota a la factura')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =====================================================================================================================
  def retirar_nota_a_cabecera_factura(factura_aplicada)
    res               = Response.new
    operador          = factura_aplicada.tipo_nota == TiposNotas.credito ? '+' : '-'

    self.balance      = eval "#{self.balance} #{operador} #{(factura_aplicada[:total].to_d).abs}" if !self.is_contado || self.is_viaje
    self.estado       = true
    self.tiene_nota   = self.facturas_aplicadas.any? { |factura_ap| factura_ap.id != factura_aplicada.id && factura_ap.nota.estado }

    unless self.save!
      res.add_msgs(self.errors.to_a)
      res.add_msg('Error removiendo nota de la factura')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end


    factura_aplicada.detalles_facturas_notas.each do | detalle_nota |


      result_revert_detalle = detalle_nota.procesos_remover_detalles_facturas_notas

      return result_revert_detalle unless result_revert_detalle.status_valid
    end

    return res
  end

  # =====================================================================================================================

  def equivalent_serie
    self.serie == SerieFactura.normal ? SerieFactura.electronica : SerieFactura.normal
  end

  # =====================================================================================================================

  def equivalent_tipo_factura
    key              = self.tipo_factura.key
    TipoFactura.find_by(:serie => SerieFactura.electronica, :key => key)
  end

  # =====================================================================================================================

  def self.encf_remplace(current_factura)
    return Response.new(nil, HTTP_STATUS_CODE[:bad_request], nil, ['Solo se pueden reemplazar facturas de venta']) if current_factura.tipo != 'venta'

    res = Response.new
    tipo_factura_descripcion_origin = current_factura.tipo_factura.descripcion

    # Establecer variables globales necesarias
    setup_encf_remplace_vars(current_factura)
    return Response.new(nil, HTTP_STATUS_CODE[:bad_request], nil, ['Error buscando el tipo tipo_de_documento para reemplazar el comprobante.']) if @tipo_de_documento.nil?

    CabeceraFactura.transaction do
      res = ejecutar_encf_remplace(current_factura, tipo_factura_descripcion_origin)
      raise ActiveRecord::Rollback unless res.status_valid
    end

    res
  end

  private_class_method def self.setup_encf_remplace_vars(current_factura)
    @is_electronica                  = true
    @tipo_de_factura                 = current_factura.equivalent_tipo_factura
    @increment_secuencia_comprobante = false

    key_target       = current_factura.is_contado ? TiposFacturasKey.venta_contado : TiposFacturasKey.venta_credito
    @tipo_de_documento = TipoFactura.find_by(key: key_target, serie: SerieFactura.electronica)
  end

  private_class_method def self.ejecutar_encf_remplace(current_factura, tipo_factura_descripcion_origin)
    res = Response.new

    # Obtener secuencias
    params_for_secuencias = {
      tipo:            current_factura.tipo,
      tipo_factura_id: @tipo_de_factura.id,
      serie:           SerieFactura.electronica,
      FACTURA_DE:      @tipo_de_documento.id
    }

    res_secuencias = CabeceraFactura.find_secuencias(params_for_secuencias)
    return res_secuencias unless res_secuencias.status_valid

    data_secuencias = res_secuencias.get_data

    # Crear nueva factura
    nueva_factura = build_factura_remplazo(current_factura, data_secuencias, params_for_secuencias)
    return set_error_response(res, nueva_factura.errors.to_a) unless nueva_factura.errors.empty?

    # Guardar nueva factura
    nueva_factura.estado = true
    return set_error_response(res, nueva_factura.errors.to_a) unless nueva_factura.save!

    # Desactivar factura original
    current_factura.estado          = false
    current_factura.is_ncf_modificado = true
    return set_error_response(res, current_factura.errors.to_a) unless current_factura.save!

    # Procesar DGII
    procesar_dgii(nueva_factura)

    # Crear referencia entre documentos
    res_reference = DocumentReference.create_reference(current_factura, nueva_factura)
    return set_error_response(res, res_reference.get_msgs.to_a) unless res_reference.status_valid

    # Actualizar secuencias
    res_update_secuencias = CabeceraFactura.update_secuencias(data_secuencias)
    return set_error_response(res, res_update_secuencias.get_msgs.to_a) unless res_update_secuencias.status_valid

    # Respuesta exitosa
    res.set_data(nueva_factura, { all: true, movimientos_viaje: true })
    res.add_msg("#{tipo_factura_descripcion_origin} reemplazada correctamente.")
    res
  end

  private_class_method def self.build_factura_remplazo(current_factura, data_secuencias, params_for_secuencias)
    nueva_factura = CabeceraFactura.new
    nueva_factura.assign_attributes(current_factura.attributes.except('id', 'identificador', 'created_at', 'updated_at'))

    # Asignar nuevos valores
    nueva_factura.serie              = SerieFactura.electronica
    nueva_factura.tipo_factura_id    = @tipo_de_factura.id
    nueva_factura.numero_comprobante = data_secuencias[:numero_comprobante]
    nueva_factura.numero_factura     = data_secuencias[:numero_factura]
    nueva_factura.fecha_valida       = current_factura.fecha_valida.present? ? data_secuencias[:actual_paquete_comprobante]&.fecha_valida : nil

    # Duplicar dependencias
    nueva_factura.detalle_facturas  = duplicar_detalles(current_factura.detalle_facturas)
    nueva_factura.movimientos_viaje = duplicar_movimientos(current_factura.movimientos_viaje)

    nueva_factura.otras_validaciones(params_for_secuencias, @tipo_de_factura)
    nueva_factura
  end

  private_class_method def self.duplicar_detalles(detalles)
    detalles.map do |detalle|
      nuevo = DetalleFactura.new
      nuevo.assign_attributes(detalle.attributes.except('id', 'cabecera_factura_id', 'created_at', 'updated_at'))
      nuevo
    end
  end

  private_class_method def self.duplicar_movimientos(movimientos)
    movimientos.map do |movimiento|
      nuevo = MovimientoViaje.new
      nuevo.assign_attributes(movimiento.attributes.except('id', 'cabecera_factura_id', 'created_at', 'updated_at'))
      nuevo
    end
  end

  # =====================================================================================================================
  def ncf_modificado
    return nil if self.document_reference_as_referenced.nil? || !self.document_reference_as_referenced.present?

    self.document_reference_as_referenced.document_origin.numero_comprobante
  end
  # =====================================================================================================================
end
