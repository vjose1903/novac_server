class CabeceraFactura < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :suplidor, optional: true
  belongs_to :cliente, optional: true
  belongs_to :user

  attribute :cliente
  attribute :suplidor
  attribute :tipo_factura

  has_many :detalle_facturas, dependent: :destroy
  attribute :detalle_facturas
  accepts_nested_attributes_for :detalle_facturas, :allow_destroy => true
  # ===================================================================================================================================================
  def self.calculateNextDay
    tomorrow = (DateTime.current + 1.days).strftime("%a")

    next_date = ""
    if tomorrow.downcase === "sun"
      next_date = (DateTime.current + 2.days).strftime("%Y-%m-%d")
    else
      next_date = (DateTime.current + 1.days).strftime("%Y-%m-%d")
    end

    return DateTime.parse("#{next_date}T12:00:00").in_time_zone
  end

  # ===================================================================================================================================================
  def self.get_facturas_venta_by_params(campo, valor, tipo_factura_id, is_adelantada)
    select_ = 'SELECT ca.id, tipo_factura_id ,tf.descripcion as tipo_factura, suplidor_id, cliente_id, user_id, fecha_equivalente, fecha_vencimiento,
    fecha_valida, numero_comprobante, numero_factura, condicion, forma_pago, total_factura, itbis, descuento, ca.estado, tipo, ca.created_at, ca.updated_at, 
    ca."Bruto", ca."NoCliente_nombre", ca."NoCliente_direccion", pagada, ca.vendedor_id, ca.balance, ca.devuelta, ca.is_adelantada, ca.is_nota, ca.aplicada_a,
    ca.tiene_nota,ca.is_viaje,ca.fecha_completada, ca.fecha_viaje, CONCAT(u.nombre, ' + "' '" + ", u.apellido)as usuario"
    from_ = "FROM cabecera_facturas ca"
    joins_ = "inner join tipo_facturas tf on ca.tipo_factura_id = tf.id
    inner join users u on ca.user_id = u.id"
    where_ = ""

    if tipo_factura_id == 0 || tipo_factura_id == "0"
      if campo == "numero_comprobante"
        where_ = "WHERE #{campo} = '#{valor}' and tipo = 'venta' and is_adelantada = #{is_adelantada}"
      else
        where_ = "WHERE #{campo} = #{valor} and tipo = 'venta' and is_adelantada = #{is_adelantada}"
      end
    else
      if campo == "numero_comprobante"
        where_ = "WHERE #{campo} = '#{valor}' and tipo = 'venta' and tipo_factura_id = #{tipo_factura_id} and is_adelantada = #{is_adelantada}"
      else
        where_ = "WHERE #{campo} = #{valor} and tipo = 'venta' and tipo_factura_id = #{tipo_factura_id} and is_adelantada = #{is_adelantada}"
      end
    end

    query = "#{select_} #{from_} #{joins_} #{where_}"

    return my_query(query)
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
    where_ = " WHERE cliente_id=#{cliente_id} and pagada=#{pagada} and tipo='venta' and condicion='Crédito'"
    query = "#{select_} #{from_} #{joins_} #{where_}"
    return my_query(query)
  end

  # ====================================================================================================
  def self.verificateCanUpdate(id)
    factura = CabeceraFactura.find_by_id(id)
    
    if factura
      
      can_update = comparar_fecha(factura[:created_at].to_s, Date.today.to_s, "==")
      unless can_update
        can_update = comparar_fecha(factura[:fecha_equivalente].to_s, Date.today.to_s ,">=")
      end
      
      if can_update      
        # ver si la factura tiene algun pago.
        pago_ = DetalleRecibo.where({ cabecera_factura_id: id }).as_json
        if pago_.length > 0
          return {status: false, msg:'La factura no puede ser editada.'}
        end
        
        # ver si la factura tiene alguna nota de credito.
        notas = CabeceraFactura.where({ aplicada_a: factura["numero_comprobante"] }).as_json
        if notas.length > 0
          return {status: false, msg:'La factura no puede ser editada.'}
        end
      else
        return {status: false, msg:'La factura no puede ser editada.'}
      end

      return {status: true, msg:'La factura si puede ser editada.'}

    else      
      return {status: false, msg:'La factura no puede ser editada.'}
    end
  end
  # ====================================================================================================
  def self.updateFactura(id, newFactura={})
    CabeceraFactura.transaction do
      validado = verificateCanUpdate(id)
      if validado[:status] 
      
        puts " "
        puts "++++++++".red * 20 
        factura_original = CabeceraFactura.find_by_id(id)
        puts "factura anterior => ".red + "#{factura_original.to_json}"

        puts "prueba => ".blue + "#{factura_original[:condicion]}"
        
        puts "++++++++".red * 20 
        puts " "

        if factura_original[:condicion] == "Crédito"
          resultCliente = Cliente.CalculateBalanceCLiente(factura_original[:cliente_id], factura_original[:total_factura0], "-")

          if resultCliente[:error]
            render json: resultCliente, status: 400
            raise ActiveRecord::Rollback
          end
        end
        
        detalles = DetalleFactura.where({ cabecera_factura_id: id })
        puts " "
        puts "++++++++".yellow * 20 
        puts "contendio anterior => ".yellow + "#{detalles.to_json}"
        puts "++++++++".yellow * 20 
        puts " "
        
        detalles.each do |detalle|
          articulo = Articulo.find_by_id(detalle["articulo_id"])
          mov = (articulo["existencia"] + detalle["cantidad_en_unidades"])
          if articulo.update({ existencia: mov })
            detalle.destroy
          else
            return { :error => true, :msg => "Error devolviendo la cantidad de #{articulo["nombre"]} en el inventario", :status => 400 }
          end
        end


        
        return { :error => true, :msg => 'Pruebas', :status => 200 }
        

        return { :error => false, :msg => 'La factura editada.', :status => 200 }
      else
        return { :error => true, :msg => validado[:msg], :status => 400 }
      end

    end
  end
  # ====================================================================================================
  def self.payFacturas(facturas)
    res = { error: false, msg: "facturas actualizadas" }
    facturas["detalle_recibos_attributes"].each do |f|
      factura_a_pagar = CabeceraFactura.find_by_id(f["cabecera_factura_id"])

      if factura_a_pagar["tiene_nota"]
        monto_editado_por_notas = 0
        notas = CabeceraFactura.where({ aplicada_a: factura_a_pagar["numero_comprobante"] })
        notas.each do |nota|
          if nota["tipo_factura_id"] === 5
            monto_editado_por_notas = monto_editado_por_notas - nota["total_factura"].abs
          elsif nota["tipo_factura_id"] === 4
            monto_editado_por_notas = monto_editado_por_notas + nota["total_factura"].abs
          end
        end
        factura_a_pagar["balance"] = factura_a_pagar["balance"] + monto_editado_por_notas
      end

      if f["pago_total"]
        if f["deposito"] == factura_a_pagar["balance"]
          unless factura_a_pagar.update({ balance: 0, pagada: true, fecha_completada: DateTime.now })
            res = { error: true, msg: factura_a_pagar.errors }
            return res
          end
        else
          res = { error: true, msg: factura_a_pagar.errors }
          return res
        end
      else
        # si la factura tiene una nota le quito el valor modificado
        if factura_a_pagar["tiene_nota"]
          factura_a_pagar["balance"] = factura_a_pagar["balance"] - monto_editado_por_notas
        end

        newBalance = factura_a_pagar["balance"] - f["deposito"]

        # si la factura tiene una nota le agrego el valor modificado
        if factura_a_pagar["tiene_nota"]
          balance = factura_a_pagar["balance"] + monto_editado_por_notas
        else
          balance = factura_a_pagar["balance"]
        end

        if f["deposito"] == balance
          unless factura_a_pagar.update({ balance: newBalance, pagada: true, fecha_completada: DateTime.now })
            res = { error: true, msg: factura_a_pagar.errors }
            return res
          end
        else
          unless factura_a_pagar.update({ balance: newBalance })
            res = { error: true, msg: factura_a_pagar.errors }
            return res
          end
        end
      end
    end
    return res
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

    obj = {
      balance: factura["balance"] + monto_editado_por_notas,
      total_facturado: factura["total_facturado"] + monto_editado_por_notas,
    }
    return obj
  end

  # =====================================================================================================================
  def self.calculateBalanceFactura(id, montoRecibido, num_fila)
    puts " -------------- Inicio CalculateBalanceFactura -------------- "

    factura = CabeceraFactura.find_by_id(id)

    balance = factura["balance"]

    total_facturado = factura["total_factura"]

    if factura.tiene_nota
      total_facturado = recalcularMonto(factura)
    end

    sumatoria = 0

    if montoRecibido.to_f > balance
      return { :error => true, :msg => "El monto ingresado para la factura: #{factura.numero_comprobante}, es mayor al balance de la factura", :status => 400 }
    else
      sumatoria = balance - montoRecibido.to_f
    end

    sumatoria = sumatoria.to_d.truncate(2).to_f

    return { :error => false, :balance => sumatoria, :balance_anterior => balance }
  end

  # =====================================================================================================================
  def self.ReCalculateBalanceFactura(id, totalFactura, operacion)
    puts " -------------- Inicio ReCalculateBalanceFactura -------------- "

    factura = CabeceraFactura.find_by_id(id)

    balance = factura["balance"]

    if operacion == "+"
      sumatoria = balance + totalFactura.to_f
    else
      if totalFactura.to_f > balance
        return { :error => true, :msg => "El monto ingresado es mayor al balance de la factura", :status => 400 }
      else
        sumatoria = balance - totalFactura.to_f
      end
    end
    sumatoria = sumatoria.to_d.truncate(2).to_f

    unless factura.update({ balance: sumatoria })
      puts " -------------- fin ReCalculateBalanceFactura -------------- "
      return { :error => true, :msg => "Error actualizanco el balance de la factura", :status => 400 }
    else
      puts " -------------- fin ReCalculateBalanceFactura -------------- "
      return { :error => false, :balance => sumatoria }
    end
  end
  # =====================================================================================================================
  def self.agregarNotaACabeceraFactura(id)
    puts " -------------- Inicio agregarNotaACabeceraFactura -------------- "

    factura = CabeceraFactura.find_by_id(id)
    unless factura.update({ tiene_nota: true })
      puts " -------------- fin agregarNotaACabeceraFactura -------------- "
      return { :error => true, :msg => "Error agregando nota la factura", :status => 400 }
    else
      puts " -------------- fin agregarNotaACabeceraFactura -------------- "
      return { :error => false, :tiene_nota => true }
    end
  end
end
