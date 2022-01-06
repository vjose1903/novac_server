class CabeceraFactura < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :suplidor, optional: true
  belongs_to :cliente, optional: true
  belongs_to :user

  has_many :detalle_facturas, dependent: :destroy

  # ===================================================================================================================================================
  def self.create_factura(params , is_save=false)
    CabeceraFactura.transaction do
      res                                  = Response.new
      res_secuencias                       = CabeceraFactura.find_secuencias(params)

      if res_secuencias.status_valid

        data_secuencias                    = res_secuencias.get_data
        num_factura_blank                  = CabeceraFactura.where({numero_factura: data_secuencias[:numero_factura], tipo: params["tipo"], tipo_factura_id: params["tipo_factura_id"] }).blank?
        
        if num_factura_blank
          
          res_valid                        = Response.new
          
          if params["condicion"] == "Crédito" && params["tipo"] == "venta" || params["is_viaje"]
            res_valid                      = Cliente.calculate_balance_cliente(params["cliente_id"], params["total_factura"], "+")
          end
          
          # NOTA DE CREDITO
          if res_valid.status_valid && params["is_nota"] && params["tipo_factura_id"] == 5
            res_valid                      = Cliente.calculate_balance_cliente(params["cliente_id"], params["total_factura"].to_f.abs, "-")
            res_valid                      = CabeceraFactura.agregar_nota_a_CabeceraFactura(params["factura_id"], params)                       if res_valid.status_valid
          end
          
          # NOTA DE DEBITO
          if res_valid.status_valid && params["is_nota"] && params["tipo_factura_id"] == 4
            res_valid                      = Cliente.calculate_balance_cliente(params["cliente_id"], params["total_factura"].to_f.abs, "+")
            res_valid                      = CabeceraFactura.agregar_nota_a_CabeceraFactura(params["factura_id"], params)                       if res_valid.status_valid
          end
          
          if res_valid.status_valid

            today_cuadre                              = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})
            cabecera_factura                          = CabeceraFactura.new()
          
            cabecera_factura.fecha_equivalente        = params["fecha_equivalente"] ? params["fecha_equivalente"] : today_cuadre.blank? ? DateTime.now : CabeceraFactura.calculateNextDay
            cabecera_factura.fecha_completada         = params["condicion"] === "Contado" && !params["is_viaje"] ? params["fecha_equivalente"] : nil
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

            # TODO: seguir aqui poniendo las dependencias
            dependencias = [ {modelo: DetalleFactura, key_object: "detalle_facturas", padre: cabecera_factura} ]
            
            res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data| 
              cabecera_factura.detalle_facturas   = dependencia_data if key_object == 'detalle_facturas'
            }

            if res.status_valid && cabecera_factura.errors.empty? && (!is_save || (is_save && cabecera_factura.save!))

              res_valid                = CabeceraFactura.update_secuencias(params, data_secuencias)
      
              if res_valid.status_valid
      
                # res.set_data(serialize_parser(cabecera_factura, {all: true}))
                res.set_data(cabecera_factura, {all: true})
                res.add_msg("factura creada correctamente.")
              else
                res.add_msgs(res_valid.get_msgs)
                res.set_status(HTTP_STATUS_CODE[:conflict])
              end
      
            else
              res.add_msgs(cabecera_factura.errors.to_a)
              res.set_status(HTTP_STATUS_CODE[:conflict])
            end

          else
            res.add_msgs(res_valid.get_msgs)
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
      
      return res 
      raise ActiveRecord::Rollback unless res.status_valid

    end
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
      
      res_actual_paquete                           = SecuenciaComprobante.get_paquete_rnc_by_estado(params["tipo_factura_id"], true)

      return res_actual_paquete unless res_actual_paquete.status_valid

      data_secuencias[:actual_paquete_comprobante] = res_actual_paquete.get_data
      next_secuencia_comprobante = data_secuencias[:actual_paquete_comprobante]["secuencia"]
    end

    tipoFactura = TipoFactura.find_by_id(params["tipo_factura_id"])

    data_secuencias[:actual_secuencia_factura]     = SecuenciaFactura.find_by_tipo_factura_id(params["tipo_factura_id"]) if params["tipo"] == "venta" || params["is_nota"]
    data_secuencias[:actual_secuencia_factura]     = SecuenciaFactura.find_by_tipo_factura_id(params["FACTURA_DE"])      if params["tipo"] == "compra"
    data_secuencias[:numero_factura]               = data_secuencias[:actual_secuencia_factura]["secuencia"] + 1

    if params["FACTURA_DE"] == 14 # COMPRA
      data_secuencias[:numero_comprobante]         = cabecera_factura_params["numero_comprobante"].upcase
    else # VENTA / NOTAS
      data_secuencias[:numero_comprobante]         = "B#{tipoFactura["referencia"]}#{"%08d" % next_secuencia_comprobante}"
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
      puts "data_secuencias[:actual_paquete_comprobante][:is_paquete] ".magenta + "#{data_secuencias[:actual_paquete_comprobante][:is_paquete]}" 

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

  def self.ajustarBalanceCliente(params)
    res = Response.new

    resultCliente    = Cliente.calculate_balance_cliente(params.cliente_id, params["total_factura"], "")
    
    unless resultCliente.status_valid
      res.add_msg(resultCliente.get_msgs.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end
    
    return res 
  end

  # ===================================================================================================================================================
  def is_contado
    return self.condicion == 'Contado'
  end

  # ===================================================================================================================================================
  def self.getDetallesNotasByFactura(aplicadaA)
    detalles_nota = {}
    notas = CabeceraFactura.where({ aplicada_a: aplicadaA })

    notas.each do |nota|

      arrayDetalle = DetalleFactura.where({ cabecera_factura_id: nota["id"] })

      arrayDetalle.each do |detalle|
        unless detalles_nota[detalle.detalle_factura_nota]
          detalles_nota[detalle.detalle_factura_nota] = 0
        end

        detalles_nota[detalle.detalle_factura_nota] += detalle.cantidad
      end
    end

    return detalles_nota
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
  def self.get_facturas_by_params(params, paginate_options)
    CabeceraFactura.transaction do
      res = Response.new

      campoNum = params[:campo]
      valor_des = desencriptarBase64(params[:valor].gsub(/\b&^IC\b/, '\\'))
      tipo_factura_id = params[:tipo_factura_id]
      is_adelantada = params[:is_adelantada].to_boolean
      fact_de = params[:fact_de] ? params[:fact_de] : "venta"

      # puts "campoNum       : ".cyan + "#{campoNum}"
      # puts "is_adelantada  : ".red + "#{is_adelantada}"
      # puts "valor_des      : ".yellow + "#{valor_des}"
      # puts "tipo_factura_id: ".green + "#{tipo_factura_id}"
      
      campo = FacturasParams.get_campo_by_param(campoNum)
      valor_des = FacturasParams.parse_valor_by_param(campoNum, valor_des)
      limit_ = campo == "last_50" ? 50 : nil

      valor_where = campo == "cliente_id" || campo == "numero_factura" ? valor_des : "'#{valor_des}' "

      where_ = "cabecera_facturas.tipo = '#{fact_de}' and cabecera_facturas.is_adelantada = #{is_adelantada} "

      where_ = "detalle_facturas.retirado < detalle_facturas.cantidad_en_unidades "  if is_adelantada

      where_ += "and cabecera_facturas.#{campo} = #{valor_where} "              unless campo == "last_50"
      
      where_ += "and cabecera_facturas.tipo_factura_id = #{tipo_factura_id}"    unless tipo_factura_id == "0"


      joins_ = "inner join tipo_facturas on cabecera_facturas.tipo_factura_id = tipo_facturas.id inner join users on cabecera_facturas.user_id = users.id "

      joins_ += "inner join detalle_facturas on cabecera_facturas.id = detalle_facturas.cabecera_factura_id" if is_adelantada


      facturas = CabeceraFactura.joins(joins_).where(where_).order("cabecera_facturas.id DESC").group("cabecera_facturas.id").limit(limit_).to_a
      puts "======== mmg".red + "#{facturas.to_json}"
      if facturas.length > 0
        #  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        facturas_ = []
        facturas.each do |factura|
          objFactura = factura.attributes
          objFactura['detalle_facturas'] = []
          objFactura['usuario'] = "#{factura.user.nombre.titleize} #{factura.user.apellido.titleize}" 

          if !objFactura["vendedor_id"].nil?
            vendedor_ = User.get_vendedor_by_id(objFactura["vendedor_id"])[0]
            vendedor = "#{vendedor_["nombre"].titleize} #{vendedor_["apellido"].titleize}"
            objFactura["vendedor"] = vendedor
          end

          factura.detalle_facturas.each do |detalle|
            articuloSelect             = Articulo.find_by_id(detalle["articulo_id"])
            unidad                     = detalle["unidad"].split(" ")
            objDetalle                 =  detalle.attributes

            objDetalle["se_calcula_saco"] = Articulo.checkFechaCalcularSaco(factura["fecha_equivalente"], articuloSelect)
            
            if unidad.length > 1
              if objDetalle["se_calcula_saco"]
                objDetalle["descripcion"] = "#{articuloSelect["nombre"]} (#{unidad[2]} LBS)#{objDetalle["calcular_saco"] ? '' : '*'}"
              else
                objDetalle["descripcion"] = "#{articuloSelect["nombre"]} (#{unidad[2]} LBS)"
              end
              
              objDetalle["unidad"] = "#{unidad[0]}"
              objDetalle["peso_saco"] = unidad[2]
            else
              objDetalle["descripcion"] = "#{articuloSelect["nombre"]}"
              objDetalle["unidad"] = detalle["unidad"]
            end
            objDetalle["codigo"] = articuloSelect["codigo"]

            objFactura['detalle_facturas'].push(objDetalle)
            
          end
          facturas_.push(objFactura)
          
        end
        #  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        res.set_data(facturas_)
      else
        res.set_data([])
        res.add_msg("No existe facturas con las especificaciones introducidas") unless is_adelantada
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res
    end
  end

  # ===================================================================================================================================================
  def self.get_facturas_by_cliente_id_and_estado(cliente_id, pagada)
    select_ = 'SELECT ca.id, tipo_factura_id ,tf.descripcion as tipo_factura, suplidor_id, cliente_id, user_id, fecha_equivalente, fecha_vencimiento, 
    fecha_valida, numero_comprobante, numero_factura, condicion, forma_pago, total_factura, itbis, descuento, ca.estado, tipo, ca.created_at, ca.updated_at, 
    ca."Bruto", ca."NoCliente_nombre", ca."NoCliente_direccion", pagada, ca.vendedor_id, ca.balance, ca.devuelta, ca.is_adelantada, ca.is_nota, ca.aplicada_a, 
    ca.tiene_nota,ca.is_viaje,ca.fecha_completada, ca.fecha_viaje , CONCAT(u.nombre, ' + "' '" + ", u.apellido)as usuario"
    from_ = "FROM cabecera_facturas ca"
    joins_ =
      "inner join tipo_facturas tf on ca.tipo_factura_id = tf.id
    inner join users u on ca.user_id = u.id"
    where_ = " WHERE cliente_id=#{cliente_id} and pagada=#{pagada} and tipo='venta' and condicion='Crédito' and ca.estado=true"
    query = "#{select_} #{from_} #{joins_} #{where_}"
    return my_query(query)
  end

  # ====================================================================================================

  def self.verificateFacturaHasPagos(factura)

    pagos = DetalleRecibo.where({ cabecera_factura_id: factura['id'] }).as_json

    my_print_log('pagos'.red + "#{pagos.to_json}" ) 

    my_print_log('LA FACTURA YA HA RECIBIDO PAGOS'.red) if pagos && pagos.length > 0

    return pagos.length > 0 
  end

  # ====================================================================================================

  def self.verificateFacturaHasNotas(factura, id=nil)
    factura = id ? CabeceraFactura.find_by_id(id) : factura

    notas = CabeceraFactura.where({ aplicada_a: factura["numero_comprobante"] }).as_json
    my_print_log('LA FACTURA YA TIENE NOTAS REGISTRADAS'.red) if notas && notas.length > 0
    return notas.length > 0 ? true : false
  end
  
  # ====================================================================================================
  
  def self.verificateCanUpdateViaje(factura)
    my_print_log('verificateCanUpdateViaje ')

    ha_recibido_pagos = verificateFacturaHasPagos(factura) 

    my_print_log('VIAJE NO HA RECIBIDO PAGOS'.green) if !ha_recibido_pagos

    return {is_viaje: factura[:is_viaje], can_update: !ha_recibido_pagos} 
  end

    # ====================================================================================================
  def self.verificateCanUpdate(id)
    factura = CabeceraFactura.find_by_id(id)
    last_cuadre = CuadreCaja.all.last

    my_print_log('factura --> ', factura.to_json)
    my_print_log('------------------------------------------------ ')


    if factura
      if last_cuadre.nil? || comparar_fecha(factura[:fecha_equivalente].to_s, last_cuadre[:created_at].to_s, ">=")

        # ver si la factura tiene algun pago.
        has_pagos = verificateFacturaHasPagos(factura)
        return {status: false, msg:'La factura no puede ser editada, por que ya ha recibido pagos anteriormente.'} if has_pagos && !factura.is_contado
        
        # ver si la factura tiene alguna nota de credito.
        has_hotas =  verificateFacturaHasNotas(factura)
        return {status: false, msg:'La factura no puede ser editada, por que ha sido modificada por una nota.'} if has_hotas
        
      else
        
        puts "AQUIIIIIIIIIIII ".yellow

        can_update = verificateCanUpdateViaje(factura)

        my_print_log('can_update ' + "#{can_update}")

        msg_ = 'La factura si puede ser editada.'

        msg_ =  'La factura no puede ser editada, por que no es del dia de hoy.' if !can_update[:is_viaje] && !can_update[:can_update]

        msg_ = 'La factura no puede ser editada, por que el viaje ya ha recibido un pago anteriormente.' if can_update[:is_viaje] && !can_update[:can_update]

        return {status: can_update[:can_update], msg: msg_} 
      end

      return {status: true, msg:'La factura si puede ser editada.'}
    else      
      my_print_log('NO SE ENCONTRO FACTURA CON EL ID MANDADO'.yellow)
      return {status: false, msg:'No se encuentra la factura a editar, contactar a Victor José Vásquez.'}
    end
  end
  
  # ====================================================================================================
  def self.updateFactura(id, params={}, user_current)
  
    validado = verificateCanUpdate(id)

    res = {:error => false,  :msg => '',:status => 200 }
    if validado[:status] 

      @factura_de = params['FACTURA_DE']
      factura_nueva = params['cabecera_factura']

      puts "factura_nueva ==> ".red + "#{factura_nueva.to_json}"
      factura_original = CabeceraFactura.find_by_id(id)
      puts "factura_original ==> ".green + "#{factura_original.to_json}"
      
      if factura_original[:condicion] == "Crédito"
        calculo_para_balancear_cliente = factura_nueva[:total_factura] - factura_original[:total_factura]
        puts "calculo_para_balancear_cliente ==> ".yellow + "#{calculo_para_balancear_cliente.to_json}"

        resultCliente = Cliente.calculate_balance_cliente(factura_original[:cliente_id], calculo_para_balancear_cliente, "+")
        return {:error => true,  :msg => resultCliente[:msg] ,:status => resultCliente[:status] } if resultCliente[:error]
      end
      
      detalles = DetalleFactura.where({ cabecera_factura_id: id })
      
      detalles.each do |detalle|
        articulo = Articulo.find_by_id(detalle["articulo_id"])
        mov = (articulo["existencia"] + detalle["cantidad_en_unidades"])
        if articulo.update({ existencia: mov })
          detalle.destroy
        else
          return { :error => true, :msg => "Error devolviendo la cantidad de #{articulo["nombre"]} en el inventario", :status => 400 }
        end
      end

      factura_nueva['detalle_facturas_attributes'].each do |detalle|
        
        detalle_ = CabeceraFactura.formarDetalleFactura(detalle, factura_original['id'])
        
        unless detalle_.save!
          return { :error => true, :msg => "Error editando articulo de la factura.", :status => 400 }
        else
          articulo    = Articulo.find_by_id(detalle["articulo_id"])
          art         = detalle 
          art['id']   = detalle['articulo_id']

            # (objArticulo,cantidad_en_unidades, factura_de, tipo, cabecera_factura, user_) 

          # si voy a editar una factura de compra buscar el movimiento de inventario que se genero cuando se compro la factura y borrarlo
          operador = @factura_de == 14 ? "+" : "-"
          MovimientosInventario.movimientos_de_inventario_(detalle, operador, factura_original[:fecha_equivalente], 'factura', factura_original)
        end
        
      end


      factura_original.total_factura   = factura_nueva['total_factura']
      factura_original.itbis           = factura_nueva['itbis']
      factura_original.descuento       = factura_nueva['descuento']
      factura_original.Bruto           = factura_nueva['Bruto']
      factura_original.pagada          = factura_nueva['pagada']
      factura_original.balance         = factura_nueva['balance']
      factura_original.devuelta        = factura_nueva['devuelta']

      unless factura_original.save!
        return { :error => true, :msg => 'Error editando la factura', :status => 400 }
      else
        return { :error => false, :msg => 'Factura editada correctamente.', :status => 200 }
      end
      
    else
      return { :error => true, :msg => validado[:msg], :status => 400 }
    end

  end
  # ====================================================================================================
  def self.formarDetalleFactura(detalle, fact_id)
    detalle_ = DetalleFactura.new
    
    detalle_["articulo_id"]            = detalle['articulo_id'] 
    detalle_["descuento_valor"]        = detalle['descuento_valor']
    detalle_["cantidad_en_unidades"]   = detalle['cantidad_en_unidades']
    detalle_["cantidad"]               = detalle['cantidad']
    detalle_["total"]                  = detalle['total']
    detalle_["descuento_porciento"]    = detalle['descuento_porciento']
    detalle_["itbis"]                  = detalle['itbis']
    detalle_["unidad"]                 = detalle['unidad']
    detalle_["precio"]                 = detalle['precio']
    detalle_["retirado"]               = detalle['retirado']
    detalle_["retirado_en_venta"]      = detalle['retirado_en_venta']
    detalle_['cabecera_factura_id']    = fact_id
    
    return detalle_
  end

  # ====================================================================================================
  def self.payFactura(factura_id, recibo)
    CabeceraFactura.transaction do
      res               = Response.new
      factura_a_pagar   = CabeceraFactura.find_by_id(factura_id)

      if factura_a_pagar["tiene_nota"]
        monto_editado_por_notas                = 0
        notas = CabeceraFactura.where({ aplicada_a: factura_a_pagar["numero_comprobante"] })

        notas.each do |nota|
          if nota["tipo_factura_id"] === 5
            monto_editado_por_notas            = monto_editado_por_notas - nota["total_factura"].abs
          elsif nota["tipo_factura_id"] === 4
            monto_editado_por_notas            = monto_editado_por_notas + nota["total_factura"].abs
          end
        end
        # factura_a_pagar["balance"]     = factura_a_pagar["balance"] + monto_editado_por_notas ( OJO )

        # si la factura tiene una nota le quito el valor modificado
        factura_a_pagar["balance"]             = factura_a_pagar["balance"] - monto_editado_por_notas
      end

      newBalance                               = factura_a_pagar["balance"] - recibo["deposito"]
      
      is_pago_total                            = newBalance < 1 || recibo["deposito"] == factura_a_pagar["balance"]

      factura_a_pagar.balance                  = newBalance >= 1 ? newBalance : 0
      factura_a_pagar.pagada                   = true           if is_pago_total
      factura_a_pagar.fecha_completada         = DateTime.now   if is_pago_total

      unless factura_a_pagar.save!
        res.add_msgs(factura_a_pagar.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res 
    end
  end

  # =====================================================================================================================
  def self.anular_factura(id)
    peticion = my_query("UPDATE cabecera_facturas SET estado=#{false} WHERE id=#{id}")

    if peticion
      return true
    else
      return false
    end
  end
  # =====================================================================================================================

  def self.recalcularMonto(factura)
    monto_editado_por_notas = 0
    notas = CabeceraFactura.where({ aplicada_a: factura["numero_comprobante"] })

    notas.each do |nota|
      if nota["tipo_factura_id"] === 5
        monto_editado_por_notas = monto_editado_por_notas - nota["total_factura"].abs
      elsif nota["tipo_factura_id"] === 4
        monto_editado_por_notas = monto_editado_por_notas + nota["total_factura"].abs
      end
    end

    calculo_balance = factura["balance"] + monto_editado_por_notas
    obj = {
      balance: calculo_balance >= 1 ? calculo_balance : 0,
      total_facturado: factura["total_factura"] + monto_editado_por_notas,
    }
    return obj
  end

  # =====================================================================================================================

  def self.recalculo_factura_por_nota(factura)
    notas = CabeceraFactura.where({aplicada_a: factura['numero_comprobante']})

    notas.each do |nota|
        tipo_nota = TipoFactura.find_by_id(nota['tipo_factura_id'])
        descripcion = tipo_nota.descripcion.split(" ")[2]

        factura['total_factura'] += nota['total_factura']
        factura['balance']       += nota['total_factura']
        # if descripcion == 'credito'
        #     params['total_factura'] -= nota['total_factura']
        # elsif descripcion == 'contado'
        # end
    end
    obj = {
        total_factura: (factura['total_factura']),
        balance: (factura['balance']),
    }
    return obj
end

  # =====================================================================================================================
  def self.calculateNextBalanceFactura(id, montoRecibido)
    res = Response.new

      factura           = CabeceraFactura.find_by_id(id)
      balance           = factura["balance"]
      puts "factura ".yellow + "#{factura.to_json}"

      # total_facturado   = factura["total_factura"]
      # total_facturado   = recalcularMonto(factura)["total_facturado"] if factura.tiene_nota

      sumatoria         = 0
      puts "montoRecibido ".red + "#{montoRecibido}"
      puts "balance       ".green + "#{balance}"
      if montoRecibido.to_f > balance
        res.add_msg("El monto ingresado para la factura: #{factura.numero_comprobante}, es mayor al balance de la factura")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      else
        sumatoria = (balance - montoRecibido.to_f).to_d.truncate(2).to_f
        res.set_data({ :balance => sumatoria, :balance_anterior => balance })
      end

    return res 
  end

  # =====================================================================================================================
  def self.agregar_nota_a_CabeceraFactura(id, nota)
    res                 = Response.new
    factura             = CabeceraFactura.find_by_id(id)
    recalculo           = CabeceraFactura.recalcularMonto(factura)
    
    factura.estado      = false  if recalculo[:total_facturado] < 1 || (nota["total_factura"].to_d).abs == recalculo[:total_facturado] 
    factura.tiene_nota  = true

    unless factura.save!
      res.add_msg("Error agregando nota la factura")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res 
  end
end
